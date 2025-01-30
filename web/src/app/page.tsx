"use client";

import { useState } from "react";
import Search from "@/components/Search";
import Game from "@/components/Game";
import { Artist } from "@/types";
import { AnimatePresence, motion } from "framer-motion";
import { presetArtists } from "@/data/preset-artists";
import Link from "next/link";

export default function Home() {
  const [selectedArtist, setSelectedArtist] = useState<Artist | null>(null);
  const [showSearch, setShowSearch] = useState(true);

  const handleArtistSelect = (artist: Artist) => {
    setSelectedArtist(artist);
    setShowSearch(false);
  };

  const handleGameEnd = () => {
    setSelectedArtist(null);
    setShowSearch(true);
  };

  return (
    <div className="min-h-screen flex flex-col">
      <main className="flex flex-col items-center p-8 md:p-24 flex-grow">
        <motion.h1
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-4xl font-bold mb-8"
        >
          Heardle.fun
        </motion.h1>
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="text-center mb-8 max-w-md"
        >
          Test your music knowledge! Search for an artist and try to guess their
          songs from short clips. The faster you guess, the more points you
          earn!
        </motion.p>

        <AnimatePresence mode="wait">
          {showSearch && (
            <>
              <Search key="search" onArtistSelect={handleArtistSelect} />
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                className="mt-12"
              >
                <h2 className="text-xl font-semibold mb-4 text-center">
                  Popular Artists
                </h2>
                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
                  {presetArtists.map((artist) => (
                    <Link
                      key={artist.id}
                      href={`/artist/${artist.id}`}
                      className="flex flex-col items-center p-4 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
                    >
                      <img
                        src={artist.imageUrl}
                        alt={artist.name}
                        className="w-24 h-24 rounded-full mb-2"
                      />
                      <span className="font-medium text-center">
                        {artist.name}
                      </span>
                    </Link>
                  ))}
                </div>
              </motion.div>
            </>
          )}
          {selectedArtist && (
            <Game
              key="game"
              selectedArtist={selectedArtist}
              onGameEnd={handleGameEnd}
            />
          )}
        </AnimatePresence>
      </main>
      <footer className="text-center text-sm text-muted-foreground py-4">
        <a
          href="https://sidekicksoftware.co"
          target="_blank"
          className="hover:underline"
        >
          A Side Kick Software product
        </a>
      </footer>
    </div>
  );
}
