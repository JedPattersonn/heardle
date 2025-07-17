import { presetArtists } from "@/data/preset-artists";
import Link from "next/link";
import HomePageClient from "./HomePageClient";
import Image from "next/image";

export default function Home() {
  return (
    <>
      <div className="min-h-screen flex flex-col">
        {/* Header with navigation */}
        <header className="bg-background border-b">
          <nav className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center h-16">
              <div className="flex items-center">
                <Link href="/" className="text-2xl font-bold">
                  Heardle.fun
                </Link>
              </div>
              <div className="hidden md:flex space-x-8">
                <Link
                  href="#how-to-play"
                  className="text-muted-foreground hover:text-foreground"
                >
                  How to Play
                </Link>
                <Link
                  href="#popular-artists"
                  className="text-muted-foreground hover:text-foreground"
                >
                  Popular Artists
                </Link>
              </div>
            </div>
          </nav>
        </header>

        <main className="flex-grow">
          {/* Hero Section */}
          <section className="bg-gradient-to-b from-primary/5 to-background py-16 px-8">
            <div className="max-w-4xl mx-auto text-center">
              <h1 className="text-5xl md:text-6xl font-bold mb-6">
                Heardle.fun
              </h1>
              <p className="text-xl md:text-2xl text-muted-foreground mb-8 max-w-2xl mx-auto">
                Test your music knowledge! Search for any artist and try to
                guess their songs from short clips. The faster you guess, the
                more points you earn!
              </p>

              {/* Interactive search component */}
              <HomePageClient />
            </div>
          </section>

          {/* How to Play Section */}
          <section id="how-to-play" className="py-16 px-8 bg-muted/30">
            <div className="max-w-6xl mx-auto">
              <h2 className="text-3xl font-bold text-center mb-12">
                How to Play
              </h2>
              <div className="grid md:grid-cols-3 gap-8">
                <div className="text-center">
                  <div className="w-16 h-16 bg-primary rounded-full flex items-center justify-center mx-auto mb-4">
                    <span className="text-2xl font-bold text-primary-foreground">
                      1
                    </span>
                  </div>
                  <h3 className="text-xl font-semibold mb-3">
                    Choose an Artist
                  </h3>
                  <p className="text-muted-foreground">
                    Search for your favorite artist or pick from our popular
                    selection featuring top musicians across all genres.
                  </p>
                </div>
                <div className="text-center">
                  <div className="w-16 h-16 bg-primary rounded-full flex items-center justify-center mx-auto mb-4">
                    <span className="text-2xl font-bold text-primary-foreground">
                      2
                    </span>
                  </div>
                  <h3 className="text-xl font-semibold mb-3">Listen & Guess</h3>
                  <p className="text-muted-foreground">
                    Listen to short audio clips from the artist&apos;s songs and
                    try to guess the track name as quickly as possible.
                  </p>
                </div>
                <div className="text-center">
                  <div className="w-16 h-16 bg-primary rounded-full flex items-center justify-center mx-auto mb-4">
                    <span className="text-2xl font-bold text-primary-foreground">
                      3
                    </span>
                  </div>
                  <h3 className="text-xl font-semibold mb-3">Earn Points</h3>
                  <p className="text-muted-foreground">
                    The faster you guess correctly, the more points you earn!
                    Challenge yourself with different difficulty levels.
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* Popular Artists Section */}
          <section id="popular-artists" className="py-16 px-8">
            <div className="max-w-6xl mx-auto">
              <h2 className="text-3xl font-bold text-center mb-4">
                Popular Artists
              </h2>
              <p className="text-lg text-muted-foreground text-center mb-12 max-w-2xl mx-auto">
                Start your musical journey with these trending artists. From pop
                sensations to hip-hop legends, test your knowledge across all
                genres.
              </p>

              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-6">
                {presetArtists.map((artist) => (
                  <article key={artist.id}>
                    <Link
                      href={`/artist/${artist.id}`}
                      className="group flex flex-col items-center p-4 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
                      title={`Play ${artist.name} music quiz`}
                    >
                      <div className="relative w-24 h-24 mb-3 overflow-hidden rounded-full group-hover:scale-105 transition-transform">
                        <Image
                          src={artist.imageUrl}
                          alt={`${artist.name} - Play music quiz`}
                          fill
                          className="object-cover"
                          sizes="(max-width: 768px) 96px, 96px"
                        />
                      </div>
                      <h3 className="font-medium text-center group-hover:text-primary transition-colors">
                        {artist.name}
                      </h3>
                      <p className="text-sm text-muted-foreground text-center mt-1">
                        {artist.genres.slice(0, 2).join(", ")}
                      </p>
                    </Link>
                  </article>
                ))}
              </div>

              <div className="text-center mt-12">
                <p className="text-muted-foreground mb-4">
                  Don&apos;t see your favorite artist? Use our search to find
                  any musician!
                </p>
              </div>
            </div>
          </section>

          {/* Features Section */}
          <section className="py-16 px-8 bg-muted/30">
            <div className="max-w-6xl mx-auto">
              <h2 className="text-3xl font-bold text-center mb-12">
                Why Choose Heardle.fun?
              </h2>
              <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
                <div className="text-center">
                  <h3 className="text-lg font-semibold mb-3">
                    🎵 Vast Music Library
                  </h3>
                  <p className="text-muted-foreground text-sm">
                    Access songs from thousands of artists across all genres and
                    decades.
                  </p>
                </div>
                <div className="text-center">
                  <h3 className="text-lg font-semibold mb-3">
                    🎯 Multiple Difficulty Levels
                  </h3>
                  <p className="text-muted-foreground text-sm">
                    Choose from easy, medium, or hard modes to match your music
                    knowledge.
                  </p>
                </div>
                <div className="text-center">
                  <h3 className="text-lg font-semibold mb-3">⚡ Quick & Fun</h3>
                  <p className="text-muted-foreground text-sm">
                    Perfect for quick music breaks or extended gaming sessions.
                  </p>
                </div>
                <div className="text-center">
                  <h3 className="text-lg font-semibold mb-3">
                    📱 Mobile Friendly
                  </h3>
                  <p className="text-muted-foreground text-sm">
                    Play anywhere, anytime on your phone, tablet, or computer.
                  </p>
                </div>
              </div>
            </div>
          </section>
        </main>

        <footer className="bg-background border-t py-8">
          <div className="max-w-6xl mx-auto px-8">
            <div className="flex flex-col md:flex-row justify-between items-center">
              <div className="mb-4 md:mb-0">
                <p className="text-sm text-muted-foreground">
                  &copy; 2025 Heardle.fun - Test Your Music Knowledge
                </p>
              </div>
              <div className="flex space-x-6">
                <a
                  href="https://jedpatterson.com"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-sm text-muted-foreground hover:text-foreground"
                >
                  Developed by Jed Patterson
                </a>
              </div>
            </div>
          </div>
        </footer>
      </div>
    </>
  );
}
