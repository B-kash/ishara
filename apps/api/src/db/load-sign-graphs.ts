import { asc, eq } from "drizzle-orm";
import type { IsharaDatabase } from "./client.js";
import { signGraphFromQueryRow } from "./sign-graph.js";
import { signs } from "./schema.js";

export async function fetchAllSignGraphs(database: IsharaDatabase) {
  const rows = await database.query.signs.findMany({
    orderBy: [asc(signs.id)],
    with: {
      concept: {
        with: {
          category: true,
          words: true,
        },
      },
    },
  });

  return rows.map(signGraphFromQueryRow);
}

export async function fetchSignGraphById(
  database: IsharaDatabase,
  signId: string,
) {
  const row = await database.query.signs.findFirst({
    where: eq(signs.id, signId),
    with: {
      concept: {
        with: {
          category: true,
          words: true,
        },
      },
    },
  });

  if (!row) {
    return undefined;
  }

  return signGraphFromQueryRow(row);
}
