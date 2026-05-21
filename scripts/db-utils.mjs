import { config as loadDotenv } from "dotenv";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import pg from "pg";

const scriptsDirectory = dirname(fileURLToPath(import.meta.url));
export const repositoryRoot = join(scriptsDirectory, "..");

loadDotenv({ path: join(repositoryRoot, ".env") });

export function getDatabaseUrl() {
  const databaseUrl = process.env.DATABASE_URL?.trim();
  if (!databaseUrl) {
    throw new Error(
      "DATABASE_URL is missing. Copy .env.example to .env and set your PostgreSQL URL.",
    );
  }
  return databaseUrl;
}

export function createPool() {
  return new pg.Pool({ connectionString: getDatabaseUrl() });
}

export function readSqlFile(relativePath) {
  const filePath = join(repositoryRoot, relativePath);
  return readFileSync(filePath, "utf8");
}

export async function ensureMigrationsTable(pool) {
  await pool.query(`
    create table if not exists schema_migrations (
      name text primary key,
      applied_at timestamptz not null default now()
    );
  `);
}

export async function getAppliedNames(pool, tableName) {
  const result = await pool.query(
    `select name from ${tableName} order by name`,
  );
  return new Set(result.rows.map((row) => row.name));
}
