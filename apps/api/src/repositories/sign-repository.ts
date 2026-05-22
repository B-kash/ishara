import type { Category } from "../db/schema.js";
import type { SignGraph } from "../db/sign-graph.js";
import type { SignBrowsePage } from "../types/sign-browse-page.js";
import type { SearchLanguageCode } from "../types/search-language.js";
import type {
  BulkSignImportResult,
  SignImportOutcome,
} from "../data/sign-import.js";

export interface ListSignGraphsPageOptions {
  cursor?: string;
  limit: number;
  letter?: string;
  letterLanguage?: SearchLanguageCode;
}

export interface SignRepository {
  getAllSignGraphs(): Promise<SignGraph[]>;
  listSignGraphsPage(options: ListSignGraphsPageOptions): Promise<SignBrowsePage>;
  getSignGraphById(signId: string): Promise<SignGraph | undefined>;
  searchSignGraphs(searchQuery: string): Promise<SignGraph[]>;
  getAllCategories(): Promise<Category[]>;
  getCategoryById(categoryId: string): Promise<Category | undefined>;
  getSignGraphsByCategoryId(
    categoryId: string,
  ): Promise<SignGraph[] | undefined>;
  importSignRecord(rawRecord: unknown): Promise<SignImportOutcome>;
  bulkImportSignRecords(rawRecords: unknown[]): Promise<BulkSignImportResult>;
  close(): Promise<void>;
}
