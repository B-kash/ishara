import type { FastifyInstance } from "fastify";
import {
  getSignById,
  parseSearchLang,
  searchSigns,
} from "../data/signs.js";

interface SearchQuerystring {
  q?: string;
  lang?: string;
}

interface SignRouteParams {
  id: string;
}

export async function signRoutes(server: FastifyInstance) {
  server.get("/signs/search", async (request, reply) => {
    const { q: searchQuery, lang: languageParam } =
      request.query as SearchQuerystring;

    if (!searchQuery?.trim()) {
      return reply
        .status(400)
        .send({ error: "Query parameter q is required" });
    }

    const searchLanguage = parseSearchLang(languageParam);
    if (!searchLanguage) {
      return reply.status(400).send({
        error: "Query parameter lang must be en or ne",
      });
    }

    const results = searchSigns(searchQuery, searchLanguage);

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
