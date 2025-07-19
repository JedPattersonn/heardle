import { NextResponse } from "next/server";
import { db } from "@/db";
import { artists } from "@/db/schema";
import { eq, asc, sql } from "drizzle-orm";

export async function GET() {
  try {
    // Get artists grouped by category, including playlist flag
    const categorizedArtists = await db
      .select({
        category: artists.category,
        artists: sql<string>`json_agg(
          json_build_object(
            'id', ${artists.appleId},
            'name', ${artists.name}, 
            'imageUrl', ${artists.imageUrl},
            'genres', ${artists.genres},
            'isPlaylist', ${artists.isPlaylist}
          ) ORDER BY ${artists.sortOrder}, ${artists.name}
        )`,
      })
      .from(artists)
      .where(eq(artists.isActive, true))
      .groupBy(artists.category);

    // Transform the data into the expected format
    const categories = categorizedArtists.map((cat) => {
      const artistList =
        typeof cat.artists === "string" ? JSON.parse(cat.artists) : cat.artists;

      return {
        title: formatCategoryTitle(cat.category || "uncategorized"),
        category: cat.category || "uncategorized",
        artists: artistList.map((artist: any) => ({
          ...artist,
          displayGenres: (artist.genres || []).slice(0, 2).join(", "),
        })),
      };
    });

    // Sort categories in the desired order (most likely to be wanted by users)
    const categoryOrder = [
      "trending",
      "featured",
      "playlists",
      "pop",
      "hip-hop",
      "country",
      "rock",
      "classics",
      "r&b",
      "electronic",
      "jazz",
    ];
    categories.sort((a, b) => {
      const aIndex = categoryOrder.indexOf(a.category.toLowerCase());
      const bIndex = categoryOrder.indexOf(b.category.toLowerCase());

      // If both categories are in the order array, sort by their position
      if (aIndex !== -1 && bIndex !== -1) {
        return aIndex - bIndex;
      }
      // If only one is in the order array, prioritize it
      if (aIndex !== -1) return -1;
      if (bIndex !== -1) return 1;
      // If neither is in the order array, sort alphabetically
      return a.title.localeCompare(b.title);
    });

    // No cache headers for mobile - always fetch fresh data
    const response = NextResponse.json(categories);
    response.headers.set(
      "Cache-Control",
      "no-cache, no-store, must-revalidate"
    );

    return response;
  } catch (error) {
    console.error("Failed to fetch categorized artists:", error);
    return NextResponse.json(
      { error: "Failed to fetch categorized artists" },
      { status: 500 }
    );
  }
}

function formatCategoryTitle(category: string): string {
  const categoryMap: Record<string, string> = {
    featured: "Featured Artists",
    trending: "Trending Now",
    playlists: "Playlists",
    "hip-hop": "Hip-Hop & Rap",
    rock: "Rock & Alternative",
    classics: "Classics & Legends",
    pop: "Pop",
    "r&b": "R&B",
    country: "Country",
    electronic: "Electronic",
    jazz: "Jazz",
    uncategorized: "Other Artists",
  };

  return (
    categoryMap[category.toLowerCase()] ||
    category.charAt(0).toUpperCase() + category.slice(1)
  );
}
