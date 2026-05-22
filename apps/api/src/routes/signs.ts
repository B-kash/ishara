import type { FastifyInstance, FastifyRequest } from "fastify";
import { detectDisplayLanguage } from "../data/sign-search-matching.js";
import {
  databaseErrorResponse,
  notFoundErrorResponse,
  validationErrorResponse,
} from "../errors/api-error.js";
import { toSignDetail, toSignSearchResult } from "../mappers/sign-response.js";
import {
  validateBrowseLetterParams,
  validateOptionalCursor,
  validatePageLimit,
  validateRequiredQueryParam,
  validateRouteId,
  validateSearchLanguageParam,
} from "../validation/request-validation.js";

interface SignRouteParams {
  id: string;
}

function getQueryParam(
  request: FastifyRequest,
  paramName: string,
): string | undefined {
  const queryValue = request.query as Record<string, string | undefined>;
  return queryValue[paramName];
}

export async function signRoutes(server: FastifyInstance) {
  server.get("/signs/search", async (request, reply) => {
    const { signRepository, log } = request.app;

    const searchQueryResult = validateRequiredQueryParam(
      getQueryParam(request, "q"),
      "q",
    );
    if (!searchQueryResult.ok) {
      return reply
        .status(400)
        .send(validationErrorResponse(searchQueryResult.message));
    }

    try {
      const matchedGraphs = await signRepository.searchSignGraphs(
        searchQueryResult.value,
      );
      const displayLanguage = detectDisplayLanguage(searchQueryResult.value);
      const items = matchedGraphs.map((signGraph) =>
        toSignSearchResult(signGraph, displayLanguage),
      );

      return { items };
    } catch (error) {
      log.error(error);
      return reply.status(503).send(databaseErrorResponse());
    }
  });

  server.get("/signs", async (request, reply) => {
    const { signRepository, log } = request.app;

    const languageResult = validateSearchLanguageParam(
      getQueryParam(request, "lang"),
    );
    if (!languageResult.ok) {
      return reply
        .status(400)
        .send(validationErrorResponse(languageResult.message));
    }

    const cursorResult = validateOptionalCursor(
      getQueryParam(request, "cursor"),
    );
    if (!cursorResult.ok) {
      return reply
        .status(400)
        .send(validationErrorResponse(cursorResult.message));
    }

    const limitResult = validatePageLimit(getQueryParam(request, "limit"));
    if (!limitResult.ok) {
      return reply
        .status(400)
        .send(validationErrorResponse(limitResult.message));
    }

    const letterResult = validateBrowseLetterParams(
      getQueryParam(request, "letter"),
      getQueryParam(request, "letterLang"),
    );
    if (!letterResult.ok) {
      return reply
        .status(400)
        .send(validationErrorResponse(letterResult.message));
    }

    try {
      const browsePage = await signRepository.listSignGraphsPage({
        cursor: cursorResult.value,
        limit: limitResult.value,
        letter: letterResult.value?.letter,
        letterLanguage: letterResult.value?.letterLanguage,
      });

      const items = browsePage.items.map((signGraph) =>
        toSignSearchResult(signGraph, languageResult.value),
      );

      return {
        items,
        pageInfo: {
          nextCursor: browsePage.nextCursor,
          hasMore: browsePage.hasMore,
        },
      };
    } catch (error) {
      log.error(error);
      return reply.status(503).send(databaseErrorResponse());
    }
  });

  server.get("/signs/:id", async (request, reply) => {
    const { signRepository, log } = request.app;
    const routeParams = request.params as SignRouteParams;
    const signIdResult = validateRouteId(routeParams.id, "Sign");
    if (!signIdResult.ok) {
      return reply
        .status(400)
        .send(validationErrorResponse(signIdResult.message));
    }

    try {
      const signGraph = await signRepository.getSignGraphById(signIdResult.value);

      if (!signGraph) {
        return reply
          .status(404)
          .send(notFoundErrorResponse("Sign not found"));
      }

      return toSignDetail(signGraph);
    } catch (error) {
      log.error(error);
      return reply.status(503).send(databaseErrorResponse());
    }
  });
}
