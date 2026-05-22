import { relations } from "drizzle-orm";
import { categories, concepts, signs, words } from "./schema.js";

export const categoriesRelations = relations(categories, ({ many }) => ({
  concepts: many(concepts),
}));

export const conceptsRelations = relations(concepts, ({ one, many }) => ({
  category: one(categories, {
    fields: [concepts.categoryId],
    references: [categories.id],
  }),
  words: many(words),
  sign: one(signs, {
    fields: [concepts.id],
    references: [signs.conceptId],
  }),
}));

export const wordsRelations = relations(words, ({ one }) => ({
  concept: one(concepts, {
    fields: [words.conceptId],
    references: [concepts.id],
  }),
}));

export const signsRelations = relations(signs, ({ one }) => ({
  concept: one(concepts, {
    fields: [signs.conceptId],
    references: [concepts.id],
  }),
}));
