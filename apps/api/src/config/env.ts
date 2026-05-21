export type DataSource = "mock" | "postgres";

export type CorsOriginSetting = boolean | string | string[];

export interface AppConfig {
  dataSource: DataSource;
  databaseUrl: string | undefined;
  port: number;
  host: string;
  corsOrigin: CorsOriginSetting;
}

function parseCorsOrigin(value: string | undefined): CorsOriginSetting {
  const trimmedValue = value?.trim();
  if (!trimmedValue || trimmedValue === "*") {
    return true;
  }

  const allowedOrigins = trimmedValue
    .split(",")
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0);

  if (allowedOrigins.length === 1) {
    return allowedOrigins[0]!;
  }

  return allowedOrigins;
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
    corsOrigin: parseCorsOrigin(process.env.CORS_ORIGIN),
  };
}
