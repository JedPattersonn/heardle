import { NextResponse } from "next/server";
import { db } from "@/db";
import { artists } from "@/db/schema";
import { eq, asc } from "drizzle-orm";

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const category = searchParams.get("category");

  try {
    let query = db.select().from(artists).where(eq(artists.isActive, true));

    if (category) {
      query = query.where(eq(artists.category, category));
    }

    const allArtists = await query.orderBy(asc(artists.sortOrder), asc(artists.name));

    // Transform to match the mobile app format
    const mobileArtists = allArtists.map((artist) => ({
      id: artist.appleId, // Use Apple ID as the mobile app expects
      name: artist.name,
      imageUrl: artist.imageUrl,
      genres: artist.genres || [],
      displayGenres: (artist.genres || []).slice(0, 2).join(", "),
    }));

    // Set appropriate cache headers
    const response = NextResponse.json(mobileArtists);
    response.headers.set('Cache-Control', 'public, max-age=300'); // 5 minutes
    
    return response;
  } catch (error) {
    console.error("Failed to fetch artists:", error);
    return NextResponse.json(
      { error: "Failed to fetch artists" },
      { status: 500 }
    );
  }
}