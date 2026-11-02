// cspell:ignore Januari Februari Machi Aprili Juni Julai Agosti Septemba Oktoba Novemba Desemba
// cspell:ignore langu naitwa kitambulisho NHIF nhif Deidentify deidentify
/**
 * Strip identifiers from free text before it reaches a model (S-5).
 * Placeholders keep structure without leaking the original token.
 */
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import { DATA_DIR } from './reference-data';

export interface DeidentifySubject {
  firstName?: string;
  middleName?: string;
  lastName?: string;
  phoneNumber?: string;
  email?: string;
  dateOfBirth?: string;
  county?: string;
  subCounty?: string;
  nationalId?: string;
  facilityName?: string;
  orderNumber?: string;
  labAccessionNo?: string;
  /** Record ids (case, patient, doctor) the notes might quote. */
  ids?: string[];
}

const EMAIL = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/g;

/** Kenyan mobiles and landlines with optional spaces/dashes. */
const PHONE =
  /(?:\+?254|0)\s*[17](?:[\s\-]*\d){8}|(?:\+?254|0)\s*20(?:[\s\-]*\d){6,7}|\b0[17]\d(?:[\s\-]?\d){7}\b/g;

const ISO_DATE = /\b(?:19|20)\d{2}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\d|3[01])\b/g;
const SLASH_DATE = /\b(?:0?[1-9]|[12]\d|3[01])[/.-](?:0?[1-9]|1[0-2])[/.-](?:19|20)?\d{2}\b/g;

const EN_MONTHS =
  'January|February|March|April|May|June|July|August|September|October|November|December|Jan|Feb|Mar|Apr|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec';
const SW_MONTHS =
  'Januari|Februari|Machi|Aprili|Mei|Juni|Julai|Agosti|Septemba|Oktoba|Novemba|Desemba';
const MONTH_DATE = new RegExp(
  String.raw`\b(?:tarehe\s+)?(?:0?[1-9]|[12]\d|3[01])\s+(?:${EN_MONTHS}|${SW_MONTHS})\s+(?:19|20)?\d{2}\b`,
  'gi',
);

const INTRO =
  /(?:my name is|i am|i'm|jina langu ni|naitwa|mimi ni)\s+([A-ZÀ-ÖØ-Ý][\p{L}'-]*(?:\s+[A-ZÀ-ÖØ-Ý][\p{L}']*){0,2})/giu;

const ID_NEAR =
  /(?:\b(?:ID|id|kitambulisho|NHIF|nhif|SHA|sha)\b[\s:#-]*)(\d{7,8})\b/g;

const ORDER_NO = /\b(?:ODR|TBB)-(?:[A-Z]{1,6}-){0,2}\d{8}-\d{2,6}\b/gi;

function escapeRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

/** Whole-word, case-insensitive replace; skips tokens shorter than 2 chars. */
function replaceWord(text: string, value: string, placeholder: string): string {
  const trimmed = value.trim();
  if (trimmed.length < 2) return text;
  const re = new RegExp(
    `(?<![\\p{L}\\p{N}])${escapeRegExp(trimmed)}(?![\\p{L}\\p{N}])`,
    'giu',
  );
  return text.replace(re, placeholder);
}

let cachedFacilities: string[] | null = null;

function facilities(): string[] {
  if (!cachedFacilities) {
    const rows = JSON.parse(
      readFileSync(join(DATA_DIR, 'facilities_nairobi.json'), 'utf8'),
    ) as { name: string }[];
    cachedFacilities = rows.map((r) => r.name).filter((n) => n.length >= 2);
  }
  return cachedFacilities;
}

/**
 * Replace identifiers with placeholders. Doses and durations are left alone.
 */
export function deidentify(text: string, subject: DeidentifySubject = {}): string {
  let out = text;

  out = replaceWord(out, subject.firstName ?? '', '[NAME]');
  out = replaceWord(out, subject.middleName ?? '', '[NAME]');
  out = replaceWord(out, subject.lastName ?? '', '[NAME]');
  out = replaceWord(out, subject.phoneNumber ?? '', '[PHONE]');
  out = replaceWord(out, subject.email ?? '', '[EMAIL]');
  out = replaceWord(out, subject.nationalId ?? '', '[ID]');
  out = replaceWord(out, subject.facilityName ?? '', '[FACILITY]');
  out = replaceWord(out, subject.subCounty ?? '', '[AREA]');
  out = replaceWord(out, subject.county ?? '', '[AREA]');
  out = replaceWord(out, subject.orderNumber ?? '', '[ORDER]');
  out = replaceWord(out, subject.labAccessionNo ?? '', '[ACCESSION]');
  for (const id of subject.ids ?? []) out = replaceWord(out, id, '[ID]');

  if (subject.dateOfBirth) {
    out = replaceWord(out, subject.dateOfBirth, '[DOB]');
  }

  for (const name of facilities()) {
    out = replaceWord(out, name, '[FACILITY]');
  }

  out = out.replace(INTRO, '[NAME]');
  out = out.replace(EMAIL, '[EMAIL]');
  out = out.replace(PHONE, '[PHONE]');
  out = out.replace(ORDER_NO, '[ORDER]');
  out = out.replace(ID_NEAR, '[ID]');

  out = out.replace(MONTH_DATE, '[DATE]');
  out = out.replace(SLASH_DATE, '[DATE]');
  out = out.replace(ISO_DATE, (match) =>
    subject.dateOfBirth && match === subject.dateOfBirth ? '[DOB]' : '[DATE]',
  );

  return out;
}
