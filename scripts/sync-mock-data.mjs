import { copyFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const repositoryRoot = join(dirname(fileURLToPath(import.meta.url)), "..");
const sourcePath = join(repositoryRoot, "data", "mock-signs.json");
const targetDirectory = join(
  repositoryRoot,
  "apps",
  "mobile",
  "assets",
  "data",
);
const targetPath = join(targetDirectory, "mock-signs.json");

mkdirSync(targetDirectory, { recursive: true });
copyFileSync(sourcePath, targetPath);

console.log("Synced mock sign data to apps/mobile/assets/data/mock-signs.json");
