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

interface AppleMusicArtist {
  id: string;
  type: string;
  attributes: {
    name: string;
    genreNames: string[];
    artwork?: {
      url: string;
      width: number;
      height: number;
    };
    url: string;
  };
}

interface AppleMusicSearchResponse {
  results: {
    artists: {
      data: AppleMusicArtist[];
    };
  };
}

// GET /api/admin/search-apple-music?q=artist+name
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

    const data: AppleMusicSearchResponse = await response.json();

    // Transform the response to match our needs
    const transformedArtists = data.results.artists.data.map((artist) => ({
      appleId: artist.id,
      name: artist.attributes.name,
      imageUrl: artist.attributes.artwork?.url
        ? artist.attributes.artwork.url.replace("{w}x{h}", "300x300")
        : null,
      genres: artist.attributes.genreNames || [],
      appleMusicUrl: artist.attributes.url,
    }));

    return NextResponse.json(transformedArtists);
  } catch (error) {
    console.error("Apple Music search error:", error);
    return NextResponse.json(
      { error: "Failed to search Apple Music" },
      { status: 500 }
    );
  }
}