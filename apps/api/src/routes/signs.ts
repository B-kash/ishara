import type { FastifyInstance, FastifyRequest } from "fastify";
import { getSignById } from "../data/sign-repository.js";
import {
  parseSearchLanguage,
  searchSignRecords,
} from "../data/sign-search.js";

interface SignRouteParams {
  id: string;
}

function getSearchQuery(request: FastifyRequest): string | undefined {
  const queryValue = request.query as Record<string, string | undefined>;
  return queryValue["q"];
}

function getLanguageParam(request: FastifyRequest): string | undefined {
  const queryValue = request.query as Record<string, string | undefined>;
  return queryValue["lang"];
}

export async function signRoutes(server: FastifyInstance) {
  server.get("/signs/search", async (request, reply) => {
    const searchQuery = getSearchQuery(request);
    const languageParam = getLanguageParam(request);

    if (!searchQuery?.trim()) {
      return reply
        .status(400)
        .send({ error: "Query parameter q is required" });
    }

    const searchLanguage = parseSearchLanguage(languageParam);
    if (!searchLanguage) {
      return reply.status(400).send({
        error: "Query parameter lang must be en or ne",
      });
    }

    const results = searchSignRecords(searchQuery, searchLanguage);

    return {
      query: searchQuery,
      lang: searchLanguage,
      count: results.length,
      results,
    };
  });

  server.get("/signs/:id", async (request, reply) => {
    const { id: signId } = request.params as SignRouteParams;
    const sign = getSignById(signId);

    if (!sign) {
      return reply.status(404).send({ error: "Sign not found" });
    }

    return sign;
  });
}
