import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/features/conversations/data/datasources/conversation_firebase.dart';
import 'package:tabibu/features/conversations/data/models/conversation_cursor_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_cursor_model.dart';
import 'package:tabibu/features/conversations/data/models/conversation_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/data/models/message_hive.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';
import 'package:tabibu/features/conversations/data/models/message_transcript_hive.dart';
import 'package:tabibu/features/conversations/data/models/message_transcript_model.dart';
import 'package:uuid/uuid.dart';

/// Cached conversations, cursors, messages and transcripts: the layer the
/// blocs call.
@lazySingleton
class ConversationCacheHelper {
  ConversationCacheHelper({
    required this._db,
    required this._remote,
    required this._hive,
  });

  final DBHelper _db;
  final ConversationFirebase _remote;

  /// The concrete helper: the lazy messages box opens only through
  /// `messagesBox()`, which the abstract type does not expose.
  final HiveHelper _hive;
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  /// Failures that mean "the cloud cannot be reached", for which the cache
  /// stands in.
  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  /// Replay mapping (§3.8): these drop the local change and refetch by id.
  /// `failed-precondition` collapses into [AppError.unknown], which also
  /// covers transient faults (`aborted`, `internal`), so it stays queued: a
  /// stuck-but-visible row beats a silently dropped message.
  static const Set<AppError> _dropAndRefetch = {
    .permissionDenied,
    .dataNotFound,
  };

  /// Messages kept per conversation; every queued row survives regardless.
  static const messagesKeptPerConversation = 200;

  /// Lazy-box calls surface as [AppError], like the guarded eager boxes: a
  /// box closed mid-sync raises HiveError, which is an Error. Deliberate
  /// [AppError]s pass through untouched.
  Future<R> _guardLazy<R>(
    String operation,
    Future<R> Function(LazyBox<MessageHive> box) body,
  ) async {
    try {
      return await body(await _hive.messagesBox());
    } on AppError {
      rethrow;
      // A closed box raises HiveError, which is an Error; catching it here
      // keeps the failure an AppError like every other box failure.
      // ignore: avoid_catching_errors
    } on HiveError catch (e) {
      if (kDebugMode) _logger.e('DB $operation failed: $e');
      throw AppError.unknown;
    } on Exception catch (e) {
      if (kDebugMode) _logger.e('DB $operation failed: $e');
      throw AppError.unknown;
    }
  }

  /// Whether [incoming] may replace [cached] (sync rule, §6).
  bool _accepts({
    required bool fromCloud,
    required ({bool synced, String lastUpdatedAt})? cached,
    required String incoming,
  }) =>
      !fromCloud ||
      cached == null ||
      cloudRowWins(
        cachedSynced: cached.synced,
        cachedLastUpdatedAt: cached.lastUpdatedAt,
        incomingLastUpdatedAt: incoming,
      );

  Future<bool> _isParticipant(String uid, String conversationUid) async {
    if (uid.isEmpty || conversationUid.isEmpty) return false;
    final row = await _db.get<ConversationHive>(
      HiveHelperImpl.conversationsBox,
      conversationUid,
    );
    return row != null && row.participantUids.contains(uid);
  }

  /// Remote first; the cache answers only when the cloud cannot be reached.
  Future<List<ConversationModel>> syncConversations(
    String uid, {
    String? since,
  }) async {
    if (uid.isEmpty) return const [];
    try {
      final remote = await _remote.fetchParticipantDelta(
        uid: uid,
        cursor: since ?? await conversationCursor(uid),
      );
      await cacheConversations(remote, fromCloud: true);
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      final cached = await getConversations(uid);
      // Nothing cached is "could not read", never "there is none".
      if (cached.isEmpty) rethrow;
      return cached;
    }
    return await getConversations(uid);
  }

  /// The participant's cached conversations, newest activity first.
  Future<List<ConversationModel>> getConversations(
    String uid, {
    ConversationType? type,
  }) async {
    if (uid.isEmpty) return const [];
    final rows = [
      for (final row in await _db.getAll<ConversationHive>(
        HiveHelperImpl.conversationsBox,
      ))
        if (row.participantUids.contains(uid) &&
            (type == null || row.type == type.value))
          row.toModel(),
    ];
    return rows..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
  }

