import { readdirSync } from "node:fs";
import { join } from "node:path";
import { createPool, readSqlFile, repositoryRoot } from "./db-utils.mjs";

const seedsDirectory = join(repositoryRoot, "supabase", "seeds");

const clearDictionaryDataSql = `
  truncate table signs, words, concepts, categories cascade;
`;

function listSeedFiles() {
  try {
    return readdirSync(seedsDirectory)
      .filter((fileName) => fileName.endsWith(".sql"))
      .sort();
  } catch (error) {
    if (error.code === "ENOENT") {
      return [];
    }
    throw error;
  }
}

function getSeedTargets() {
  const seedFiles = listSeedFiles();
  if (seedFiles.length > 0) {
    return seedFiles.map((fileName) => ({
      name: fileName,
      relativePath: `supabase/seeds/${fileName}`,
    }));
  }

  return [
    {
      name: "seed.sql",
      relativePath: "supabase/seed.sql",
    },
  ];
}

async function runSeeds() {
  const pool = createPool();
  const seedTargets = getSeedTargets();

  if (seedTargets.length === 0) {
    console.log("No seed files found.");
    await pool.end();
    return;
  }

  const client = await pool.connect();

  try {
    await client.query("begin");
    console.log("clear dictionary tables");
    await client.query(clearDictionaryDataSql);

    for (const seedTarget of seedTargets) {
      const sql = readSqlFile(seedTarget.relativePath);
      await client.query(sql);
      console.log(`seed  ${seedTarget.name}`);
    }

    await client.query("commit");
    console.log(`Seeded ${seedTargets.length} file(s).`);
  } catch (error) {
    await client.query("rollback");
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

runSeeds().catch((error) => {
  console.error("Seed failed:", error.message);
  process.exit(1);
});
