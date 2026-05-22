import { asc, eq } from "drizzle-orm";
import type {
  BulkSignImportResult,
  SignImportOutcome,
} from "../data/sign-import.js";
import {
  signGraphMatchesBilingualSearch,
  sortSignGraphsBySearchScore,
} from "../data/sign-search-matching.js";
import {
  buildSignBrowsePage,
  prepareBrowseSignGraphs,
} from "../data/sign-browse-pagination.js";
import { createDatabase, type Database } from "../db/client.js";
import { fetchAllSignGraphs, fetchSignGraphById } from "../db/load-sign-graphs.js";
import type { Category } from "../db/schema.js";
import { categories } from "../db/schema.js";
import type { SignBrowsePage } from "../types/sign-browse-page.js";
import type { SignGraph } from "../db/sign-graph.js";
import {
  bulkImportSignRecordsWithDatabase,
  importSingleSignRecordWithDatabase,
} from "./drizzle-sign-import.js";
import type {
  ListSignGraphsPageOptions,
  SignRepository,
} from "./sign-repository.js";

export class DrizzleSignRepository implements SignRepository {
  private readonly databaseHandle: Database;

  constructor(databaseUrl: string) {
    this.databaseHandle = createDatabase(databaseUrl);
  }

  private get database() {
    return this.databaseHandle.database;
  }

  async getAllSignGraphs(): Promise<SignGraph[]> {
    return fetchAllSignGraphs(this.database);
  }

  async listSignGraphsPage(
    options: ListSignGraphsPageOptions,
  ): Promise<SignBrowsePage> {
    const allGraphs = await this.getAllSignGraphs();
    const candidatePage = prepareBrowseSignGraphs(allGraphs, {
      cursor: options.cursor,
      limit: options.limit,
      letter: options.letter,
      letterLanguage: options.letterLanguage,
    });

    return buildSignBrowsePage(candidatePage, options.limit);
  }

  async getSignGraphById(signId: string): Promise<SignGraph | undefined> {
    return fetchSignGraphById(this.database, signId);
  }

  async searchSignGraphs(searchQuery: string): Promise<SignGraph[]> {
    const trimmedQuery = searchQuery.trim();
    if (!trimmedQuery) {
      return [];
    }

    const allGraphs = await this.getAllSignGraphs();
    const matchedGraphs = allGraphs.filter((signGraph) =>
      signGraphMatchesBilingualSearch(signGraph, trimmedQuery),
    );

    return sortSignGraphsBySearchScore(matchedGraphs, trimmedQuery);
  }

  async getAllCategories(): Promise<Category[]> {
    return this.database.query.categories.findMany({
      orderBy: [asc(categories.name)],
    });
  }

  async getCategoryById(categoryId: string): Promise<Category | undefined> {
    return this.database.query.categories.findFirst({
      where: eq(categories.id, categoryId),
    });
  }

  async getSignGraphsByCategoryId(
    categoryId: string,
  ): Promise<SignGraph[] | undefined> {
    const category = await this.getCategoryById(categoryId);
    if (!category) {
      return undefined;
    }

    const allGraphs = await this.getAllSignGraphs();
    return allGraphs.filter(
      (signGraph) => signGraph.category.id === categoryId,
    );
  }

  async importSignRecord(rawRecord: unknown): Promise<SignImportOutcome> {
    return importSingleSignRecordWithDatabase(this.database, rawRecord);
  }

  async bulkImportSignRecords(rawRecords: unknown[]): Promise<BulkSignImportResult> {
    return bulkImportSignRecordsWithDatabase(this.database, rawRecords);
  }

  async close(): Promise<void> {
    await this.databaseHandle.close();
  }
}
