import { presetArtists } from "@/data/preset-artists";
import ArtistGameClient from "./ArtistGameClient";
import { Artist } from "@/types";
import Link from "next/link";
import { notFound } from "next/navigation";

interface ArtistPageProps {
  params: Promise<{ id: string }>;
}

export default async function ArtistPage({ params }: ArtistPageProps) {
  const { id } = await params;
  const artist = presetArtists.find((a) => a.id === id);

  if (!artist) {
    notFound();
  }

  // Generate structured data for SEO
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "Game",
    name: `${artist.name} Music Quiz`,
    description: `Test your ${artist.name} music knowledge! Try to guess their songs from short clips. The faster you guess, the more points you earn!`,
    genre: "Music Quiz Game",
    gamePlatform: "Web Browser",
    about: {
      "@type": "MusicGroup",
      name: artist.name,
      genre: artist.genres,
      image: artist.imageUrl,
    },
    provider: {
      "@type": "Organization",
      name: "Heardle.fun",
      url: "https://www.heardle.fun",
    },
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(structuredData) }}
      />
      <div className="min-h-screen flex flex-col">
        <nav className="p-4">
          <div className="max-w-7xl mx-auto">
            <div className="flex items-center space-x-2 text-sm text-muted-foreground">
              <Link href="/" className="hover:text-primary">
                Home
              </Link>
              <span>/</span>
              <span className="text-foreground">{artist.name} Quiz</span>
            </div>
          </div>
        </nav>

        <main className="flex flex-col items-center p-8 md:p-24 flex-grow">
          <h1 className="text-4xl font-bold mb-4 text-center">
            {artist.name} Music Quiz
          </h1>
          <p className="text-lg text-muted-foreground mb-8 text-center max-w-2xl">
            Test your knowledge of {artist.name}&apos;s music! Listen to short
            clips and guess the song as quickly as possible to earn more points.
          </p>
          <ArtistGameClient artist={artist} />
        </main>

        <footer className="text-center text-sm text-muted-foreground py-4">
          <Link href="/" className="hover:underline mr-4">
            Try another artist
          </Link>
          <a
            href="https://sidekicksoftware.co"
            target="_blank"
            className="hover:underline"
          >
            Developed by Jed Patterson
          </a>
        </footer>
      </div>
    </>
  );
}
