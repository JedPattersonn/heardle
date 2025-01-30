"use client";

import { useEffect, useState, use } from "react";
import { presetArtists } from "@/data/preset-artists";
import Game from "@/components/Game";
import { Artist } from "@/types";
import { motion } from "framer-motion";
import Link from "next/link";

export default function ArtistPage(props: { params: Promise<{ id: string }> }) {
  const params = use(props.params);
  const [artist, setArtist] = useState<Artist | null>(null);

  useEffect(() => {
    const foundArtist = presetArtists.find((a) => a.id === params.id);
    if (foundArtist) {
      setArtist(foundArtist);
    }
  }, [params.id]);

  if (!artist) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center p-8">
        <h1 className="text-2xl font-bold mb-4">Artist not found</h1>
        <Link href="/" className="text-blue-500 hover:underline">
          Go back home
        </Link>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex flex-col">
      <main className="flex flex-col items-center p-8 md:p-24 flex-grow">
        <motion.h1
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-4xl font-bold mb-8"
        >
          {artist.name} Music Quiz
        </motion.h1>
        <Game selectedArtist={artist} onGameEnd={() => {}} />
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
  );
}