  /// The participant's cached conversations linked to one resource.
  Future<List<ConversationModel>> getForResource(
    String uid,
    String resourceType,
    String linkedResourceUid,
  ) async {
    if (uid.isEmpty) return const [];
    final rows = [
      for (final row in await _db.getAll<ConversationHive>(
        HiveHelperImpl.conversationsBox,
      ))
        if (row.participantUids.contains(uid) &&
            row.linkedResourceType == resourceType &&
            row.linkedResourceUid == linkedResourceUid)
          row.toModel(),
    ];
    return rows..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
  }

  /// The cached conversation, or `.empty()` when uid is not a participant.
  Future<ConversationModel> getConversation(
    String uid,
    String conversationUid,
  ) async {
    if (!await _isParticipant(uid, conversationUid)) {
      return ConversationModel.empty();
    }
    final row = await _db.get<ConversationHive>(
      HiveHelperImpl.conversationsBox,
      conversationUid,
    );
    return row?.toModel() ?? ConversationModel.empty();
  }

  /// Messages from others past the read cursor; 0 outside the thread.
  Future<int> unreadCount(String uid, String conversationUid) async {
    if (!await _isParticipant(uid, conversationUid)) return 0;
    final cursor = await getCursor(uid, conversationUid);
    final lastReadAt = cursor?.lastReadAt ?? '';
    return await _guardLazy('unreadCount', (box) async {
      var count = 0;
      for (final key in box.keys) {
        final row = await box.get(key);
        if (row == null ||
            row.conversationUid != conversationUid ||
            row.senderUid == uid ||
            row.status == MessageStatus.withheld.value ||
            row.sentAt.compareTo(lastReadAt) <= 0) {
          continue;
        }
        count++;
      }
      return count;
    });
  }

  /// One cached page, newest first; empty outside the thread.
  Future<List<MessageModel>> getMessages(
    String uid,
    String conversationUid, {
    String? before,
    int? limit,
  }) async {
    if (!await _isParticipant(uid, conversationUid)) return const [];
    return await _guardLazy('getMessages', (box) async {
      final rows = <MessageModel>[];
      for (final key in box.keys) {
        final row = await box.get(key);
        if (row == null || row.conversationUid != conversationUid) continue;
        if (before != null &&
            before.isNotEmpty &&
            row.sentAt.compareTo(before) >= 0) {
          continue;
        }
        rows.add(row.toModel());
      }
      rows.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      if (limit != null && rows.length > limit) rows.length = limit;
      return rows;
    });
  }

  /// The sender's queued rows, oldest first (flush order).
  Future<List<MessageModel>> getQueuedMessages(String uid) async {
    if (uid.isEmpty) return const [];
    return await _guardLazy('getQueuedMessages', (box) async {
      final rows = <MessageModel>[];
      for (final key in box.keys) {
        final row = await box.get(key);
        if (row == null || row.senderUid != uid || row.synced) continue;
        rows.add(row.toModel());
      }
      rows.sort((a, b) => a.sentAt.compareTo(b.sentAt));
      return rows;
    });
  }

  /// Delta cursor for the conversation list, or null to pull everything.
  Future<String?> conversationCursor(String uid) async =>
      syncCursorFrom((await getConversations(uid)).map((c) => c.lastUpdatedAt));

  /// Delta cursor for one thread, or null to pull everything (or when uid
  /// is outside the thread).
  Future<String?> messageCursor(String uid, String conversationUid) async {
    if (!await _isParticipant(uid, conversationUid)) return null;
    return await _guardLazy('messageCursor', (box) async {
      final stamps = <String>[];
      for (final key in box.keys) {
        final row = await box.get(key);
        if (row == null || row.conversationUid != conversationUid) continue;
        stamps.add(row.lastUpdatedAt);
      }
      return syncCursorFrom(stamps);
    });
  }

  /// Remote first; the cache answers only when the cloud cannot be reached.
  Future<List<MessageModel>> syncMessages(
    String uid,
    String conversationUid,
  ) async {
    if (!await _isParticipant(uid, conversationUid)) {
      throw AppError.dataNotFound;
    }
    try {
      // Page to a short page: every read stays bounded no matter how long
      // the thread grows.
      String? cursor;
      for (;;) {
        final page = await _remote.fetchMessages(
          conversationUid: conversationUid,
          limit: messagesKeptPerConversation,
          fromSentAt: cursor,
        );
        if (page.isEmpty) break;
        await cacheMessages(page, fromCloud: true);
        if (page.length < messagesKeptPerConversation) break;
        // A full page on one stamp cannot advance an inclusive cursor.
        if (page.last.sentAt == cursor) break;
        cursor = page.last.sentAt;
      }
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      final cached = await getMessages(uid, conversationUid);
      // Nothing cached is "could not read", never "there is none".
      if (cached.isEmpty) rethrow;
      return cached;
    }
    return await getMessages(uid, conversationUid);
  }

