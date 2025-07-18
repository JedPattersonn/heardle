import { NextResponse } from "next/server";
import { db } from "@/db";
import { artists } from "@/db/schema";
import { eq, asc, sql } from "drizzle-orm";

export async function GET() {
  try {
    // Get artists grouped by category
    const categorizedArtists = await db
      .select({
        category: artists.category,
        artists: sql<string>`json_agg(
          json_build_object(
            'id', ${artists.appleId},
            'name', ${artists.name}, 
            'imageUrl', ${artists.imageUrl},
            'genres', ${artists.genres}
          ) ORDER BY ${artists.sortOrder}, ${artists.name}
        )`,
      })
      .from(artists)
      .where(eq(artists.isActive, true))
      .groupBy(artists.category);

    // Transform the data into the expected format
    const categories = categorizedArtists.map((cat) => {
      const artistList = typeof cat.artists === 'string' 
        ? JSON.parse(cat.artists) 
        : cat.artists;
      
      return {
        title: formatCategoryTitle(cat.category || 'uncategorized'),
        artists: artistList.map((artist: any) => ({
          ...artist,
          displayGenres: (artist.genres || []).slice(0, 2).join(", "),
        })),
      };
    });

    // Set appropriate cache headers
    const response = NextResponse.json(categories);
    response.headers.set('Cache-Control', 'public, max-age=600'); // 10 minutes
    
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
    'featured': 'Featured Artists',
    'trending': 'Trending Now',
    'hip-hop': 'Hip-Hop & Rap',
    'rock': 'Rock & Alternative',
    'classics': 'Classics & Legends',
    'pop': 'Pop',
    'r&b': 'R&B',
    'country': 'Country',
    'electronic': 'Electronic',
    'jazz': 'Jazz',
    'uncategorized': 'Other Artists',
  };

  return categoryMap[category.toLowerCase()] || 
         category.charAt(0).toUpperCase() + category.slice(1);
}