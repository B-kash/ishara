export type DataSource = "mock" | "postgres";

export interface AppConfig {
  dataSource: DataSource;
  databaseUrl: string | undefined;
  port: number;
  host: string;
}

function parseDataSource(value: string | undefined): DataSource {
  const normalized = value?.trim().toLowerCase();
  if (!normalized || normalized === "mock") {
    return "mock";
  }
  if (normalized === "postgres") {
    return "postgres";
  }
  throw new Error(
    `Invalid DATA_SOURCE "${value}". Use "mock" or "postgres".`,
  );
}

export function loadConfig(): AppConfig {
  const dataSource = parseDataSource(process.env.DATA_SOURCE);
  const databaseUrl = process.env.DATABASE_URL?.trim() || undefined;

  if (dataSource === "postgres" && !databaseUrl) {
    throw new Error(
      "DATABASE_URL is required when DATA_SOURCE=postgres.",
    );
  }

  return {
    dataSource,
    databaseUrl,
    port: Number(process.env.PORT ?? 3000),
    host: process.env.HOST ?? "0.0.0.0",
  };
}
