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

  /// Messages in a conversation, ordered by `sentAt`.
  Future<List<MessageModel>> fetchMessages({required String conversationUid}) =>
      _guard('Conversation messages', () async {
        final snap = await _messages(conversationUid).orderBy('sentAt').get();
        return [
          for (final doc in snap.docs)
            MessageModel.fromJson({'uid': doc.id, ...doc.data()}),
        ];
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
    await ref.set({
      'uid': uid,
      'conversationUid': conversationUid,
      'lastReadAt': lastReadAt,
      'lastUpdatedAt': syncTimestamp(),
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

  /// Creates a text message. Client-allowed create under rules.
  Future<void> createTextMessage({
    required String conversationUid,
    required String messageUid,
    required String senderUid,
    required String text,
    required String sentAt,
  }) => _guard('Create text message', () async {
    await _messages(conversationUid).doc(messageUid).set({
      'uid': messageUid,
      'conversationUid': conversationUid,
      'senderUid': senderUid,
      'kind': 'Text',
      'text': text,
      'transcriptStatus': 'None',
      'inputMode': 'Typed',
      'attachmentPath': '',
      'attachmentContentType': '',
      'attachmentSize': 0,
      'attachmentDurationMs': 0,
      'voicePeaks': <int>[],
      'voiceWaveformId': '',
      'replyToMessageUid': '',
      'withheldReason': '',
      'transcriptShared': false,
      'identifierFlagged': false,
      'status': 'Sent',
      'sentAt': sentAt,
      'lastUpdatedAt': syncTimestamp(),
    });
  });

  /// Uploads the voice object first, then creates the message. A failed
  /// upload creates no message.
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
    final path = 'conversations/$conversationUid/voice/$messageUid.m4a';
    await _storage
        .ref(path)
        .putData(bytes, SettableMetadata(contentType: contentType));
    await _messages(conversationUid).doc(messageUid).set({
      'uid': messageUid,
      'conversationUid': conversationUid,
      'senderUid': senderUid,
      'kind': 'Voice',
      'text': '',
      'transcriptStatus': 'Queued',
      'inputMode': 'Voice',
      'attachmentPath': path,
      'attachmentContentType': contentType,
      'attachmentSize': bytes.length,
      'attachmentDurationMs': durationMs,
      'voicePeaks': voicePeaks,
      'voiceWaveformId': '',
      'replyToMessageUid': '',
      'withheldReason': '',
      'transcriptShared': false,
      'identifierFlagged': false,
      'status': 'Sent',
      'sentAt': sentAt,
      'lastUpdatedAt': syncTimestamp(),
    });
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
