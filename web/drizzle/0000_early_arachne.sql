CREATE TABLE "artists" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "artists_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"apple_id" varchar(255) NOT NULL,
	"name" varchar(255) NOT NULL,
	"image_url" text,
	"genres" json DEFAULT '[]'::json,
	"is_active" boolean DEFAULT true,
	"category" varchar(100),
	"sort_order" integer DEFAULT 0,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now(),
	CONSTRAINT "artists_apple_id_unique" UNIQUE("apple_id")
);
