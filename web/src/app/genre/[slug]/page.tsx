import { presetArtists } from "@/data/preset-artists";
import Link from "next/link";
import Image from "next/image";
import { notFound } from "next/navigation";
import { Metadata } from "next";

interface GenrePageProps {
  params: Promise<{ slug: string }>;
}

// Generate static params for all genres
export async function generateStaticParams() {
  const allGenres = [
    ...new Set(presetArtists.flatMap((artist) => artist.genres)),
  ];
  return allGenres.map((genre) => ({
    slug: genre.toLowerCase().replace(/\s+/g, "-"),
  }));
}

// Generate metadata for SEO
export async function generateMetadata({
  params,
}: GenrePageProps): Promise<Metadata> {
  const { slug } = await params;
  const genreName = slug
    .replace(/-/g, " ")
    .replace(/\b\w/g, (l) => l.toUpperCase());

  // Find artists in this genre
  const artistsInGenre = presetArtists.filter((artist) =>
    artist.genres.some(
      (genre) => genre.toLowerCase().replace(/\s+/g, "-") === slug
    )
  );

  if (artistsInGenre.length === 0) {
    return {
      title: "Genre Not Found - Heardle.fun",
      description: "The music genre you're looking for could not be found.",
    };
  }

  const title = `${genreName} Music Quiz - Heardle.fun`;
  const description = `Test your ${genreName.toLowerCase()} music knowledge! Play quizzes featuring ${artistsInGenre
    .map((a) => a.name)
    .slice(0, 3)
    .join(
      ", "
    )}${artistsInGenre.length > 3 ? ` and ${artistsInGenre.length - 3} more artists` : ""}. Guess songs from audio clips and earn points!`;

  return {
    title,
    description,
    keywords: [
      genreName,
      `${genreName} music`,
      `${genreName} quiz`,
      `${genreName} heardle`,
      `${genreName} artists`,
      `${genreName} songs`,
      "music quiz",
      "song guessing game",
      ...artistsInGenre.slice(0, 5).map((artist) => artist.name),
    ],
    openGraph: {
      title,
      description,
      type: "website",
      url: `https://www.heardle.fun/genre/${slug}`,
      images: artistsInGenre.slice(0, 4).map((artist) => ({
        url: artist.imageUrl,
        alt: `${artist.name} - ${genreName} artist`,
      })),
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
    },
  };
}

