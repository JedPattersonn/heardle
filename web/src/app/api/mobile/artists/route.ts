import { NextResponse } from "next/server";
import { db } from "@/db";
import { artists } from "@/db/schema";
import { eq, ilike, or } from "drizzle-orm";
import jwt from "jsonwebtoken";

const TEAM_ID = process.env.APPLE_TEAM_ID!;
const KEY_ID = process.env.APPLE_KEY_ID!;
const PRIVATE_KEY = process.env.APPLE_PRIVATE_KEY!.replace(/\\n/g, "\n");

async function generateToken() {
  const token = jwt.sign({}, PRIVATE_KEY, {
    algorithm: "ES256",
    expiresIn: "1h",
    issuer: TEAM_ID,
    header: {
      alg: "ES256",
      kid: KEY_ID,
    },
  });

  return token;
}

async function searchAppleMusic(query: string, token: string) {
  const encodedQuery = encodeURIComponent(query);
  const response = await fetch(
    `https://api.music.apple.com/v1/catalog/us/search?types=artists&term=${encodedQuery}&limit=20`,
    {
      headers: {
        Authorization: `Bearer ${token}`,
        "Music-User-Token": "",
      },
    }
  );

  if (!response.ok) {
    throw new Error(`Apple Music API error: ${response.statusText}`);
  }

  const data = await response.json();

  return data.results.artists.data.map((artist: any) => ({
    name: artist.attributes.name,
    id: artist.id,
    imageUrl: artist.attributes.artwork?.url
      ? artist.attributes.artwork.url.replace("{w}x{h}", "300x300")
      : null,
    genres: artist.attributes.genreNames || [],
  }));
}

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const query = searchParams.get("q");

  if (!query) {
    return NextResponse.json(
      { error: "Search query is required" },
      { status: 400 }
    );
  }

  try {
    // First, search in our database for preset artists
    const databaseResults = await db
      .select()
      .from(artists)
      .where(
        or(
          ilike(artists.name, `%${query}%`),
          ilike(artists.name, `${query}%`)
        )
      )
      .limit(10);

    // Transform database results to mobile format
    const databaseArtists = databaseResults.map((artist) => ({
      id: artist.appleId,
      name: artist.name,
      imageUrl: artist.imageUrl,
      genres: artist.genres || [],
      displayGenres: (artist.genres || []).slice(0, 2).join(", "),
      isPreset: true, // Mark as preset artist
    }));

    // If we have enough database results, return them
    if (databaseArtists.length >= 5) {
      const response = NextResponse.json(databaseArtists);
      response.headers.set("Cache-Control", "public, max-age=300");
      return response;
    }

    // Otherwise, also search Apple Music for additional results
    const token = await generateToken();
    const appleMusicResults = await searchAppleMusic(query, token);

    // Filter out Apple Music results that are already in our database
    const databaseAppleIds = new Set(databaseResults.map(a => a.appleId));
    const filteredAppleMusicResults = appleMusicResults.filter(
      (artist: any) => !databaseAppleIds.has(artist.id)
    );

    // Add mobile-specific optimizations to Apple Music results
    const mobileOptimizedAppleResults = filteredAppleMusicResults.map((artist: any) => ({
      ...artist,
      imageUrl:
        artist.imageUrl ||
        `https://via.placeholder.com/300x300/ccc/999?text=${encodeURIComponent(artist.name)}`,
      displayGenres: artist.genres.slice(0, 2).join(", "),
      isPreset: false, // Mark as non-preset artist
    }));

    // Combine results - preset artists first, then Apple Music results
    const combinedResults = [
      ...databaseArtists,
      ...mobileOptimizedAppleResults.slice(0, 20 - databaseArtists.length)
    ];

    // Set appropriate cache headers for mobile
    const response = NextResponse.json(combinedResults);
    response.headers.set("Cache-Control", "public, max-age=300"); // 5 minutes

    return response;
  } catch (error) {
    console.error("Mobile artist search error:", error);
    return NextResponse.json(
      { error: "Failed to search for artists" },
      { status: 500 }
    );
  }
}
