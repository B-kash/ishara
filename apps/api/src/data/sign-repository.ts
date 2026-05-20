import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import type { SignRecord } from "../types/sign-record.js";

const repositoryDirectory = dirname(fileURLToPath(import.meta.url));
const mockSignsFilePath = join(
  repositoryDirectory,
  "../../../../data/mock-signs.json",
);

const signRecords: SignRecord[] = JSON.parse(
  readFileSync(mockSignsFilePath, "utf8"),
) as SignRecord[];

export function getAllSignRecords(): SignRecord[] {
  return signRecords;
}

export function getSignById(signId: string): SignRecord | undefined {
  return signRecords.find((sign) => sign.id === signId);
}