  /// Caches conversation rows under the merge guard.
  Future<void> cacheConversations(
    List<ConversationModel> conversations, {
    required bool fromCloud,
  }) async {
    final cached = {
      for (final row in await _db.getAll<ConversationHive>(
        HiveHelperImpl.conversationsBox,
      ))
        row.uid: (synced: row.synced, lastUpdatedAt: row.lastUpdatedAt),
    };
    await _db.putAll<ConversationHive>(HiveHelperImpl.conversationsBox, {
      for (final c in conversations)
        if (_accepts(
          fromCloud: fromCloud,
          cached: cached[c.uid],
          incoming: c.lastUpdatedAt,
        ))
          c.uid: ConversationHive.fromModel(
            fromCloud ? c.copyWith(synced: true) : c,
          ),
    });
  }

  /// Caches message rows, then prunes every touched thread to the newest
  /// [messagesKeptPerConversation]. A cloud copy of our own queued row is the
  /// server's acknowledgement: it replaces the row and marks it synced.
  Future<void> cacheMessages(
    List<MessageModel> messages, {
    required bool fromCloud,
  }) => _guardLazy('cacheMessages', (box) async {
    final touched = <String>{};
    for (final m in messages) {
      if (m.uid.isEmpty) continue;
      touched.add(m.conversationUid);
      final cached = await box.get(m.uid);
      final isAck =
          fromCloud &&
          cached != null &&
          !cached.synced &&
          cached.senderUid == m.senderUid;
      if (!isAck &&
          !_accepts(
            fromCloud: fromCloud,
            cached: cached == null
                ? null
                : (synced: cached.synced, lastUpdatedAt: cached.lastUpdatedAt),
            incoming: m.lastUpdatedAt,
          )) {
        continue;
      }
      final row = fromCloud ? m.copyWith(synced: true) : m;
      await box.put(
        m.uid,
        MessageHive.fromModel(
          // The acknowledgement carries no local path; keep ours so the
          // recording still plays offline.
          isAck
              ? row.copyWith(localAttachmentPath: cached.localAttachmentPath)
              : row,
        ),
      );
    }
    for (final conversationUid in touched) {
      if (conversationUid.isNotEmpty) await _prune(conversationUid);
    }
  });

  /// Keeps the newest [messagesKeptPerConversation] synced rows per thread;
  /// queued rows are never pruned.
  Future<void> _prune(String conversationUid) =>
      _guardLazy('pruneMessages', (box) async {
        final synced = <MessageHive>[];
        for (final key in box.keys) {
          final row = await box.get(key);
          if (row == null ||
              row.conversationUid != conversationUid ||
              !row.synced) {
            continue;
          }
          synced.add(row);
        }
        if (synced.length <= messagesKeptPerConversation) return;
        synced.sort((a, b) => b.sentAt.compareTo(a.sentAt));
        for (final row in synced.skip(messagesKeptPerConversation)) {
          await box.delete(row.uid);
        }
      });

  /// Queues a text message and sends it at once; offline it stays queued
  /// and the optimistic row is returned.
  Future<MessageModel> queueTextMessage({
    required String conversationUid,
    required String senderUid,
    required String text,
    String replyToMessageUid = '',
  }) async {
    if (text.isEmpty) throw ArgumentError('Cannot queue an empty message.');
    if (!await _isParticipant(senderUid, conversationUid)) {
      throw AppError.dataNotFound;
    }
    final now = syncTimestamp();
    final queued = MessageModel(
      uid: _uuid.v4(),
      conversationUid: conversationUid,
      senderUid: senderUid,
      kind: MessageKind.text.value,
      text: text,
      replyToMessageUid: replyToMessageUid,
      status: MessageStatus.pending.value,
      sentAt: now,
      lastUpdatedAt: now,
      synced: false,
    );
    return await _queue(queued);
  }

