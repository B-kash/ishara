export function categoryNameToId(categoryName: string): string {
  return categoryName
    .toLowerCase()
    .replace(/ & /g, "-")
    .replace(/\s+/g, "-");
}
