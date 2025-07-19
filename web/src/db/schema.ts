import {
  integer,
  pgTable,
  varchar,
  text,
  timestamp,
  boolean,
  json,
} from "drizzle-orm/pg-core";

// Artists table for storing preset artists
export const artists = pgTable("artists", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  appleId: varchar("apple_id", { length: 255 }).unique().notNull(), // Apple Music artist ID or playlist ID
  name: varchar("name", { length: 255 }).notNull(),
  imageUrl: text("image_url"),
  genres: json("genres").$type<string[]>().default([]),
  isActive: boolean("is_active").default(true),
  category: varchar("category", { length: 100 }), // "featured", "trending", "hip-hop", "playlists", etc.
  sortOrder: integer("sort_order").default(0), // For ordering within categories
  isPlaylist: boolean("is_playlist").default(false), // Flag to indicate if this is a playlist
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

export type Artist = typeof artists.$inferSelect;
export type NewArtist = typeof artists.$inferInsert;
