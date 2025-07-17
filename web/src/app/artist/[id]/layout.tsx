import { presetArtists } from "@/data/preset-artists";
import { Metadata } from "next";

export async function generateStaticParams() {
  return presetArtists.map((artist) => ({
    id: artist.id,
  }));
}

export async function generateMetadata(props: {
  params: Promise<{ id: string }>;
}): Promise<Metadata> {
  const params = await props.params;
  const artist = presetArtists.find((a) => a.id === params.id);

  if (!artist) {
    return {
      title: "Artist Not Found - Heardle.fun",
      description:
        "The artist you're looking for could not be found. Try searching for another artist.",
    };
  }

  const title = `${artist.name} Music Quiz - Heardle.fun`;
  const description = `Test your ${artist.name} music knowledge! Try to guess their songs from short clips. The faster you guess, the more points you earn!`;
  const url = `https://www.heardle.fun/artist/${artist.id}`;

  return {
    title,
    description,
    keywords: [
      artist.name,
      "music quiz",
      "heardle",
      "song guessing game",
      "music trivia",
      ...artist.genres,
      `${artist.name} songs`,
      `${artist.name} quiz`,
    ],
    authors: [{ name: "Jed Patterson" }],
    creator: "Jed Patterson",
    publisher: "Heardle.fun",
    robots: {
      index: true,
      follow: true,
      googleBot: {
        index: true,
        follow: true,
        "max-video-preview": -1,
        "max-image-preview": "large",
        "max-snippet": -1,
      },
    },
    alternates: {
      canonical: url,
    },
    openGraph: {
      type: "website",
      siteName: "Heardle.fun",
      title,
      description,
      url,
      images: [
        {
          url: artist.imageUrl,
          width: 300,
          height: 300,
          alt: `${artist.name} profile picture`,
        },
      ],
      locale: "en_US",
    },
    twitter: {
      card: "summary_large_image",
      site: "@heardle_fun",
      creator: "@jedpatterson",
      title,
      description,
      images: [
        {
          url: artist.imageUrl,
          alt: `${artist.name} profile picture`,
        },
      ],
    },
    verification: {
      google: "your-google-verification-code",
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
