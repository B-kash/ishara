import { parseSearchLanguage } from "../data/sign-search.js";
import type { SearchLanguageCode } from "../types/sign-record.js";

export interface ValidationSuccess<T> {
  ok: true;
  value: T;
}

export interface ValidationFailure {
  ok: false;
  message: string;
}

export type ValidationResult<T> = ValidationSuccess<T> | ValidationFailure;

function validationFailure(message: string): ValidationFailure {
  return { ok: false, message };
}

export function validateRequiredQueryParam(
  value: string | undefined,
  paramName: string,
): ValidationResult<string> {
  const trimmedValue = value?.trim();
  if (!trimmedValue) {
    return validationFailure(`Query parameter ${paramName} is required`);
  }

  return { ok: true, value: trimmedValue };
}

export function validateSearchLanguageParam(
  languageInput: string | undefined,
): ValidationResult<SearchLanguageCode> {
  const searchLanguage = parseSearchLanguage(languageInput);
  if (!searchLanguage) {
    return validationFailure('Query parameter lang must be "en" or "ne"');
  }

  return { ok: true, value: searchLanguage };
}

/** URL path ids are slugs (e.g. hello, thank-you, family). Not used inside SQL text. */
const slugIdPattern = /^[a-z0-9-]+$/;

export const DEFAULT_PAGE_LIMIT = 20;
export const MAX_PAGE_LIMIT = 100;

export function validateOptionalCursor(
  cursorInput: string | undefined,
): ValidationResult<string | undefined> {
  const trimmedCursor = cursorInput?.trim();
  if (!trimmedCursor) {
    return { ok: true, value: undefined };
  }

  if (!slugIdPattern.test(trimmedCursor)) {
    return validationFailure("Query parameter cursor is invalid");
  }

  return { ok: true, value: trimmedCursor };
}

export function validatePageLimit(
  limitInput: string | undefined,
): ValidationResult<number> {
  if (!limitInput?.trim()) {
    return { ok: true, value: DEFAULT_PAGE_LIMIT };
  }

  const parsedLimit = Number.parseInt(limitInput, 10);
  if (
    !Number.isInteger(parsedLimit) ||
    parsedLimit < 1 ||
    parsedLimit > MAX_PAGE_LIMIT
  ) {
    return validationFailure(
      `Query parameter limit must be between 1 and ${MAX_PAGE_LIMIT}`,
    );
  }

  return { ok: true, value: parsedLimit };
}

export function validateRouteId(
  routeId: string | undefined,
  resourceName: string,
): ValidationResult<string> {
  const trimmedId = routeId?.trim();
  if (!trimmedId) {
    return validationFailure(`${resourceName} id is required`);
  }

  if (!slugIdPattern.test(trimmedId)) {
    return validationFailure(`${resourceName} id is invalid`);
  }

  return { ok: true, value: trimmedId };
}
