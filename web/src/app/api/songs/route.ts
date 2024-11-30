import { NextResponse } from "next/server";
import jwt from "jsonwebtoken";
import { Song } from "@/types";

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

type Difficulty = "easy" | "medium" | "hard";

async function fetchArtistSongs(
  artistId: string,
  token: string
): Promise<Song[]> {
  const requests = Array.from({ length: 5 }, (_, i) =>
    fetch(
      `https://api.music.apple.com/v1/catalog/us/artists/${artistId}/songs?limit=20&offset=${
        i * 20
      }`,
      {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      }
    )
  );

  const responses = await Promise.all(requests);
  const validResponses = [];

  for (const response of responses) {
    if (!response.ok) {
      const errorText = await response.text();
      try {
        const errorJson = JSON.parse(errorText);
        // This throws if there are no more songs
        if (errorJson.errors?.[0]?.code === "40403") {
          break;
        }
      } catch {
        console.error("Apple Music API error response:", errorText);
        throw new Error(`Apple Music API error: ${response.statusText}`);
      }
      console.error("Apple Music API error response:", errorText);
      throw new Error(`Apple Music API error: ${response.statusText}`);
    }
    validResponses.push(response);
  }

  const results = await Promise.all(validResponses.map((r) => r.json()));
  const allSongs = results.flatMap((result) => result.data || []);
  const uniqueSongs = new Map();

  allSongs.forEach((song: any, index: number) => {
    const uniqueKey = song.id;
    if (!uniqueSongs.has(uniqueKey)) {
      let difficulty: Difficulty = "hard";
      if (index < 20) {
        difficulty = "easy";
      } else if (index < 40) {
        difficulty = "medium";
      }

      uniqueSongs.set(uniqueKey, {
        ...song,
        difficulty,
      });
    }
  });

  return Array.from(uniqueSongs.values()).map(
    (song: any): Song => ({
      id: song.id,
      difficulty: song.difficulty,
      attributes: {
        name: song.attributes.name,
        artistName: song.attributes.artistName,
        albumName: song.attributes.albumName,
        artwork: {
          url: song.attributes.artwork.url,
        },
        durationInMillis: song.attributes.durationInMillis,
        previews: song.attributes.previews || [],
      },
    })
  );
}

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const artistId = searchParams.get("artistId");

  if (!artistId) {
    return NextResponse.json(
      { error: "Artist ID is required" },
      { status: 400 }
    );
  }

  try {
    const token = await generateToken();
    const songs = await fetchArtistSongs(artistId, token);
    return NextResponse.json(songs);
  } catch (error) {
    console.error("Songs fetch error:", error);
    return NextResponse.json(
      { error: "Failed to fetch songs" },
      { status: 500 }
    );
  }
}
