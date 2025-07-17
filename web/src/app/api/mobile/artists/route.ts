import { NextResponse } from "next/server";
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
    const token = await generateToken();
    const results = await searchAppleMusic(query, token);

    // Add mobile-specific optimizations
    const mobileOptimizedResults = results.map((artist: any) => ({
      ...artist,
      // Ensure we have a valid image URL for mobile
      imageUrl: artist.imageUrl || `https://via.placeholder.com/300x300/ccc/999?text=${encodeURIComponent(artist.name)}`,
      // Add simplified genres for mobile display
      displayGenres: artist.genres.slice(0, 2).join(", "),
    }));

    // Set appropriate cache headers for mobile
    const response = NextResponse.json(mobileOptimizedResults);
    response.headers.set('Cache-Control', 'public, max-age=300'); // 5 minutes
    
    return response;
  } catch (error) {
    console.error("Mobile artist search error:", error);
    return NextResponse.json(
      { error: "Failed to search for artists" },
      { status: 500 }
    );
  }
}