import assert from "node:assert/strict";
import { after, before, describe, test } from "node:test";
import type { FastifyInstance } from "fastify";
import { createServer } from "../src/create-server.js";
import { MockSignRepository } from "../src/repositories/mock-sign-repository.js";

let server: FastifyInstance;
let signRepository: MockSignRepository;

before(async () => {
  signRepository = new MockSignRepository();
  server = await createServer({
    dataSource: "mock",
    signRepository,
  });
});

after(async () => {
  await signRepository.close();
  await server.close();
});

describe("GET /health", () => {
  test("returns ok with mock data source", async () => {
    const response = await server.inject({ method: "GET", url: "/health" });

    assert.equal(response.statusCode, 200);
    const body = response.json<{ status: string; dataSource: string }>();
    assert.equal(body.status, "ok");
    assert.equal(body.dataSource, "mock");
  });
});

describe("GET /signs/search", () => {
  test("returns mother for English query without lang", async () => {
    const response = await server.inject({
      method: "GET",
      url: "/signs/search?q=mother",
    });

    assert.equal(response.statusCode, 200);
    const body = response.json<{ items: { id: string }[] }>();
    assert.ok(body.items.some((item) => item.id === "mother"));
  });

  test("returns mother for Nepali query without lang", async () => {
    const nepaliQuery = encodeURIComponent("आमा");
    const response = await server.inject({
      method: "GET",
      url: `/signs/search?q=${nepaliQuery}`,
    });

    assert.equal(response.statusCode, 200);
    const body = response.json<{ items: { id: string }[] }>();
    assert.ok(body.items.some((item) => item.id === "mother"));
  });

  test("fuzzy matches mom to mother", async () => {
    const response = await server.inject({
      method: "GET",
      url: "/signs/search?q=mom",
    });

    assert.equal(response.statusCode, 200);
    const body = response.json<{ items: { id: string }[] }>();
    assert.ok(body.items.some((item) => item.id === "mother"));
  });

  test("fuzzy matches typo motr to mother", async () => {
    const response = await server.inject({
      method: "GET",
      url: "/signs/search?q=motr",
    });

    assert.equal(response.statusCode, 200);
    const body = response.json<{ items: { id: string }[] }>();
    assert.ok(body.items.some((item) => item.id === "mother"));
  });

  test("returns validation error when q is missing", async () => {
    const response = await server.inject({
      method: "GET",
      url: "/signs/search",
    });

    assert.equal(response.statusCode, 400);
    const body = response.json<{ error: { code: string; message: string } }>();
    assert.equal(body.error.code, "VALIDATION_ERROR");
  });
});

describe("GET /signs/:id", () => {
  test("returns sign detail with video fields", async () => {
    const response = await server.inject({
      method: "GET",
      url: "/signs/hello",
    });

    assert.equal(response.statusCode, 200);
    const body = response.json<{
      id: string;
      videoUrl: string | null;
      thumbnailUrl: string | null;
      videoDurationSeconds: number | null;
    }>();
    assert.equal(body.id, "hello");
    assert.ok("videoUrl" in body);
    assert.ok("thumbnailUrl" in body);
    assert.equal(body.videoDurationSeconds, null);
  });

  test("returns not found for unknown sign", async () => {
    const response = await server.inject({
      method: "GET",
      url: "/signs/does-not-exist",
    });

    assert.equal(response.statusCode, 404);
    const body = response.json<{ error: { code: string } }>();
    assert.equal(body.error.code, "NOT_FOUND");
  });
});

describe("GET /categories", () => {
  test("returns category list", async () => {
    const response = await server.inject({
      method: "GET",
      url: "/categories",
    });

    assert.equal(response.statusCode, 200);
    const body = response.json<{ items: { id: string; name: string }[] }>();
    assert.ok(body.items.length > 0);
    assert.ok(body.items.some((item) => item.name === "Family"));
  });
});

describe("GET /categories/:id/signs", () => {
  test("returns family signs in English", async () => {
    const response = await server.inject({
      method: "GET",
      url: "/categories/family/signs?lang=en",
    });

    assert.equal(response.statusCode, 200);
    const body = response.json<{ items: { id: string }[] }>();
    const signIds = body.items.map((item) => item.id);
    assert.ok(signIds.includes("mother"));
    assert.ok(signIds.includes("father"));
  });

  test("returns validation error when lang is missing", async () => {
    const response = await server.inject({
      method: "GET",
      url: "/categories/family/signs",
    });

    assert.equal(response.statusCode, 400);
    const body = response.json<{ error: { code: string } }>();
    assert.equal(body.error.code, "VALIDATION_ERROR");
  });
});