export default async function GenrePage({ params }: GenrePageProps) {
  const { slug } = await params;
  const genreName = slug
    .replace(/-/g, " ")
    .replace(/\b\w/g, (l) => l.toUpperCase());

  // Find artists in this genre
  const artistsInGenre = presetArtists.filter((artist) =>
    artist.genres.some(
      (genre) => genre.toLowerCase().replace(/\s+/g, "-") === slug
    )
  );

  if (artistsInGenre.length === 0) {
    notFound();
  }

  // Generate structured data
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: `${genreName} Music Quiz Collection`,
    description: `Collection of ${genreName.toLowerCase()} music quizzes featuring top artists in the genre`,
    url: `https://www.heardle.fun/genre/${slug}`,
    hasPart: artistsInGenre.map((artist) => ({
      "@type": "Game",
      name: `${artist.name} Music Quiz`,
      url: `https://www.heardle.fun/artist/${artist.id}`,
      about: {
        "@type": "MusicGroup",
        name: artist.name,
        genre: artist.genres,
        image: artist.imageUrl,
      },
    })),
    genre: genreName,
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
        {/* Navigation */}
        <nav className="p-4 border-b">
          <div className="max-w-7xl mx-auto">
            <div className="flex items-center space-x-2 text-sm text-muted-foreground">
              <Link href="/" className="hover:text-primary">
                Home
              </Link>
              <span>/</span>
              <Link href="/genres" className="hover:text-primary">
                Genres
              </Link>
              <span>/</span>
              <span className="text-foreground">{genreName}</span>
            </div>
          </div>
        </nav>

        <main className="flex-grow">
          {/* Hero Section */}
          <section className="bg-gradient-to-b from-primary/5 to-background py-16 px-8">
            <div className="max-w-6xl mx-auto text-center">
              <h1 className="text-4xl md:text-5xl font-bold mb-4">
                {genreName} Music Quiz
              </h1>
              <p className="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto">
                Test your knowledge of {genreName.toLowerCase()} music! Choose
                from {artistsInGenre.length} talented {genreName.toLowerCase()}{" "}
                artists and guess their songs from audio clips.
              </p>

              <div className="flex flex-wrap justify-center gap-2 mb-8">
                <span className="px-4 py-2 bg-primary/10 text-primary rounded-full text-sm font-medium">
                  {artistsInGenre.length} Artists Available
                </span>
                <span className="px-4 py-2 bg-primary/10 text-primary rounded-full text-sm font-medium">
                  {genreName} Genre
                </span>
              </div>
            </div>
          </section>

          {/* Artists Grid */}
          <section className="py-16 px-8">
            <div className="max-w-6xl mx-auto">
              <h2 className="text-3xl font-bold text-center mb-4">
                Featured {genreName} Artists
              </h2>
              <p className="text-lg text-muted-foreground text-center mb-12 max-w-2xl mx-auto">
                Challenge yourself with music from these top{" "}
                {genreName.toLowerCase()} artists. From chart-toppers to genre
                legends, test your musical knowledge!
              </p>

              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6">
                {artistsInGenre.map((artist) => (
                  <article key={artist.id} className="group">
                    <Link
                      href={`/artist/${artist.id}`}
                      className="flex flex-col items-center p-4 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-all duration-200"
                      title={`Play ${artist.name} ${genreName} music quiz`}
                    >
                      <div className="relative w-24 h-24 mb-3 overflow-hidden rounded-full group-hover:scale-105 transition-transform">
                        <Image
                          src={artist.imageUrl}
                          alt={`${artist.name} - ${genreName} artist quiz`}
                          fill
                          className="object-cover"
                          sizes="(max-width: 768px) 96px, 96px"
                        />
                      </div>
                      <h3 className="font-semibold text-center group-hover:text-primary transition-colors mb-1">
                        {artist.name}
                      </h3>
                      <p className="text-sm text-muted-foreground text-center">
                        {artist.genres
                          .filter(
                            (g) => g.toLowerCase().replace(/\s+/g, "-") === slug
                          )
                          .join(", ")}
                      </p>
                    </Link>
                  </article>
                ))}
              </div>
            </div>
          </section>

          {/* Why Play This Genre */}
          <section className="py-16 px-8 bg-muted/30">
            <div className="max-w-4xl mx-auto text-center">
              <h2 className="text-3xl font-bold mb-6">
                Why Play {genreName} Music Quizzes?
              </h2>
              <div className="grid md:grid-cols-2 gap-8">
                <div>
                  <h3 className="text-xl font-semibold mb-3">
                    🎵 Discover New Songs
                  </h3>
                  <p className="text-muted-foreground">
                    Explore the rich catalog of {genreName.toLowerCase()} music
                    and discover tracks you might have missed.
                  </p>
                </div>
                <div>
                  <h3 className="text-xl font-semibold mb-3">
                    🏆 Test Your Knowledge
                  </h3>
                  <p className="text-muted-foreground">
                    Challenge yourself with songs from the best{" "}
                    {genreName.toLowerCase()} artists and see how well you know
                    the genre.
                  </p>
                </div>
                <div>
                  <h3 className="text-xl font-semibold mb-3">⚡ Quick & Fun</h3>
                  <p className="text-muted-foreground">
                    Perfect for {genreName.toLowerCase()} fans looking for a
                    quick musical challenge during breaks.
                  </p>
                </div>
                <div>
                  <h3 className="text-xl font-semibold mb-3">
                    📈 Improve Your Skills
                  </h3>
                  <p className="text-muted-foreground">
                    Sharpen your ear for {genreName.toLowerCase()} music and
                    become a true genre expert.
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* Other Genres */}
          <section className="py-16 px-8">
            <div className="max-w-6xl mx-auto text-center">
              <h2 className="text-3xl font-bold mb-8">Explore Other Genres</h2>
              <div className="flex flex-wrap justify-center gap-3">
                {[...new Set(presetArtists.flatMap((artist) => artist.genres))]
                  .filter(
                    (genre) => genre.toLowerCase().replace(/\s+/g, "-") !== slug
                  )
                  .slice(0, 8)
                  .map((genre) => (
                    <Link
                      key={genre}
                      href={`/genre/${genre.toLowerCase().replace(/\s+/g, "-")}`}
                      className="px-4 py-2 bg-background border border-border rounded-full hover:bg-primary hover:text-primary-foreground transition-colors text-sm font-medium"
                    >
                      {genre}
                    </Link>
                  ))}
              </div>
              <div className="mt-6">
                <Link href="/" className="text-primary hover:underline">
                  View All Artists →
                </Link>
              </div>
            </div>
          </section>
        </main>

        <footer className="bg-background border-t py-8">
          <div className="max-w-6xl mx-auto px-8 text-center">
            <p className="text-sm text-muted-foreground">
              &copy; 2025 Heardle.fun - {genreName} Music Quiz & More
            </p>
          </div>
        </footer>
      </div>
    </>
  );
}
