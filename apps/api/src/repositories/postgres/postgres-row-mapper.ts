import type { SignRecord } from "../../types/sign-record.js";

export interface SignRecordRow {
  id: string;
  concept_id: string;
  english_word: string;
  nepali_word: string;
  meaning_english: string;
  meaning_nepali: string;
  category: string;
  video_url: string | null;
}

export function mapRowToSignRecord(row: SignRecordRow): SignRecord {
  return {
    id: row.id,
    conceptId: row.concept_id,
    englishWord: row.english_word,
    nepaliWord: row.nepali_word,
    meaningEnglish: row.meaning_english,
    meaningNepali: row.meaning_nepali,
    category: row.category,
    videoUrl: row.video_url,
  };
}

export const signRecordSelectSql = `
  select
    signs.id as id,
    concepts.id as concept_id,
    english_words.word as english_word,
    nepali_words.word as nepali_word,
    concepts.meaning_english as meaning_english,
    concepts.meaning_nepali as meaning_nepali,
    categories.name as category,
    signs.video_url as video_url
  from signs
  join concepts on concepts.id = signs.concept_id
  join categories on categories.id = concepts.category_id
  join words english_words
    on english_words.concept_id = concepts.id
    and english_words.language = 'en'
  join words nepali_words
    on nepali_words.concept_id = concepts.id
    and nepali_words.language = 'ne'
`;
