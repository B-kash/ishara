import type { Category } from "../types/api-responses.js";
import type { SearchLanguageCode, SignRecord } from "../types/sign-record.js";

export interface SignRepository {
  getAllSignRecords(): Promise<SignRecord[]>;
  getSignById(signId: string): Promise<SignRecord | undefined>;
  searchSignRecords(searchQuery: string): Promise<SignRecord[]>;
  getAllCategories(): Promise<Category[]>;
  getCategoryById(categoryId: string): Promise<Category | undefined>;
  getSignRecordsByCategoryId(
    categoryId: string,
  ): Promise<SignRecord[] | undefined>;
  close(): Promise<void>;
}
