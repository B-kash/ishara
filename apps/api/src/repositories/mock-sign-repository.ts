import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import type { Category } from "../types/api-responses.js";
import { categoryNameToId } from "../data/category-slug.js";
import type { SearchLanguageCode, SignRecord } from "../types/sign-record.js";
import type { SignRepository } from "./sign-repository.js";

const mockDataDirectory = dirname(fileURLToPath(import.meta.url));
const mockSignsFilePath = join(
  mockDataDirectory,
  "../../../../data/mock-signs.json",
);

function loadMockSignRecords(): SignRecord[] {
  return JSON.parse(readFileSync(mockSignsFilePath, "utf8")) as SignRecord[];
}

function buildCategoryList(signRecords: SignRecord[]): Category[] {
  const uniqueNames = [
    ...new Set(signRecords.map((sign) => sign.category)),
  ].sort();

  return uniqueNames.map((categoryName) => ({
    id: categoryNameToId(categoryName),
    name: categoryName,
  }));
}

export class MockSignRepository implements SignRepository {
  private readonly signRecords: SignRecord[];

  constructor() {
    this.signRecords = loadMockSignRecords();
  }

  async getAllSignRecords(): Promise<SignRecord[]> {
    return this.signRecords;
  }

  async getSignById(signId: string): Promise<SignRecord | undefined> {
    return this.signRecords.find((sign) => sign.id === signId);
  }

  async searchSignRecords(
    searchQuery: string,
    language: SearchLanguageCode,
  ): Promise<SignRecord[]> {
    const normalizedQuery = searchQuery.trim().toLowerCase();
    if (!normalizedQuery) {
      return [];
    }

    return this.signRecords.filter((sign) => {
      const wordText =
        language === "en"
          ? sign.englishWord.toLowerCase()
          : sign.nepaliWord.toLowerCase();
      return wordText.includes(normalizedQuery);
    });
  }

  async getAllCategories(): Promise<Category[]> {
    return buildCategoryList(this.signRecords);
  }

  async getCategoryById(categoryId: string): Promise<Category | undefined> {
    const categories = buildCategoryList(this.signRecords);
    return categories.find((category) => category.id === categoryId);
  }

  async getSignRecordsByCategoryId(
    categoryId: string,
  ): Promise<SignRecord[] | undefined> {
    const category = await this.getCategoryById(categoryId);
    if (!category) {
      return undefined;
    }

    return this.signRecords.filter((sign) => sign.category === category.name);
  }

  async close(): Promise<void> {
    // No resources to release for mock data.
  }
}
