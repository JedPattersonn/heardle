import { NextResponse } from "next/server";
import { db } from "@/db";
import { artists } from "@/db/schema";
import { eq, desc } from "drizzle-orm";

// GET /api/admin/artists - Get all artists from database
export async function GET() {
  try {
    const allArtists = await db
      .select()
      .from(artists)
      .orderBy(desc(artists.createdAt));

    return NextResponse.json(allArtists);
  } catch (error) {
    console.error("Failed to fetch artists:", error);
    return NextResponse.json(
      { error: "Failed to fetch artists" },
      { status: 500 }
    );
  }
}

// POST /api/admin/artists - Add a new artist to database
export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { appleId, name, imageUrl, genres, category, sortOrder, isPlaylist } = body;

    if (!appleId || !name) {
      return NextResponse.json(
        { error: "Apple ID and name are required" },
        { status: 400 }
      );
    }

    // Check if artist already exists
    const existingArtist = await db
      .select()
      .from(artists)
      .where(eq(artists.appleId, appleId))
      .limit(1);

    if (existingArtist.length > 0) {
      return NextResponse.json(
        { error: "Artist/Playlist already exists in database" },
        { status: 409 }
      );
    }

    // Insert new artist/playlist
    const newArtist = await db
      .insert(artists)
      .values({
        appleId,
        name,
        imageUrl,
        genres: genres || [],
        category,
        sortOrder: sortOrder || 0,
        isPlaylist: isPlaylist || false,
      })
      .returning();

    return NextResponse.json(newArtist[0], { status: 201 });
  } catch (error) {
    console.error("Failed to create artist:", error);
    return NextResponse.json(
      { error: "Failed to create artist" },
      { status: 500 }
    );
  }
}