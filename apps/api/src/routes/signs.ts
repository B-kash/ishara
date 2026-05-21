import type { FastifyInstance, FastifyRequest } from "fastify";
import { getSignRepository } from "../repositories/active-sign-repository.js";
import { parseSearchLanguage } from "../data/sign-search.js";
import { toSignDetail, toSignSearchResult } from "../mappers/sign-response.js";
import type { ApiErrorResponse } from "../types/api-responses.js";

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
      const errorBody: ApiErrorResponse = {
        error: "Query parameter q is required",
      };
      return reply.status(400).send(errorBody);
    }

    const searchLanguage = parseSearchLanguage(languageParam);
    if (!searchLanguage) {
      const errorBody: ApiErrorResponse = {
        error: "Query parameter lang must be en or ne",
      };
      return reply.status(400).send(errorBody);
    }

    const signRepository = getSignRepository();
    const matchedRecords = await signRepository.searchSignRecords(
      searchQuery,
      searchLanguage,
    );
    const items = matchedRecords.map((signRecord) =>
      toSignSearchResult(signRecord, searchLanguage),
    );

    return { items };
  });

  server.get("/signs/:id", async (request, reply) => {
    const { id: signId } = request.params as SignRouteParams;
    const signRepository = getSignRepository();
    const signRecord = await signRepository.getSignById(signId);

    if (!signRecord) {
      const errorBody: ApiErrorResponse = { error: "Sign not found" };
      return reply.status(404).send(errorBody);
    }

    return toSignDetail(signRecord);
  });
}
