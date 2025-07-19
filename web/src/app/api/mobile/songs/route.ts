import { NextResponse } from "next/server";
import jwt from "jsonwebtoken";
import { Song } from "@/types";
import { db } from "@/db";
import { artists } from "@/db/schema";
import { eq } from "drizzle-orm";

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

async function fetchPlaylistSongs(
  playlistId: string,
  token: string
): Promise<Song[]> {
  // Fetch playlist tracks
  const response = await fetch(
    `https://api.music.apple.com/v1/catalog/us/playlists/${playlistId}/tracks?limit=100`,
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    }
  );

  if (!response.ok) {
    const errorText = await response.text();
    console.error("Apple Music API error response:", errorText);
    throw new Error(`Apple Music API error: ${response.statusText}`);
  }

  const result = await response.json();
  const allSongs = result.data || [];
  const uniqueSongs = new Map();

  allSongs.forEach((song: any, index: number) => {
    const uniqueKey = `${song.attributes.name.toLowerCase().trim()}-${song.attributes.artistName.toLowerCase().trim()}`;

    if (!uniqueSongs.has(uniqueKey) && song.attributes.previews?.length > 0) {
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

  const mobileSongs = Array.from(uniqueSongs.values()).map(
    (song: any): Song => ({
      id: song.id,
      difficulty: song.difficulty,
      attributes: {
        name: song.attributes.name,
        artistName: song.attributes.artistName,
        albumName: song.attributes.albumName,
        artwork: {
          url:
            song.attributes.artwork?.url ||
            "https://via.placeholder.com/300x300/ccc/999?text=Album",
        },
        durationInMillis: song.attributes.durationInMillis,
        previews: song.attributes.previews || [],
      },
    })
  );

  // Filter out songs without valid preview URLs
  return mobileSongs.filter(
    (song) =>
      song.attributes.previews.length > 0 &&
      song.attributes.previews[0].url.startsWith("https://")
  );
}

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
    const uniqueKey = `${song.attributes.name.toLowerCase().trim()}-${song.attributes.artistName.toLowerCase().trim()}`;

    if (!uniqueSongs.has(uniqueKey) && song.attributes.previews?.length > 0) {
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

  const mobileSongs = Array.from(uniqueSongs.values()).map(
    (song: any): Song => ({
      id: song.id,
      difficulty: song.difficulty,
      attributes: {
        name: song.attributes.name,
        artistName: song.attributes.artistName,
        albumName: song.attributes.albumName,
        artwork: {
          url:
            song.attributes.artwork?.url ||
            "https://via.placeholder.com/300x300/ccc/999?text=Album",
        },
        durationInMillis: song.attributes.durationInMillis,
        previews: song.attributes.previews || [],
      },
    })
  );

  // Filter out songs without valid preview URLs
  return mobileSongs.filter(
    (song) =>
      song.attributes.previews.length > 0 &&
      song.attributes.previews[0].url.startsWith("https://")
  );
}

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const artistId = searchParams.get("artistId");
  const difficulty = searchParams.get("difficulty") as Difficulty | null;

  if (!artistId) {
    return NextResponse.json(
      { error: "Artist ID is required" },
      { status: 400 }
    );
  }

  try {
    // Check if this artistId is actually a playlist
    const artistRecord = await db
      .select()
      .from(artists)
      .where(eq(artists.appleId, artistId))
      .limit(1);

    const token = await generateToken();
    let songs: Song[];

    if (artistRecord.length > 0 && artistRecord[0].isPlaylist) {
      // Fetch playlist songs
      songs = await fetchPlaylistSongs(artistId, token);
    } else {
      // Fetch artist songs
      songs = await fetchArtistSongs(artistId, token);
    }

    // Filter by difficulty if specified
    if (difficulty) {
      switch (difficulty) {
        case "easy":
          songs = songs.filter((song) => song.difficulty === "easy");
          break;
        case "medium":
          songs = songs.filter((song) =>
            ["easy", "medium"].includes(song.difficulty)
          );
          break;
        case "hard":
          // Return all songs
          break;
      }
    }

    // Mobile optimization: ensure we have enough songs for a good game experience
    if (songs.length < 5) {
      console.warn(`Only ${songs.length} songs found for artist ${artistId}`);
    }

    // Set appropriate cache headers for mobile
    const response = NextResponse.json(songs);
    response.headers.set("Cache-Control", "public, max-age=1800"); // 30 minutes

    return response;
  } catch (error) {
    console.error("Mobile songs fetch error:", error);
    return NextResponse.json(
      { error: "Failed to fetch songs" },
      { status: 500 }
    );
  }
}
