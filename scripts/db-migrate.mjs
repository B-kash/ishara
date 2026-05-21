import { readdirSync } from "node:fs";
import { join } from "node:path";
import {
  createPool,
  ensureMigrationsTable,
  getAppliedNames,
  readSqlFile,
  repositoryRoot,
} from "./db-utils.mjs";

const migrationsDirectory = join(repositoryRoot, "supabase", "migrations");

function listMigrationFiles() {
  return readdirSync(migrationsDirectory)
    .filter((fileName) => fileName.endsWith(".sql"))
    .sort();
}

async function runMigrations() {
  const pool = createPool();

  try {
    await ensureMigrationsTable(pool);
    const appliedMigrations = await getAppliedNames(pool, "schema_migrations");
    const migrationFiles = listMigrationFiles();

    if (migrationFiles.length === 0) {
      console.log("No migration files found.");
      return;
    }

    let appliedCount = 0;

    for (const fileName of migrationFiles) {
      if (appliedMigrations.has(fileName)) {
        console.log(`skip  ${fileName} (already applied)`);
        continue;
      }

      const sql = readSqlFile(`supabase/migrations/${fileName}`);
      const client = await pool.connect();

      try {
        await client.query("begin");
        await client.query(sql);
        await client.query(
          "insert into schema_migrations (name) values ($1)",
          [fileName],
        );
        await client.query("commit");
        console.log(`apply ${fileName}`);
        appliedCount += 1;
      } catch (error) {
        await client.query("rollback");
        throw error;
      } finally {
        client.release();
      }
    }

    if (appliedCount === 0) {
      console.log("Database is up to date.");
    } else {
      console.log(`Applied ${appliedCount} migration(s).`);
    }
  } finally {
    await pool.end();
  }
}

runMigrations().catch((error) => {
  console.error("Migration failed:", error.message);
  process.exit(1);
});
