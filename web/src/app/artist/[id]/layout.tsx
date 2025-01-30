import { presetArtists } from "@/data/preset-artists";
import { Metadata } from "next";

export async function generateMetadata(
  props: {
    params: Promise<{ id: string }>;
  }
): Promise<Metadata> {
  const params = await props.params;
  const artist = presetArtists.find((a) => a.id === params.id);
  if (!artist) return {};

  return {
    title: `${artist.name} Music Quiz - Heardle.fun`,
    description: `Test your ${artist.name} music knowledge! Try to guess their songs from short clips. The faster you guess, the more points you earn!`,
    openGraph: {
      title: `${artist.name} Music Quiz - Heardle.fun`,
      description: `Test your ${artist.name} music knowledge! Try to guess their songs from short clips. The faster you guess, the more points you earn!`,
      images: [{ url: artist.imageUrl }],
    },
    twitter: {
      card: "summary_large_image",
      title: `${artist.name} Music Quiz - Heardle.fun`,
      description: `Test your ${artist.name} music knowledge! Try to guess their songs from short clips. The faster you guess, the more points you earn!`,
      images: [artist.imageUrl],
    },
  };
}

export default function ArtistLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