  /// Queues a voice message and sends it at once; offline it stays queued
  /// with its local file path, and the optimistic row is returned.
  Future<MessageModel> queueVoiceMessage({
    required String conversationUid,
    required String senderUid,
    required String localPath,
    required int durationMs,
    required List<int> voicePeaks,
    String contentType = 'audio/mp4',
    String replyToMessageUid = '',
  }) async {
    if (localPath.isEmpty) throw ArgumentError('A voice message needs audio.');
    if (!await _isParticipant(senderUid, conversationUid)) {
      throw AppError.dataNotFound;
    }
    final now = syncTimestamp();
    final queued = MessageModel(
      uid: _uuid.v4(),
      conversationUid: conversationUid,
      senderUid: senderUid,
      kind: MessageKind.voice.value,
      inputMode: InputMode.voice.value,
      transcriptStatus: TranscriptStatus.queued.value,
      attachmentContentType: contentType,
      attachmentDurationMs: durationMs,
      voicePeaks: voicePeaks,
      replyToMessageUid: replyToMessageUid,
      status: MessageStatus.pending.value,
      sentAt: now,
      localAttachmentPath: localPath,
      lastUpdatedAt: now,
      synced: false,
    );
    return await _queue(queued);
  }

  Future<MessageModel> _queue(MessageModel queued) async {
    await cacheMessages([queued], fromCloud: false);
    try {
      await _send(queued);
    } on AppError catch (e) {
      // Transient (and unknown) errors stay queued for the next flush.
      if (_offline.contains(e)) return queued;
      rethrow;
    }
    return await _fresh(queued.uid) ?? queued;
  }

  /// Replays every queued message in scope; attempts all of them, then
  /// rethrows the first failure, if any.
  Future<void> replayPendingMessages(String uid) async {
    AppError? firstFailure;
    for (final row in await getQueuedMessages(uid)) {
      try {
        await _send(row);
      } on AppError catch (e) {
        firstFailure ??= e;
      }
    }
    if (firstFailure != null) throw firstFailure;
  }

  Future<void> _send(MessageModel row) async {
    // Outside the mapping below: a missing recording is terminal locally,
    // never a reason to touch the server truth.
    final voiceBytes = row.kindValue == MessageKind.voice
        ? await _voiceBytes(row)
        : null;
    try {
      switch (row.kindValue) {
        case MessageKind.text:
          await _remote.createTextMessage(
            conversationUid: row.conversationUid,
            messageUid: row.uid,
            senderUid: row.senderUid,
            text: row.text,
            sentAt: row.sentAt,
          );
        case MessageKind.voice:
          await _remote.createVoiceMessage(
            conversationUid: row.conversationUid,
            messageUid: row.uid,
            senderUid: row.senderUid,
            bytes: voiceBytes!,
            contentType: row.attachmentContentType,
            durationMs: row.attachmentDurationMs,
            voicePeaks: row.voicePeaks,
            sentAt: row.sentAt,
          );
        case MessageKind.image:
          // No image send exists server-side yet; fail visibly, keep the row.
          await _markFailed(row.uid, 'no image send');
          throw AppError.unknown;
      }
    } on AppError catch (e) {
      // Transient (and unknown) errors stay queued for the next flush.
      if (_dropAndRefetch.contains(e)) await _dropAndRefetchMessage(row);
      rethrow;
    }
    await _cacheSentEcho(row);
  }

  /// The queued recording, or a terminal `Failed` when it is gone.
  Future<Uint8List> _voiceBytes(MessageModel row) async {
    try {
      return await File(row.localAttachmentPath).readAsBytes();
    } on Exception catch (_) {
      // The recording is gone, so the row can never send: terminal, kept.
      await _markFailed(row.uid, 'recording missing');
      throw AppError.dataNotFound;
    }
  }

  /// The create landed: prefer the server echo, else mark our row sent. A
  /// later sync converges the stamps either way.
  Future<void> _cacheSentEcho(MessageModel row) async {
    MessageModel? echo;
    try {
      echo = await _remote.fetchMessage(
        conversationUid: row.conversationUid,
        messageUid: row.uid,
      );
    } on AppError catch (_) {
      echo = null;
    }
    final found = echo;
    return await _guardLazy('cacheSentEcho', (box) async {
      if (found != null) {
        // Direct: the merge guard would keep the queued row this replaces.
        // The echo carries no local path; keep ours so a recording still
        // plays offline.
        final kept = await box.get(row.uid);
        await box.put(
          row.uid,
          MessageHive.fromModel(
            found.copyWith(
              localAttachmentPath: kept?.localAttachmentPath ?? '',
              synced: true,
            ),
          ),
        );
        return;
      }
      final cached = await box.get(row.uid);
      if (cached == null) return;
      await box.put(
        row.uid,
        MessageHive.fromModel(
          cached.toModel().copyWith(
            status: MessageStatus.sent.value,
            lastUpdatedAt: syncTimestamp(),
            synced: true,
          ),
        ),
      );
    });
  }

