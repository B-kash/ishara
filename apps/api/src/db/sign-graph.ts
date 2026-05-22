import { categoryNameToId } from "../data/category-slug.js";
import type { Category, Concept, Sign, Word } from "./schema.js";

/**
 * One sign plus its related rows from other tables.
 * Not a database table — only groups rows that already exist in categories, concepts, words, signs.
 */
export interface SignGraph {
  sign: Sign;
  concept: Concept;
  category: Category;
  englishWord: Word;
  nepaliWord: Word;
}

const mockTimestamp = new Date(0);

export interface FlatSignInput {
  signId: string;
  conceptId: string;
  englishWord: string;
  nepaliWord: string;
  meaningEnglish: string;
  meaningNepali: string;
  categoryName: string;
  videoUrl?: string | null;
  thumbnailUrl?: string | null;
}

/** Builds table-shaped rows from mock JSON or import payloads (explicit field assignment). */
export function buildSignGraphFromFlatInput(input: FlatSignInput): SignGraph {
  const categoryId = categoryNameToId(input.categoryName);

  const category: Category = {
    id: categoryId,
    name: input.categoryName,
    createdAt: mockTimestamp,
    updatedAt: mockTimestamp,
  };

  const concept: Concept = {
    id: input.conceptId,
    categoryId,
    meaningEnglish: input.meaningEnglish,
    meaningNepali: input.meaningNepali,
    createdAt: mockTimestamp,
    updatedAt: mockTimestamp,
  };

  const sign: Sign = {
    id: input.signId,
    conceptId: input.conceptId,
    videoUrl: input.videoUrl ?? null,
    thumbnailUrl: input.thumbnailUrl ?? null,
    createdAt: mockTimestamp,
    updatedAt: mockTimestamp,
  };

  const englishWord: Word = {
    id: `${input.conceptId}-en`,
    conceptId: input.conceptId,
    language: "en",
    word: input.englishWord.toLowerCase(),
    createdAt: mockTimestamp,
    updatedAt: mockTimestamp,
  };

  const nepaliWord: Word = {
    id: `${input.conceptId}-ne`,
    conceptId: input.conceptId,
    language: "ne",
    word: input.nepaliWord,
    createdAt: mockTimestamp,
    updatedAt: mockTimestamp,
  };

  return { sign, concept, category, englishWord, nepaliWord };
}

type SignQueryRow = Sign & {
  concept: Concept & {
    category: Category;
    words: Word[];
  };
};

/** Groups Drizzle relational query result into separate table rows. */
export function signGraphFromQueryRow(row: SignQueryRow): SignGraph {
  const englishWord = row.concept.words.find((word) => word.language === "en");
  const nepaliWord = row.concept.words.find((word) => word.language === "ne");

  if (!englishWord || !nepaliWord) {
    throw new Error(`Sign "${row.id}" is missing English or Nepali word rows.`);
  }

  return {
    sign: {
      id: row.id,
      conceptId: row.conceptId,
      videoUrl: row.videoUrl,
      thumbnailUrl: row.thumbnailUrl,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    },
    concept: {
      id: row.concept.id,
      categoryId: row.concept.categoryId,
      meaningEnglish: row.concept.meaningEnglish,
      meaningNepali: row.concept.meaningNepali,
      createdAt: row.concept.createdAt,
      updatedAt: row.concept.updatedAt,
    },
    category: row.concept.category,
    englishWord,
    nepaliWord,
  };
}
