import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/features/conversations/data/models/conversation_cursor_model.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';

/// Firestore + Storage + callables for conversations. No caching.
@lazySingleton
class ConversationFirebase {
  ConversationFirebase({
    required this._firestore,
    required this._functions,
    required this._storage,
  });

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FirebaseStorage _storage;
  final Logger _logger = Logger();

  static const int maxVoiceBytes = 512 * 1024;

  AppError _toAppError(Object e) => switch (e) {
    AppError() => e,
    FirebaseFunctionsException() => AppError.fromFunctionsException(e),
    FirebaseException(:final code) => AppError.fromFirebaseCode(code),
    _ => AppError.unknown,
  };

  Future<T> _guard<T>(String operation, Future<T> Function() body) async {
    try {
      return await body();
    } on Exception catch (e) {
      if (kDebugMode) _logger.e('$operation failed: $e');
      throw _toAppError(e);
    }
  }

  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> data,
  ) async {
    final result = await _functions.httpsCallable(name).call<dynamic>(data);
    final raw = result.data;
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return <String, dynamic>{};
  }

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection('conversations');

  CollectionReference<Map<String, dynamic>> _messages(String conversationUid) =>
      _conversations.doc(conversationUid).collection('messages');

  DocumentReference<Map<String, dynamic>> _cursor(
    String conversationUid,
    String uid,
  ) => _conversations.doc(conversationUid).collection('cursors').doc(uid);

  /// Participant delta: `participantUids` contains, `lastUpdatedAt >=` (I-21).
  Future<List<ConversationModel>> fetchParticipantDelta({
    required String uid,
    String? cursor,
  }) => _guard('Conversation participant delta', () async {
    var query = _conversations.where('participantUids', arrayContains: uid);
    if (cursor != null && cursor.isNotEmpty) {
      query = query.where('lastUpdatedAt', isGreaterThanOrEqualTo: cursor);
    }
    query = query.orderBy('lastUpdatedAt');
    final snap = await query.get();
    return [
      for (final doc in snap.docs)
        ConversationModel.fromJson({'uid': doc.id, ...doc.data()}),
    ];
  });

  /// One conversation by id, or null when the server has no row. A denied
  /// read throws; the cache maps that to eviction.
  Future<ConversationModel?> fetchConversation(String conversationUid) =>
      _guard('Fetch conversation', () async {
        final snap = await _conversations.doc(conversationUid).get();
        if (!snap.exists || snap.data() == null) return null;
        return ConversationModel.fromJson({'uid': snap.id, ...snap.data()!});
      });

  /// First page ordered by `lastMessageAt` DESC (I-22).
  Future<List<ConversationModel>> fetchFirstPage({
    required String uid,
    int limit = 30,
  }) => _guard('Conversation first page', () async {
    final snap = await _conversations
        .where('participantUids', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .limit(limit)
        .get();
    return [
      for (final doc in snap.docs)
        ConversationModel.fromJson({'uid': doc.id, ...doc.data()}),
    ];
  });

  /// Messages in a conversation, ordered by `sentAt`; pass [limit] with
  /// [fromSentAt] to page long threads one bounded read at a time. The
  /// cursor is inclusive, so messages sharing the boundary stamp are never
  /// skipped; the merge below dedupes by id.
  ///
  /// The read rule shows withheld rows to their sender only, and a query
  /// must prove every row it could return — so the readable statuses and
  /// the caller's own rows are queried separately, then merged.
  Future<List<MessageModel>> fetchMessages({
    required String conversationUid,
    required String callerUid,
    int? limit,
    String? fromSentAt,
  }) => _guard('Conversation messages', () async {
    Query<Map<String, dynamic>> page(Query<Map<String, dynamic>> base) {
      var query = base.orderBy('sentAt');
      if (fromSentAt != null && fromSentAt.isNotEmpty) {
        query = query.startAt([fromSentAt]);
      }
      if (limit != null) query = query.limit(limit);
      return query;
    }

    final readable = page(
      _messages(
        conversationUid,
      ).where('status', whereIn: const ['Sent', 'Delivered', 'Withdrawn']),
    );
    final own = page(
      _messages(conversationUid).where('senderUid', isEqualTo: callerUid),
    );
    final snaps = await Future.wait([readable.get(), own.get()]);
    final seen = <String>{};
    final rows = <MessageModel>[];
    for (final snap in snaps) {
      for (final doc in snap.docs) {
        if (!seen.add(doc.id)) continue;
        rows.add(MessageModel.fromJson({'uid': doc.id, ...doc.data()}));
      }
    }
    rows.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return rows;
  });

  /// One message by id, or null when the server never saw it.
  Future<MessageModel?> fetchMessage({
    required String conversationUid,
    required String messageUid,
  }) => _guard('Conversation message', () async {
    final doc = await _messages(conversationUid).doc(messageUid).get();
    if (!doc.exists) return null;
    return MessageModel.fromJson({'uid': doc.id, ...?doc.data()});
  });

  /// Forward-only cursor write: create or update `lastReadAt` + stamp.
  Future<void> updateCursor({
    required String conversationUid,
    required String uid,
    required String lastReadAt,
  }) => _guard('Update conversation cursor', () async {
    final ref = _cursor(conversationUid, uid);
    final existing = await ref.get();
    if (existing.exists) {
      final previous = existing.data()?['lastReadAt'] as String? ?? '';
      if (lastReadAt.compareTo(previous) <= 0) {
        return;
      }
      await ref.update({
        'lastReadAt': lastReadAt,
        'lastUpdatedAt': syncTimestamp(),
      });
      return;
    }
    // The rule pins lastUpdatedAt to lastReadAt on create, even when the
    // cursor trails behind now; the update path re-stamps from the clock.
    await ref.set({
      'uid': uid,
      'conversationUid': conversationUid,
      'lastReadAt': lastReadAt,
      'lastUpdatedAt': lastReadAt,
    });
  });

  Future<ConversationCursorModel?> fetchCursor({
    required String conversationUid,
    required String uid,
  }) => _guard('Fetch conversation cursor', () async {
    final snap = await _cursor(conversationUid, uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return ConversationCursorModel.fromJson(snap.data()!);
  });

  /// Creates a text message. The payload matches `messageKeys()` exactly:
  /// no more keys, no fewer, and `lastUpdatedAt` equal to `sentAt`.
  Future<void> createTextMessage({
    required String conversationUid,
    required String messageUid,
    required String senderUid,
    required String text,
    required String sentAt,
  }) => _guard('Create text message', () async {
    // The rule refuses empty and over-long text; failing here fails fast
    // with a clear error instead of a refusal (the queue checks first).
    if (text.isEmpty || text.length > 2000) {
      throw ArgumentError('Text messages must be 1-2000 characters.');
    }
    await _messages(conversationUid).doc(messageUid).set({
      'uid': messageUid,
      'conversationUid': conversationUid,
      'senderUid': senderUid,
      'kind': 'Text',
      'text': text,
      'attachmentPath': '',
      'attachmentType': '',
      'attachmentSize': 0,
      'voiceDurationMs': 0,
      'voicePeaks': <int>[],
      'transcriptShared': false,
      'transcriptLanguage': '',
      'transcriptStatus': 'None',
      'identifierFlagged': false,
      'inputMode': 'Typed',
      'status': 'Sent',
      'withheldReason': '',
      'sentAt': sentAt,
      'deliveredAt': '',
      'lastUpdatedAt': sentAt,
    });
  });

  /// Uploads the voice object, then creates the message right after it. A
  /// failed upload creates no message; a failed create deletes the upload,
  /// so neither half of the pair is ever left dangling.
  Future<void> createVoiceMessage({
    required String conversationUid,
    required String messageUid,
    required String senderUid,
    required Uint8List bytes,
    required String contentType,
    required int durationMs,
    required List<int> voicePeaks,
    required String sentAt,
  }) => _guard('Create voice message', () async {
    if (bytes.isEmpty || bytes.length > maxVoiceBytes) {
      throw AppError.fileTooLarge;
    }
    if (contentType != 'audio/mp4' && contentType != 'audio/aac') {
      throw ArgumentError('Voice uploads must be audio/mp4 or audio/aac.');
    }
    if (durationMs <= 0 || durationMs > 120000) {
      throw ArgumentError('Voice duration must be within (0, 120000] ms.');
    }
    if (voicePeaks.length > 64) {
      throw ArgumentError('Voice peaks must fit in 64 buckets.');
    }
    if (voicePeaks.any((p) => p < 0 || p > 100)) {
      throw ArgumentError('Voice peaks must range 0-100.');
    }
    final path = 'conversations/$conversationUid/voice/$messageUid.m4a';
    await _storage
        .ref(path)
        .putData(bytes, SettableMetadata(contentType: contentType));
    try {
      await _messages(conversationUid).doc(messageUid).set({
        'uid': messageUid,
        'conversationUid': conversationUid,
        'senderUid': senderUid,
        'kind': 'Voice',
        'text': '',
        'attachmentPath': path,
        'attachmentType': contentType,
        'attachmentSize': bytes.length,
        'voiceDurationMs': durationMs,
        'voicePeaks': voicePeaks,
        'transcriptShared': false,
        'transcriptLanguage': '',
        'transcriptStatus': 'Queued',
        'identifierFlagged': false,
        'inputMode': 'Voice',
        'status': 'Sent',
        'withheldReason': '',
        'sentAt': sentAt,
        'deliveredAt': '',
        'lastUpdatedAt': sentAt,
      });
    } on Object catch (_) {
      try {
        await _storage.ref(path).delete();
      } on Object catch (_) {
        // Best effort: the orphan sweep reaps whatever this misses.
      }
      rethrow;
    }
  });

  /// Fetches voice note bytes through the SDK (never a download URL).
  Future<Uint8List> fetchVoiceNoteBytes({
    required String conversationUid,
    required String messageUid,
  }) => _guard('Fetch voice note', () async {
    final path = 'conversations/$conversationUid/voice/$messageUid.m4a';
    final data = await _storage.ref(path).getData(maxVoiceBytes);
    if (data == null || data.isEmpty) throw AppError.dataNotFound;
    return data;
  });

  Future<Map<String, dynamic>> openDirectConversation({
    required String resourceType,
    required String resourceUid,
  }) => _guard(
    'Open direct conversation',
    () => _call('openDirectConversation', {
      'resourceType': resourceType,
      'resourceUid': resourceUid,
    }),
  );

  Future<Map<String, dynamic>> openMdt({
    required String conversationUid,
    required String caseUid,
    required String specialty,
    required String description,
    required List<String> inviteeUids,
  }) => _guard(
    'Open MDT',
    () => _call('openMdt', {
      'conversationUid': conversationUid,
      'caseUid': caseUid,
      'specialty': specialty,
      'description': description,
      'inviteeUids': inviteeUids,
    }),
  );

  Future<Map<String, dynamic>> inviteToMdt({
    required String conversationUid,
    required List<String> inviteeUids,
  }) => _guard(
    'Invite to MDT',
    () => _call('inviteToMdt', {
      'conversationUid': conversationUid,
      'inviteeUids': inviteeUids,
    }),
  );

  Future<Map<String, dynamic>> respondToMdtInvite({
    required String conversationUid,
    required bool accept,
  }) => _guard(
    'Respond to MDT invite',
    () => _call('respondToMdtInvite', {
      'conversationUid': conversationUid,
      'accept': accept,
    }),
  );

  Future<Map<String, dynamic>> leaveMdt({required String conversationUid}) =>
      _guard(
        'Leave MDT',
        () => _call('leaveMdt', {'conversationUid': conversationUid}),
      );

  Future<Map<String, dynamic>> removeFromMdt({
    required String conversationUid,
    required String memberUid,
  }) => _guard(
    'Remove from MDT',
    () => _call('removeFromMdt', {
      'conversationUid': conversationUid,
      'memberUid': memberUid,
    }),
  );

  Future<Map<String, dynamic>> closeConversation({
    required String conversationUid,
  }) => _guard(
    'Close conversation',
    () => _call('closeConversation', {'conversationUid': conversationUid}),
  );

  Future<Map<String, dynamic>> withdrawMessage({
    required String conversationUid,
    required String messageUid,
  }) => _guard(
    'Withdraw message',
    () => _call('withdrawMessage', {
      'conversationUid': conversationUid,
      'messageUid': messageUid,
    }),
  );

  Future<Map<String, dynamic>> shareTranscript({
    required String conversationUid,
    required String messageUid,
    required String decision,
    String? text,
  }) => _guard('Share transcript', () {
    final data = <String, dynamic>{
      'conversationUid': conversationUid,
      'messageUid': messageUid,
      'decision': decision,
      'text': ?text,
    };
    return _call('shareTranscript', data);
  });
}