  /// Drops the refused send for the server truth: the refetch runs first, so
  /// a transient refetch failure leaves the queued row in place. A refused
  /// create the server never saw becomes `Failed`, kept: the user's words
  /// stay visible instead of vanishing.
  Future<void> _dropAndRefetchMessage(MessageModel row) async {
    MessageModel? match;
    try {
      match = await _remote.fetchMessage(
        conversationUid: row.conversationUid,
        messageUid: row.uid,
      );
    } on AppError catch (e) {
      // A denied refetch evicts the row; anything else stays queued.
      if (e == AppError.permissionDenied) {
        await _evictMessage(row.uid, 'refetch denied');
      }
      return;
    }
    if (match == null) {
      await _markFailed(row.uid, 'send refused');
      return;
    }
    final found = match;
    // Direct: the merge guard would keep the queued row this replaces. The
    // echo carries no local path; keep ours so a recording still plays.
    return await _guardLazy('dropAndRefetchMessage', (box) async {
      final kept = await box.get(row.uid);
      await box.put(
        row.uid,
        MessageHive.fromModel(
          found.copyWith(
            localAttachmentPath: kept?.localAttachmentPath ?? '',
            synced: true,
          ),
        ),
      );
    });
  }

  Future<void> _markFailed(String messageUid, String reason) async {
    if (kDebugMode) _logger.i('Message $messageUid failed: $reason.');
    return await _guardLazy('markMessageFailed', (box) async {
      final cached = await box.get(messageUid);
      if (cached == null) return;
      await box.put(
        messageUid,
        MessageHive.fromModel(
          cached.toModel().copyWith(
            status: MessageStatus.failed.value,
            lastUpdatedAt: syncTimestamp(),
            synced: true,
          ),
        ),
      );
    });
  }

  Future<void> _evictMessage(String messageUid, String reason) async {
    if (kDebugMode) _logger.i('Evicting message $messageUid: $reason.');
    return await _guardLazy('evictMessage', (box) => box.delete(messageUid));
  }

  Future<MessageModel?> _fresh(String messageUid) => _guardLazy(
    'freshMessage',
    (box) async => (await box.get(messageUid))?.toModel(),
  );

  /// Withdraws online only (the 15-minute window cannot queue), then clears
  /// the local text and transcripts: a withdrawn transcript cannot come back.
  Future<void> withdrawMessage({
    required String conversationUid,
    required String messageUid,
    required String senderUid,
  }) async {
    final cached = await _guardLazy('withdrawMessage', (box) async {
      final row = await box.get(messageUid);
      if (row == null || row.conversationUid != conversationUid) {
        throw AppError.dataNotFound;
      }
      if (row.senderUid != senderUid) throw AppError.permissionDenied;
      return row;
    });
    await _remote.withdrawMessage(
      conversationUid: conversationUid,
      messageUid: messageUid,
    );
    await _guardLazy(
      'withdrawMessage',
      (box) => box.put(
        messageUid,
        MessageHive.fromModel(
          cached.toModel().copyWith(
            text: '',
            status: MessageStatus.withheld.value,
            withheldReason: 'withdrawn',
            lastUpdatedAt: syncTimestamp(),
            synced: true,
          ),
        ),
      ),
    );
    await _db.delete<MessageTranscriptHive>(
      HiveHelperImpl.messageTranscriptsBox,
      '${messageUid}_machine',
    );
    await _db.delete<MessageTranscriptHive>(
      HiveHelperImpl.messageTranscriptsBox,
      '${messageUid}_shared',
    );
    if (cached.localAttachmentPath.isNotEmpty) {
      try {
        await File(cached.localAttachmentPath).delete();
      } on Exception catch (_) {
        // The row is already withdrawn; a leftover file is harmless.
      }
    }
  }

