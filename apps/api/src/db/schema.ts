import {
  pgTable,
  text,
  timestamp,
  uuid,
  unique,
} from "drizzle-orm/pg-core";

/**
 * PostgreSQL tables — column names match supabase/migrations/001_initial_schema.sql.
 * TypeScript fields use camelCase; Drizzle maps them to snake_case columns.
 */
export const categories = pgTable("categories", {
  id: text("id").primaryKey(),
  name: text("name").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true, mode: "date" })
    .notNull()
    .defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true, mode: "date" })
    .notNull()
    .defaultNow(),
});

export const concepts = pgTable("concepts", {
  id: text("id").primaryKey(),
  categoryId: text("category_id")
    .notNull()
    .references(() => categories.id, { onDelete: "restrict" }),
  meaningEnglish: text("meaning_english").notNull(),
  meaningNepali: text("meaning_nepali").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true, mode: "date" })
    .notNull()
    .defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true, mode: "date" })
    .notNull()
    .defaultNow(),
});

export const words = pgTable(
  "words",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    conceptId: text("concept_id")
      .notNull()
      .references(() => concepts.id, { onDelete: "cascade" }),
    language: text("language").notNull(),
    word: text("word").notNull(),
    createdAt: timestamp("created_at", { withTimezone: true, mode: "date" })
      .notNull()
      .defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: "date" })
      .notNull()
      .defaultNow(),
  },
  (table) => [unique("words_concept_id_language_unique").on(table.conceptId, table.language)],
);

export const signs = pgTable("signs", {
  id: text("id").primaryKey(),
  conceptId: text("concept_id")
    .notNull()
    .unique()
    .references(() => concepts.id, { onDelete: "cascade" }),
  videoUrl: text("video_url"),
  thumbnailUrl: text("thumbnail_url"),
  createdAt: timestamp("created_at", { withTimezone: true, mode: "date" })
    .notNull()
    .defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true, mode: "date" })
    .notNull()
    .defaultNow(),
});

export type Category = typeof categories.$inferSelect;
export type NewCategory = typeof categories.$inferInsert;

export type Concept = typeof concepts.$inferSelect;
export type NewConcept = typeof concepts.$inferInsert;

export type Word = typeof words.$inferSelect;
export type NewWord = typeof words.$inferInsert;

export type Sign = typeof signs.$inferSelect;
export type NewSign = typeof signs.$inferInsert;
