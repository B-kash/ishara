import { drizzle, type NodePgDatabase } from "drizzle-orm/node-postgres";
import pg from "pg";
import * as relations from "./relations.js";
import * as schema from "./schema.js";

const fullSchema = { ...schema, ...relations };

export type IsharaDatabase = NodePgDatabase<typeof fullSchema>;
export type IsharaDatabaseExecutor =
  | IsharaDatabase
  | Parameters<Parameters<IsharaDatabase["transaction"]>[0]>[0];

export type Database = ReturnType<typeof createDatabase>;

export function createDatabase(databaseUrl: string) {
  const pool = new pg.Pool({ connectionString: databaseUrl });
  const database: IsharaDatabase = drizzle(pool, { schema: fullSchema });

  return {
    database,
    pool,
    async close(): Promise<void> {
      await pool.end();
    },
  };
}
