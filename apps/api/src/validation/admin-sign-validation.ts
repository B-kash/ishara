import { buildConceptIdFromSignId } from "../data/sign-import.js";

export type ValidationResult<T> =
  | { ok: true; value: T }
  | { ok: false; message: string };

export interface CreateSignRequestBody {
  signId: string;
  conceptId: string;
  englishWord: string;
  nepaliWord: string;
  meaningEnglish: string;
  meaningNepali: string;
  category: string;
  videoUrl: string | null;
  thumbnailUrl: string | null;
}

function readRequiredString(
  body: Record<string, unknown>,
  fieldName: string,
): ValidationResult<string> {
  const fieldValue = body[fieldName];
  if (typeof fieldValue !== "string" || !fieldValue.trim()) {
    return { ok: false, message: `"${fieldName}" is required.` };
  }

  return { ok: true, value: fieldValue.trim() };
}

function readOptionalUrl(
  body: Record<string, unknown>,
  fieldName: string,
): ValidationResult<string | null> {
  const fieldValue = body[fieldName];
  if (fieldValue == null || fieldValue === "") {
    return { ok: true, value: null };
  }

  if (typeof fieldValue !== "string") {
    return { ok: false, message: `"${fieldName}" must be a string or null.` };
  }

  const trimmedValue = fieldValue.trim();
  return { ok: true, value: trimmedValue.length > 0 ? trimmedValue : null };
}

export function validateCreateSignRequestBody(
  body: unknown,
): ValidationResult<CreateSignRequestBody> {
  if (!body || typeof body !== "object") {
    return { ok: false, message: "Request body must be a JSON object." };
  }

  const record = body as Record<string, unknown>;

  const signIdResult = readRequiredString(record, "signId");
  if (!signIdResult.ok) {
    return signIdResult;
  }

  const englishWordResult = readRequiredString(record, "englishWord");
  if (!englishWordResult.ok) {
    return englishWordResult;
  }

  const nepaliWordResult = readRequiredString(record, "nepaliWord");
  if (!nepaliWordResult.ok) {
    return nepaliWordResult;
  }

  const meaningEnglishResult = readRequiredString(record, "meaningEnglish");
  if (!meaningEnglishResult.ok) {
    return meaningEnglishResult;
  }

  const meaningNepaliResult = readRequiredString(record, "meaningNepali");
  if (!meaningNepaliResult.ok) {
    return meaningNepaliResult;
  }

  const categoryResult = readRequiredString(record, "category");
  if (!categoryResult.ok) {
    return categoryResult;
  }

  const videoUrlResult = readOptionalUrl(record, "videoUrl");
  if (!videoUrlResult.ok) {
    return videoUrlResult;
  }

  const thumbnailUrlResult = readOptionalUrl(record, "thumbnailUrl");
  if (!thumbnailUrlResult.ok) {
    return thumbnailUrlResult;
  }

  let conceptId = "";
  if (typeof record.conceptId === "string" && record.conceptId.trim()) {
    conceptId = record.conceptId.trim();
  } else {
    conceptId = buildConceptIdFromSignId(signIdResult.value);
  }

  return {
    ok: true,
    value: {
      signId: signIdResult.value,
      conceptId,
      englishWord: englishWordResult.value,
      nepaliWord: nepaliWordResult.value,
      meaningEnglish: meaningEnglishResult.value,
      meaningNepali: meaningNepaliResult.value,
      category: categoryResult.value,
      videoUrl: videoUrlResult.value,
      thumbnailUrl: thumbnailUrlResult.value,
    },
  };
}

export function createSignBodyToImportRecord(body: CreateSignRequestBody) {
  return {
    id: body.signId,
    conceptId: body.conceptId,
    englishWord: body.englishWord,
    nepaliWord: body.nepaliWord,
    meaningEnglish: body.meaningEnglish,
    meaningNepali: body.meaningNepali,
    category: body.category,
    videoUrl: body.videoUrl,
    thumbnailUrl: body.thumbnailUrl,
  };
}