  /// Moves the read cursor forward, locally and remotely; offline it stays
  /// queued. A backward move is a no-op returning the cached cursor.
  Future<ConversationCursorModel> moveCursor(
    String uid,
    String conversationUid,
    String lastReadAt,
  ) async {
    if (uid.isEmpty || conversationUid.isEmpty || lastReadAt.isEmpty) {
      throw ArgumentError('A cursor move needs a member, thread and time.');
    }
    if (!await _isParticipant(uid, conversationUid)) {
      throw AppError.dataNotFound;
    }
    final key = '${conversationUid}_$uid';
    final cached = await _db.get<ConversationCursorHive>(
      HiveHelperImpl.conversationCursorsBox,
      key,
    );
    if (cached != null && lastReadAt.compareTo(cached.lastReadAt) <= 0) {
      return cached.toModel();
    }
    final moved = (cached?.toModel() ?? ConversationCursorModel.empty())
        .copyWith(
          uid: uid,
          conversationUid: conversationUid,
          lastReadAt: lastReadAt,
          lastUpdatedAt: syncTimestamp(),
          synced: false,
        );
    await _db.put<ConversationCursorHive>(
      HiveHelperImpl.conversationCursorsBox,
      key,
      ConversationCursorHive.fromModel(moved),
    );
    try {
      await _remote.updateCursor(
        conversationUid: conversationUid,
        uid: uid,
        lastReadAt: lastReadAt,
      );
    } on AppError catch (e) {
      // Transient (and unknown) errors stay queued for the next flush.
      if (_offline.contains(e)) return moved;
      if (_dropAndRefetch.contains(e)) await _dropAndRefetchCursor(moved);
      rethrow;
    }
    return await _markCursorSynced(key);
  }

  /// The cached read cursor, or null.
  Future<ConversationCursorModel?> getCursor(
    String uid,
    String conversationUid,
  ) async {
    if (!await _isParticipant(uid, conversationUid)) return null;
    return (await _db.get<ConversationCursorHive>(
      HiveHelperImpl.conversationCursorsBox,
      '${conversationUid}_$uid',
    ))?.toModel();
  }

  /// Remote first; the cache answers only when the cloud cannot be reached.
  Future<ConversationCursorModel?> syncCursor(
    String uid,
    String conversationUid,
  ) async {
    if (!await _isParticipant(uid, conversationUid)) {
      throw AppError.dataNotFound;
    }
    try {
      final remote = await _remote.fetchCursor(
        conversationUid: conversationUid,
        uid: uid,
      );
      if (remote != null) await _cacheCursor(remote, fromCloud: true);
      return await getCursor(uid, conversationUid);
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      final cached = await getCursor(uid, conversationUid);
      // Nothing cached is "could not read", never "there is none".
      if (cached == null) rethrow;
      return cached;
    }
  }

  /// Replays every queued cursor in scope; attempts all of them, then
  /// rethrows the first failure, if any.
  Future<void> replayPendingCursors(String uid) async {
    if (uid.isEmpty) return;
    AppError? firstFailure;
    for (final row in await _db.getAll<ConversationCursorHive>(
      HiveHelperImpl.conversationCursorsBox,
    )) {
      if (row.synced || row.uid != uid) continue;
      try {
        await _remote.updateCursor(
          conversationUid: row.conversationUid,
          uid: uid,
          lastReadAt: row.lastReadAt,
        );
      } on AppError catch (e) {
        // Transient (and unknown) errors stay queued for the next flush.
        if (_dropAndRefetch.contains(e)) {
          await _dropAndRefetchCursor(row.toModel());
        }
        firstFailure ??= e;
        continue;
      }
      await _markCursorSynced('${row.conversationUid}_$uid');
    }
    if (firstFailure != null) throw firstFailure;
  }

  /// Caches one cursor: merge-guarded and never moved backward.
  Future<void> _cacheCursor(
    ConversationCursorModel cursor, {
    required bool fromCloud,
  }) async {
    final key = '${cursor.conversationUid}_${cursor.uid}';
    final cached = await _db.get<ConversationCursorHive>(
      HiveHelperImpl.conversationCursorsBox,
      key,
    );
    if (cached != null && cursor.lastReadAt.compareTo(cached.lastReadAt) <= 0) {
      return;
    }
    if (!_accepts(
      fromCloud: fromCloud,
      cached: cached == null
          ? null
          : (synced: cached.synced, lastUpdatedAt: cached.lastUpdatedAt),
      incoming: cursor.lastUpdatedAt,
    )) {
      return;
    }
    await _db.put<ConversationCursorHive>(
      HiveHelperImpl.conversationCursorsBox,
      key,
      ConversationCursorHive.fromModel(
        fromCloud ? cursor.copyWith(synced: true) : cursor,
      ),
    );
  }

