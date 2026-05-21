import type pg from "pg";
import { buildSearchTerms } from "../data/sign-search-matching.js";
import type { Category } from "../types/api-responses.js";
import type { SearchLanguageCode, SignRecord } from "../types/sign-record.js";
import { createPostgresPool } from "./postgres/postgres-pool.js";
import {
  mapRowToSignRecord,
  signRecordSelectSql,
  type SignRecordRow,
} from "./postgres/postgres-row-mapper.js";
import type { SignRepository } from "./sign-repository.js";

export class PostgresSignRepository implements SignRepository {
  private readonly pool: pg.Pool;

  constructor(databaseUrl: string) {
    this.pool = createPostgresPool(databaseUrl);
  }

  private async querySignRecords(
    whereClause: string,
    parameters: unknown[],
  ): Promise<SignRecord[]> {
    const sql = `${signRecordSelectSql} ${whereClause}`;
    const result = await this.pool.query<SignRecordRow>(sql, parameters);
    return result.rows.map(mapRowToSignRecord);
  }

  async getAllSignRecords(): Promise<SignRecord[]> {
    return this.querySignRecords("order by signs.id", []);
  }

  async getSignById(signId: string): Promise<SignRecord | undefined> {
    const records = await this.querySignRecords(
      "where signs.id = $1",
      [signId],
    );
    return records[0];
  }

  async searchSignRecords(
    searchQuery: string,
    language: SearchLanguageCode,
  ): Promise<SignRecord[]> {
    const searchTerms = buildSearchTerms(searchQuery, language);
    if (searchTerms.length === 0) {
      return [];
    }

    return this.querySignRecords(
      `where exists (
        select 1
        from words search_words
        where search_words.concept_id = concepts.id
          and search_words.language = $1
          and (
            lower(search_words.word) = any($2::text[])
            or exists (
              select 1
              from unnest($2::text[]) as search_term
              where lower(search_words.word) like '%' || search_term || '%'
                 or search_term like '%' || lower(search_words.word) || '%'
            )
          )
      )
      order by signs.id`,
      [language, searchTerms],
    );
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
