import type { SearchLanguageCode, SignRecord } from "../types/sign-record.js";
import type { SignDetail, SignSearchResult } from "../types/api-responses.js";

function formatEnglishWord(englishWord: string): string {
  return englishWord.toLowerCase();
}

function pickMeaning(
  signRecord: SignRecord,
  language: SearchLanguageCode,
): string {
  return language === "en"
    ? signRecord.meaningEnglish
    : signRecord.meaningNepali;
}

export function toSignSearchResult(
  signRecord: SignRecord,
  language: SearchLanguageCode,
): SignSearchResult {
  return {
    id: signRecord.id,
    englishWord: formatEnglishWord(signRecord.englishWord),
    nepaliWord: signRecord.nepaliWord,
    category: signRecord.category,
    meaning: pickMeaning(signRecord, language),
  };
}

export function toSignDetail(signRecord: SignRecord): SignDetail {
  return {
    id: signRecord.id,
    englishWord: formatEnglishWord(signRecord.englishWord),
    nepaliWord: signRecord.nepaliWord,
    category: signRecord.category,
    meaning: signRecord.meaningEnglish,
    videoUrl: signRecord.videoUrl,
    thumbnailUrl: signRecord.thumbnailUrl,
    videoDurationSeconds: null,
  };
}