  /// Drops the refused cursor move for the server truth: the refetch runs
  /// first, so a transient refetch failure leaves the queued row in place.
  Future<void> _dropAndRefetchCursor(ConversationCursorModel row) async {
    ConversationCursorModel? fresh;
    try {
      fresh = await _remote.fetchCursor(
        conversationUid: row.conversationUid,
        uid: row.uid,
      );
    } on AppError catch (e) {
      // A denied refetch evicts the row; anything else stays queued.
      if (e == AppError.permissionDenied) {
        await _evictCursor(row, 'refetch denied');
      }
      return;
    }
    if (fresh == null) {
      await _evictCursor(row, 'gone server-side');
      return;
    }
    // Direct: server truth wins, even over a queued or newer-looking row.
    await _db.put<ConversationCursorHive>(
      HiveHelperImpl.conversationCursorsBox,
      '${fresh.conversationUid}_${fresh.uid}',
      ConversationCursorHive.fromModel(fresh.copyWith(synced: true)),
    );
  }

  Future<ConversationCursorModel> _markCursorSynced(String key) async {
    final row = await _db.get<ConversationCursorHive>(
      HiveHelperImpl.conversationCursorsBox,
      key,
    );
    // Deleted under us (a concurrent sign-out wipes the boxes): the server
    // already has the cursor, so there is nothing left to do.
    if (row == null) throw AppError.dataNotFound;
    final synced = row.toModel().copyWith(synced: true);
    await _db.put<ConversationCursorHive>(
      HiveHelperImpl.conversationCursorsBox,
      key,
      ConversationCursorHive.fromModel(synced),
    );
    return synced;
  }

  Future<void> _evictCursor(ConversationCursorModel row, String reason) async {
    if (kDebugMode) {
      _logger.i('Evicting cursor ${row.conversationUid}/${row.uid}: $reason.');
    }
    await _db.delete<ConversationCursorHive>(
      HiveHelperImpl.conversationCursorsBox,
      '${row.conversationUid}_${row.uid}',
    );
  }

  /// Caches transcripts: `shared` for every participant, `machine` only for
  /// the sender or a clinician; anything else is skipped, never stored.
  Future<void> cacheTranscripts(
    List<MessageTranscriptModel> transcripts, {
    required bool fromCloud,
    required String viewerUid,
    required Role viewerRole,
  }) async {
    if (viewerUid.isEmpty) return;
    for (final t in transcripts) {
      if (!_mayCacheTranscript(t, viewerUid, viewerRole)) continue;
      await _db.put<MessageTranscriptHive>(
        HiveHelperImpl.messageTranscriptsBox,
        '${t.messageUid}_${t.uid}',
        MessageTranscriptHive.fromModel(
          fromCloud ? t.copyWith(synced: true) : t,
        ),
      );
    }
  }

  /// One cached transcript, under the same rule; null when it may not be
  /// shown to this viewer.
  Future<MessageTranscriptModel?> getTranscript(
    String messageUid,
    String kind,
    String viewerUid,
    Role viewerRole,
  ) async {
    if (messageUid.isEmpty || viewerUid.isEmpty) return null;
    if (kind != 'machine' && kind != 'shared') return null;
    final row = await _db.get<MessageTranscriptHive>(
      HiveHelperImpl.messageTranscriptsBox,
      '${messageUid}_$kind',
    );
    if (row == null) return null;
    if (!await _isParticipant(viewerUid, row.conversationUid)) return null;
    if (!_mayCacheTranscript(row.toModel(), viewerUid, viewerRole)) return null;
    return row.toModel();
  }

  /// `machine` reaches the sender and clinicians (who also hear the audio);
  /// `shared` reaches every participant. Unknown kinds fail closed.
  bool _mayCacheTranscript(
    MessageTranscriptModel t,
    String viewerUid,
    Role viewerRole,
  ) =>
      t.uid == 'shared' ||
      (t.uid == 'machine' &&
          (t.senderUid == viewerUid && viewerUid.isNotEmpty ||
              viewerRole != Role.patient));
}
