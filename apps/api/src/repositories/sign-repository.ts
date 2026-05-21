import type { Category } from "../types/api-responses.js";
import type { SignBrowsePage } from "../types/sign-browse-page.js";
import type { SearchLanguageCode, SignRecord } from "../types/sign-record.js";

export interface ListSignRecordsPageOptions {
  cursor?: string;
  limit: number;
  letter?: string;
  letterLanguage?: SearchLanguageCode;
}

export interface SignRepository {
  getAllSignRecords(): Promise<SignRecord[]>;
  listSignRecordsPage(
    options: ListSignRecordsPageOptions,
  ): Promise<SignBrowsePage>;
  getSignById(signId: string): Promise<SignRecord | undefined>;
  searchSignRecords(searchQuery: string): Promise<SignRecord[]>;
  getAllCategories(): Promise<Category[]>;
  getCategoryById(categoryId: string): Promise<Category | undefined>;
  getSignRecordsByCategoryId(
    categoryId: string,
  ): Promise<SignRecord[] | undefined>;
  close(): Promise<void>;
}
