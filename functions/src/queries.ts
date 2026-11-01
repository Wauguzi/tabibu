/**
 * Firestore query registry (plan §5.3). Every Cloud Functions query is built
 * through [buildQuery] so the index check can see it.
 */
import type {
  Firestore,
  Query,
  WhereFilterOp,
} from 'firebase-admin/firestore';

export type QueryFilterOp = WhereFilterOp;

export interface QueryFilter {
  field: string;
  op: QueryFilterOp;
}

export interface QueryOrder {
  field: string;
  direction: 'asc' | 'desc';
}

export interface QueryEntry {
  id: string;
  collection: string;
  scope: 'collection' | 'collectionGroup';
  filters: QueryFilter[];
  orderBy: QueryOrder[];
}

/**
 * Queries identity handlers run today. New domains append here; leave
 * [futureQuerySlots] as the typed place for the reviewer to fill.
 */
export const queryRegistry: QueryEntry[] = [
  {
    id: 'patients.byPhoneAndDob',
    collection: 'patients',
    scope: 'collection',
    filters: [
      { field: 'phoneNumber', op: '==' },
      { field: 'dateOfBirth', op: '==' },
    ],
    orderBy: [],
  },
  {
    id: 'patients.byUid',
    collection: 'patients',
    scope: 'collection',
    filters: [{ field: 'uid', op: '==' }],
    orderBy: [],
  },
  {
    id: 'doctors.byKmpdcNumber',
    collection: 'doctors',
    scope: 'collection',
    filters: [{ field: 'kmpdcNumber', op: '==' }],
    orderBy: [],
  },
];

/** Typed slots for domains the reviewer adds later. Keep empty until then. */
export const futureQuerySlots: QueryEntry[] = [];

export function queryById(id: string): QueryEntry {
  const entry = [...queryRegistry, ...futureQuerySlots].find((q) => q.id === id);
  if (!entry) throw new Error(`Unknown query id: ${id}`);
  return entry;
}

/**
 * Builds a Firestore [Query] from a registry entry and one value per filter,
 * in filter order.
 */
export function buildQuery(
  db: Firestore,
  entry: QueryEntry,
  values: unknown[],
): Query {
  if (values.length !== entry.filters.length) {
    throw new Error(
      `Query ${entry.id}: expected ${entry.filters.length} values, got ${values.length}`,
    );
  }
  let q: Query =
    entry.scope === 'collectionGroup'
      ? db.collectionGroup(entry.collection)
      : db.collection(entry.collection);
  entry.filters.forEach((filter, i) => {
    q = q.where(filter.field, filter.op, values[i]);
  });
  for (const order of entry.orderBy) {
    q = q.orderBy(order.field, order.direction);
  }
  return q;
}
