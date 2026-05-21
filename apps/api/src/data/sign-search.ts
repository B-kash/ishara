import type { SearchLanguageCode } from "../types/sign-record.js";

export function parseSearchLanguage(
  languageInput: string | undefined,
): SearchLanguageCode | null {
  const normalizedLanguage = languageInput?.trim().toLowerCase();
  if (normalizedLanguage === "en" || normalizedLanguage === "english") {
    return "en";
  }
  if (normalizedLanguage === "ne" || normalizedLanguage === "nepali") {
    return "ne";
  }
  return null;
}
