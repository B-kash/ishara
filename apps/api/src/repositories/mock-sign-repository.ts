import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import {
  buildSignBrowsePage,
  prepareBrowseSignGraphs,
} from "../data/sign-browse-pagination.js";
import {
  signGraphMatchesBilingualSearch,
  sortSignGraphsBySearchScore,
} from "../data/sign-search-matching.js";
import type {
  BulkSignImportResult,
  SignImportOutcome,
} from "../data/sign-import.js";
import type { Category } from "../db/schema.js";
import {
  buildSignGraphFromFlatInput,
  type SignGraph,
} from "../db/sign-graph.js";
import type { SignBrowsePage } from "../types/sign-browse-page.js";
import type {
  ListSignGraphsPageOptions,
  SignRepository,
} from "./sign-repository.js";

const mockDataDirectory = dirname(fileURLToPath(import.meta.url));
const mockSignsFilePath = join(
  mockDataDirectory,
  "../../../../data/mock-signs.json",
);

interface MockSignJson {
  id: string;
  conceptId: string;
  englishWord: string;
  nepaliWord: string;
  meaningEnglish: string;
  meaningNepali: string;
  category: string;
  videoUrl?: string | null;
  thumbnailUrl?: string | null;
}

function loadMockSignGraphs(): SignGraph[] {
  const rawRecords = JSON.parse(
    readFileSync(mockSignsFilePath, "utf8"),
  ) as MockSignJson[];

  return rawRecords.map((record) =>
    buildSignGraphFromFlatInput({
      signId: record.id,
      conceptId: record.conceptId,
      englishWord: record.englishWord,
      nepaliWord: record.nepaliWord,
      meaningEnglish: record.meaningEnglish,
      meaningNepali: record.meaningNepali,
      categoryName: record.category,
      videoUrl: record.videoUrl ?? null,
      thumbnailUrl: record.thumbnailUrl ?? null,
    }),
  );
}

function buildCategoryRows(signGraphs: SignGraph[]): Category[] {
  const categoriesById = new Map<string, Category>();

  for (const signGraph of signGraphs) {
    categoriesById.set(signGraph.category.id, signGraph.category);
  }

  return [...categoriesById.values()].sort((left, right) =>
    left.name.localeCompare(right.name),
  );
}

export class MockSignRepository implements SignRepository {
  private readonly signGraphs: SignGraph[];

  constructor() {
    this.signGraphs = loadMockSignGraphs();
  }

  async getAllSignGraphs(): Promise<SignGraph[]> {
    return this.signGraphs;
  }

  async listSignGraphsPage(
    options: ListSignGraphsPageOptions,
  ): Promise<SignBrowsePage> {
    const candidatePage = prepareBrowseSignGraphs(this.signGraphs, {
      cursor: options.cursor,
      limit: options.limit,
      letter: options.letter,
      letterLanguage: options.letterLanguage,
    });

    return buildSignBrowsePage(candidatePage, options.limit);
  }

  async getSignGraphById(signId: string): Promise<SignGraph | undefined> {
    return this.signGraphs.find((signGraph) => signGraph.sign.id === signId);
  }

  async searchSignGraphs(searchQuery: string): Promise<SignGraph[]> {
    const matchedGraphs = this.signGraphs.filter((signGraph) =>
      signGraphMatchesBilingualSearch(signGraph, searchQuery),
    );

    return sortSignGraphsBySearchScore(matchedGraphs, searchQuery);
  }

  async getAllCategories(): Promise<Category[]> {
    return buildCategoryRows(this.signGraphs);
  }

  async getCategoryById(categoryId: string): Promise<Category | undefined> {
    return buildCategoryRows(this.signGraphs).find(
      (category) => category.id === categoryId,
    );
  }

  async getSignGraphsByCategoryId(
    categoryId: string,
  ): Promise<SignGraph[] | undefined> {
    const category = await this.getCategoryById(categoryId);
    if (!category) {
      return undefined;
    }

    return this.signGraphs.filter(
      (signGraph) => signGraph.category.id === categoryId,
    );
  }

  async importSignRecord(_rawRecord: unknown): Promise<SignImportOutcome> {
    throw new Error("Mock data source does not support admin imports.");
  }

  async bulkImportSignRecords(_rawRecords: unknown[]): Promise<BulkSignImportResult> {
    throw new Error("Mock data source does not support admin imports.");
  }

  async close(): Promise<void> {
    // No resources to release for mock data.
  }
}
