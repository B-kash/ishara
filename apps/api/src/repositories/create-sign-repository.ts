import type { AppConfig } from "../config/env.js";
import { MockSignRepository } from "./mock-sign-repository.js";
import { PostgresSignRepository } from "./postgres-sign-repository.js";
import type { SignRepository } from "./sign-repository.js";

export function createSignRepository(config: AppConfig): SignRepository {
  if (config.dataSource === "mock") {
    return new MockSignRepository();
  }

  return new PostgresSignRepository(config.databaseUrl!);
}
