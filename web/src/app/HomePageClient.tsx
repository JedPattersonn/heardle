"use client";

import { useState } from "react";
import Search from "@/components/Search";
import Game from "@/components/Game";
import { Artist } from "@/types";
import { AnimatePresence, motion } from "framer-motion";
import { Button } from "@/components/ui/button";

export default function HomePageClient() {
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
    <div className="w-full max-w-lg mx-auto">
      <AnimatePresence mode="wait">
        {showSearch && (
          <motion.div
            key="search"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="space-y-6"
          >
            <Search onArtistSelect={handleArtistSelect} />

            <div className="text-center">
              <Button
                variant="outline"
                onClick={() => {
                  const popularSection =
                    document.getElementById("popular-artists");
                  popularSection?.scrollIntoView({ behavior: "smooth" });
                }}
                className="text-sm"
              >
                Browse Popular Artists Below
              </Button>
            </div>
          </motion.div>
        )}

        {selectedArtist && (
          <motion.div
            key="game"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="w-full"
          >
            <Game selectedArtist={selectedArtist} onGameEnd={handleGameEnd} />
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
