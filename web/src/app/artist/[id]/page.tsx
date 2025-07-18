import { presetArtists } from "@/data/preset-artists";
import ArtistGameClient from "./ArtistGameClient";
import { Artist } from "@/types";
import Link from "next/link";
import { notFound } from "next/navigation";
import PostHogClient from "@/lib/posthog";
import { randomUUID } from "crypto";

interface ArtistPageProps {
  params: Promise<{ id: string }>;
}

export default async function ArtistPage({ params }: ArtistPageProps) {
  const { id } = await params;
  const artist = presetArtists.find((a) => a.id === id);

  if (!artist) {
    notFound();
  }

  const posthog = PostHogClient();

  posthog.capture({
    event: "artistSelected",
    distinctId: randomUUID(),
    properties: {
      artist_id: id,
      artist_name: artist.name,
    },
  });

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
          <p className="text-lg text-muted-foreground mb-4 text-center max-w-2xl">
            Test your knowledge of {artist.name}&apos;s music! Listen to short
            clips and guess the song as quickly as possible to earn more points.
          </p>

          {/* Artist Info Section */}
          <div className="w-full max-w-4xl mx-auto mb-8">
            <div className="grid md:grid-cols-2 gap-8 items-start">
              <div className="text-center md:text-left">
                <div className="relative w-48 h-48 mx-auto md:mx-0 mb-4 rounded-xl overflow-hidden">
                  <img
                    src={artist.imageUrl}
                    alt={`${artist.name} profile`}
                    className="w-full h-full object-cover"
                  />
                </div>
                <div className="flex flex-wrap justify-center md:justify-start gap-2 mb-4">
                  {artist.genres.map((genre) => (
                    <Link
                      key={genre}
                      href={`/genre/${genre.toLowerCase().replace(/\s+/g, "-")}`}
                      className="px-3 py-1 bg-primary/10 text-primary rounded-full text-sm hover:bg-primary hover:text-primary-foreground transition-colors"
                    >
                      {genre}
                    </Link>
                  ))}
                </div>
              </div>

              <div className="space-y-4">
                <div>
                  <h2 className="text-2xl font-bold mb-3">
                    About {artist.name}
                  </h2>
                  <p className="text-muted-foreground">
                    Challenge yourself with {artist.name}&apos;s biggest hits
                    and deep cuts! This{" "}
                    {artist.genres.join(" & ").toLowerCase()} artist has created
                    countless memorable tracks that have shaped the music
                    industry. From chart-topping singles to album favorites,
                    test your knowledge of {artist.name}&apos;s discography in
                    this interactive music quiz.
                  </p>
                </div>

                <div>
                  <h3 className="text-lg font-semibold mb-2">What to Expect</h3>
                  <ul className="text-sm text-muted-foreground space-y-1">
                    <li>
                      • Audio clips from {artist.name}&apos;s most popular songs
                    </li>
                    <li>• Multiple difficulty levels to challenge all fans</li>
                    <li>• Points for quick and accurate guesses</li>
                    <li>• Discover songs you might have missed</li>
                  </ul>
                </div>

                <div>
                  <h3 className="text-lg font-semibold mb-2">
                    Genre: {artist.genres.join(", ")}
                  </h3>
                  <p className="text-sm text-muted-foreground">
                    Explore more {artist.genres[0].toLowerCase()} artists and
                    test your knowledge across different genres. Perfect for
                    fans of {artist.genres.join(" and ").toLowerCase()} music!
                  </p>
                </div>
              </div>
            </div>
          </div>

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
