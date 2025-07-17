import { presetArtists } from "@/data/preset-artists";
import { MetadataRoute } from "next";

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = "https://www.heardle.fun";
  const now = new Date();

  // Popular artists get higher priority and more frequent updates
  const popularArtistIds = [
    "159260351", // Taylor Swift
    "271256", // Drake
    "320569549", // Justin Bieber
    "412778295", // Ariana Grande
    "390647681", // Sabrina Carpenter
  ];

  // Generate artist pages
  const artistUrls = presetArtists.map((artist) => {
    const isPopular = popularArtistIds.includes(artist.id);
    return {
      url: `${baseUrl}/artist/${artist.id}`,
      lastModified: now,
      changeFrequency: isPopular ? ("daily" as const) : ("weekly" as const),
      priority: isPopular ? 0.9 : 0.8,
    };
  });

  // Generate genre pages
  const allGenres = [
    ...new Set(presetArtists.flatMap((artist) => artist.genres)),
  ];
  const genreUrls = allGenres.map((genre) => ({
    url: `${baseUrl}/genre/${encodeURIComponent(genre.toLowerCase().replace(/\s+/g, "-"))}`,
    lastModified: now,
    changeFrequency: "weekly" as const,
    priority: 0.7,
  }));

  return [
    {
      url: baseUrl,
      lastModified: now,
      changeFrequency: "daily",
      priority: 1.0,
    },
    ...artistUrls,
    ...genreUrls,
  ];
}
