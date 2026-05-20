import type { Category } from "../types/api-responses.js";
import type { SignRecord } from "../types/sign-record.js";
import { categoryNameToId } from "./category-slug.js";
import { getAllSignRecords } from "./sign-repository.js";

function buildCategoryList(signRecords: SignRecord[]): Category[] {
  const uniqueNames = [
    ...new Set(signRecords.map((sign) => sign.category)),
  ].sort();

  return uniqueNames.map((categoryName) => ({
    id: categoryNameToId(categoryName),
    name: categoryName,
  }));
}

export function getAllCategories(): Category[] {
  return buildCategoryList(getAllSignRecords());
}

export function getCategoryById(categoryId: string): Category | undefined {
  return getAllCategories().find((category) => category.id === categoryId);
}

export function getSignRecordsByCategoryId(
  categoryId: string,
): SignRecord[] | undefined {
  const category = getCategoryById(categoryId);
  if (!category) {
    return undefined;
  }

  return getAllSignRecords().filter(
    (sign) => sign.category === category.name,
  );
}
