import type pg from "pg";
import { buildLetterPrefixPattern } from "../data/browse-letters.js";
import { buildSignBrowsePage } from "../data/sign-browse-pagination.js";
import {
  signRecordMatchesBilingualSearch,
  sortSignRecordsBySearchScore,
} from "../data/sign-search-matching.js";
import type { Category } from "../types/api-responses.js";
import type { SignBrowsePage } from "../types/sign-browse-page.js";
import type { SignRecord } from "../types/sign-record.js";
import { createPostgresPool } from "./postgres/postgres-pool.js";
import {
  mapRowToSignRecord,
  signRecordSelectSql,
  type SignRecordRow,
} from "./postgres/postgres-row-mapper.js";
import type {
  ListSignRecordsPageOptions,
  SignRepository,
} from "./sign-repository.js";

export class PostgresSignRepository implements SignRepository {
  private readonly pool: pg.Pool;

  constructor(databaseUrl: string) {
    this.pool = createPostgresPool(databaseUrl);
  }

  /**
   * whereClause is hardcoded in this file only — never built from request input.
   * User values are passed via parameters ($1, $2) so the driver binds them as data.
   */
  private async querySignRecords(
    whereClause: string,
    parameters: unknown[],
  ): Promise<SignRecord[]> {
    const sql = `${signRecordSelectSql} ${whereClause}`;
    const result = await this.pool.query<SignRecordRow>(sql, parameters);
    return result.rows.map(mapRowToSignRecord);
  }

  async getAllSignRecords(): Promise<SignRecord[]> {
    return this.querySignRecords("order by signs.id asc", []);
  }

  async listSignRecordsPage(
    options: ListSignRecordsPageOptions,
  ): Promise<SignBrowsePage> {
    const fetchLimit = options.limit + 1;

    if (options.letter && options.letterLanguage) {
      const letterPattern = buildLetterPrefixPattern(
        options.letter,
        options.letterLanguage,
      );
      const wordColumn =
        options.letterLanguage === "en"
          ? "lower(english_words.word)"
          : "nepali_words.word";

      const candidateRecords = options.cursor
        ? await this.querySignRecords(
            `where ${wordColumn} like $1 and signs.id > $2 order by signs.id asc limit $3`,
            [letterPattern, options.cursor, fetchLimit],
          )
        : await this.querySignRecords(
            `where ${wordColumn} like $1 order by signs.id asc limit $2`,
            [letterPattern, fetchLimit],
          );

      return buildSignBrowsePage(candidateRecords, options.limit);
    }

    const candidateRecords = options.cursor
      ? await this.querySignRecords(
          "where signs.id > $1 order by signs.id asc limit $2",
          [options.cursor, fetchLimit],
        )
      : await this.querySignRecords("order by signs.id asc limit $1", [
          fetchLimit,
        ]);

    return buildSignBrowsePage(candidateRecords, options.limit);
  }

  async getSignById(signId: string): Promise<SignRecord | undefined> {
    const records = await this.querySignRecords(
      "where signs.id = $1",
      [signId],
    );
    return records[0];
  }

  async searchSignRecords(searchQuery: string): Promise<SignRecord[]> {
    const trimmedQuery = searchQuery.trim();
    if (!trimmedQuery) {
      return [];
    }

    // Full scan + in-memory fuzzy match (dictionary size is small for MVP).
    // SQL LIKE pre-filters skip typo matches before Levenshtein can run.
    const allRecords = await this.getAllSignRecords();
    const matchedRecords = allRecords.filter((signRecord) =>
      signRecordMatchesBilingualSearch(signRecord, trimmedQuery),
    );

    return sortSignRecordsBySearchScore(matchedRecords, trimmedQuery);
  }

  async getAllCategories(): Promise<Category[]> {
    const result = await this.pool.query<{ id: string; name: string }>(
      "select id, name from categories order by name",
    );
    return result.rows;
  }

  async getCategoryById(categoryId: string): Promise<Category | undefined> {
    const result = await this.pool.query<{ id: string; name: string }>(
      "select id, name from categories where id = $1",
      [categoryId],
    );
    return result.rows[0];
  }

  async getSignRecordsByCategoryId(
    categoryId: string,
  ): Promise<SignRecord[] | undefined> {
    const category = await this.getCategoryById(categoryId);
    if (!category) {
      return undefined;
    }

    return this.querySignRecords(
      "where categories.id = $1 order by signs.id",
      [categoryId],
    );
  }

  async close(): Promise<void> {
    await this.pool.end();
  }
}
