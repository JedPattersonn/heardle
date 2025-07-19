CREATE TABLE "genre_playlists" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "genre_playlists_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"name" varchar(255) NOT NULL,
	"type" varchar(50) NOT NULL,
	"apple_playlist_id" varchar(255) NOT NULL,
	"image_url" text,
	"description" text,
	"is_active" boolean DEFAULT true,
	"category" varchar(100),
	"sort_order" integer DEFAULT 0,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now(),
	CONSTRAINT "genre_playlists_apple_playlist_id_unique" UNIQUE("apple_playlist_id")
);
