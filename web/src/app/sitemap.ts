import { presetArtists } from "@/data/preset-artists";
import { MetadataRoute } from "next";

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = "https://www.heardle.fun";
  const now = new Date();

  const popularArtistIds = [
    "159260351",
    "271256",
    "320569549",
    "412778295",
    "390647681",
  ];

  const artistUrls = presetArtists.map((artist) => {
    const isPopular = popularArtistIds.includes(artist.id);
    return {
      url: `${baseUrl}/artist/${artist.id}`,
      lastModified: now,
      changeFrequency: "weekly" as const,
      priority: isPopular ? 0.9 : 0.8,
    };
  });

  return [
    {
      url: baseUrl,
      lastModified: now,
      changeFrequency: "weekly",
      priority: 1.0,
    },
    ...artistUrls,
  ];
}
