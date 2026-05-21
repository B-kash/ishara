import assert from "node:assert/strict";
import { after, before, describe, test } from "node:test";
import type { FastifyInstance } from "fastify";
import { createServer } from "../src/create-server.js";
import { MockSignRepository } from "../src/repositories/mock-sign-repository.js";

const testAdminAuth = {
  username: "editor",
  password: "test-password",
  sessionSecret: "test-session-secret-value",
  sessionTtlMs: 60 * 60 * 1000,
};

let server: FastifyInstance;
let signRepository: MockSignRepository;

before(async () => {
  signRepository = new MockSignRepository();
  server = await createServer({
    dataSource: "mock",
    signRepository,
    adminAuth: testAdminAuth,
    enableAdminPanel: true,
  });
});

after(async () => {
  await signRepository.close();
  await server.close();
});

describe("POST /admin/login", () => {
  test("returns token for valid credentials", async () => {
    const response = await server.inject({
      method: "POST",
      url: "/admin/login",
      payload: {
        username: "editor",
        password: "test-password",
      },
    });

    assert.equal(response.statusCode, 200);
    const body = response.json<{ token: string; username: string }>();
    assert.ok(body.token.length > 10);
    assert.equal(body.username, "editor");
  });

  test("returns unauthorized for invalid password", async () => {
    const response = await server.inject({
      method: "POST",
      url: "/admin/login",
      payload: {
        username: "editor",
        password: "wrong-password",
      },
    });

    assert.equal(response.statusCode, 401);
    const body = response.json<{ error: { code: string } }>();
    assert.equal(body.error.code, "UNAUTHORIZED");
  });
});

describe("POST /admin/signs", () => {
  test("requires authentication", async () => {
    const response = await server.inject({
      method: "POST",
      url: "/admin/signs",
      payload: {
        signId: "new-sign",
        englishWord: "new",
        nepaliWord: "नयाँ",
        meaningEnglish: "Something new.",
        meaningNepali: "नयाँ कुरा।",
        category: "Greetings",
      },
    });

    assert.equal(response.statusCode, 401);
  });

  test("returns validation error when postgres is not enabled", async () => {
    const loginResponse = await server.inject({
      method: "POST",
      url: "/admin/login",
      payload: {
        username: "editor",
        password: "test-password",
      },
    });
    const loginBody = loginResponse.json<{ token: string }>();

    const response = await server.inject({
      method: "POST",
      url: "/admin/signs",
      headers: {
        authorization: `Bearer ${loginBody.token}`,
      },
      payload: {
        signId: "new-sign",
        englishWord: "new",
        nepaliWord: "नयाँ",
        meaningEnglish: "Something new.",
        meaningNepali: "नयाँ कुरा।",
        category: "Greetings",
      },
    });

    assert.equal(response.statusCode, 503);
    const body = response.json<{ error: { message: string } }>();
    assert.match(body.error.message, /postgres/i);
  });
});
