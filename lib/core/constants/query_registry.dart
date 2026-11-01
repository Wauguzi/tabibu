/// App-side Firestore queries used by feature data sources (plan §5.3).
///
/// Each entry must match a composite index in `firestore.indexes.json` or be
/// equality-only. The deploy-time smoke harness walks this list.
library;

/// One registered query shape.
class QuerySpec {
  const QuerySpec({
    required this.id,
    required this.collection,
    required this.filters,
    this.orderBy = const <String>[],
    this.scope = 'collection',
  });

  final String id;
  final String collection;
  final List<String> filters;
  final List<String> orderBy;
  final String scope;
}

/// Queries issued by the step-4 notification, appointment, conversation and
/// alert data sources.
const queryRegistry = <QuerySpec>[
  QuerySpec(
    id: 'notifications.inboxDelta',
    collection: 'notifications',
    filters: ['recipientUid ==', 'lastUpdatedAt >='],
    orderBy: ['lastUpdatedAt ASC'],
  ),
  QuerySpec(
    id: 'appointments.patientDelta',
    collection: 'appointments',
    filters: ['patientUid ==', 'lastUpdatedAt >='],
    orderBy: ['lastUpdatedAt ASC'],
  ),
  QuerySpec(
    id: 'appointments.doctorDelta',
    collection: 'appointments',
    filters: ['doctorUid ==', 'lastUpdatedAt >='],
    orderBy: ['lastUpdatedAt ASC'],
  ),
  QuerySpec(
    id: 'conversations.participantDelta',
    collection: 'conversations',
    filters: ['participantUids array-contains', 'lastUpdatedAt >='],
    orderBy: ['lastUpdatedAt ASC'],
  ),
  QuerySpec(
    id: 'conversations.firstPage',
    collection: 'conversations',
    filters: ['participantUids array-contains'],
    orderBy: ['lastMessageAt DESC'],
  ),
  QuerySpec(
    id: 'conversations.messagesBySentAt',
    collection: 'messages',
    scope: 'nested',
    filters: <String>[],
    orderBy: ['sentAt ASC'],
  ),
  QuerySpec(
    id: 'publicAlerts.patientDelta',
    collection: 'publicAlerts',
    filters: ['countyId ==', 'patientsReleased ==', 'lastUpdatedAt >='],
    orderBy: ['lastUpdatedAt ASC'],
  ),
  QuerySpec(
    id: 'publicAlerts.clinicianDelta',
    collection: 'publicAlerts',
    filters: ['clinicianCountyIds array-contains', 'lastUpdatedAt >='],
    orderBy: ['lastUpdatedAt ASC'],
  ),
];
