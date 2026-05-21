import { categoryNameToId } from "./category-slug.js";

export const signImportRequiredFields = [
  "id",
  "conceptId",
  "englishWord",
  "nepaliWord",
  "meaningEnglish",
  "meaningNepali",
  "category",
] as const;

export type SignImportFieldName = (typeof signImportRequiredFields)[number];

export interface NormalizedSignImportRecord {
  signId: string;
  conceptId: string;
  englishWord: string;
  nepaliWord: string;
  meaningEnglish: string;
  meaningNepali: string;
  categoryName: string;
  categoryId: string;
  videoUrl: string | null;
  thumbnailUrl: string | null;
}

export type SignImportOutcomeStatus = "inserted" | "skipped";

export interface SignImportOutcome {
  status: SignImportOutcomeStatus;
  signId: string;
  message?: string;
}

export interface BulkSignImportResult {
  inserted: number;
  skipped: number;
  failed: number;
  outcomes: SignImportOutcome[];
  errors: string[];
}

function readStringField(
  record: Record<string, unknown>,
  fieldName: string,
  recordLabel: string,
): string {
  const fieldValue = record[fieldName];
  if (typeof fieldValue !== "string" || !fieldValue.trim()) {
    throw new Error(`${recordLabel}: "${fieldName}" is required.`);
  }

  return fieldValue.trim();
}

function readOptionalUrlField(
  record: Record<string, unknown>,
  fieldName: string,
  recordLabel: string,
): string | null {
  const fieldValue = record[fieldName];
  if (fieldValue == null || fieldValue === "") {
    return null;
  }

  if (typeof fieldValue !== "string") {
    throw new Error(`${recordLabel}: "${fieldName}" must be a string or null.`);
  }

  const trimmedValue = fieldValue.trim();
  return trimmedValue.length > 0 ? trimmedValue : null;
}

export function normalizeSignImportRecord(
  rawRecord: unknown,
  recordIndex: number,
): NormalizedSignImportRecord {
  const recordLabel = `Record ${recordIndex + 1}`;

  if (!rawRecord || typeof rawRecord !== "object") {
    throw new Error(`${recordLabel}: must be an object.`);
  }

  const record = rawRecord as Record<string, unknown>;
  const categoryName = readStringField(record, "category", recordLabel);

  return {
    signId: readStringField(record, "id", recordLabel),
    conceptId: readStringField(record, "conceptId", recordLabel),
    englishWord: readStringField(record, "englishWord", recordLabel).toLowerCase(),
    nepaliWord: readStringField(record, "nepaliWord", recordLabel),
    meaningEnglish: readStringField(record, "meaningEnglish", recordLabel),
    meaningNepali: readStringField(record, "meaningNepali", recordLabel),
    categoryName,
    categoryId: categoryNameToId(categoryName),
    videoUrl: readOptionalUrlField(record, "videoUrl", recordLabel),
    thumbnailUrl: readOptionalUrlField(record, "thumbnailUrl", recordLabel),
  };
}

export function validateNoDuplicateSignIdsInBatch(
  normalizedRecords: NormalizedSignImportRecord[],
): void {
  const signIds = new Set<string>();
  const conceptIds = new Set<string>();

  for (const record of normalizedRecords) {
    if (signIds.has(record.signId)) {
      throw new Error(`Duplicate sign id in batch: "${record.signId}".`);
    }
    signIds.add(record.signId);

    if (conceptIds.has(record.conceptId)) {
      throw new Error(`Duplicate concept id in batch: "${record.conceptId}".`);
    }
    conceptIds.add(record.conceptId);
  }
}

export function buildConceptIdFromSignId(signId: string): string {
  return `concept-${signId}`;
}
