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

export function validateRouteId(
  routeId: string | undefined,
  resourceName: string,
): ValidationResult<string> {
  const trimmedId = routeId?.trim();
  if (!trimmedId) {
    return validationFailure(`${resourceName} id is required`);
  }

  return { ok: true, value: trimmedId };
}
