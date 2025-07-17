"use client";

import { useState } from "react";
import { Artist } from "@/types";
import Game from "@/components/Game";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { ArrowLeft } from "lucide-react";
import { useRouter } from "next/navigation";

interface ArtistGameClientProps {
  artist: Artist;
}

export default function ArtistGameClient({ artist }: ArtistGameClientProps) {
  const [showGame, setShowGame] = useState(false);
  const router = useRouter();

  const handleGameEnd = () => {
    setShowGame(false);
  };

  const handleBackToHome = () => {
    router.push("/");
  };

  if (showGame) {
    return (
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="w-full flex flex-col items-center"
      >
        <Button
          variant="ghost"
          size="sm"
          onClick={handleGameEnd}
          className="self-start mb-4"
        >
          <ArrowLeft className="w-4 h-4 mr-2" />
          Back to Artist Info
        </Button>
        <Game selectedArtist={artist} onGameEnd={handleGameEnd} />
      </motion.div>
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="w-full max-w-md space-y-6 text-center"
    >
      {artist.imageUrl && (
        <motion.div
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ delay: 0.2 }}
          className="relative w-32 h-32 mx-auto rounded-full overflow-hidden"
        >
          <img
            src={artist.imageUrl}
            alt={artist.name}
            className="w-full h-full object-cover"
          />
        </motion.div>
      )}

      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        className="space-y-4"
      >
        <div className="flex flex-wrap justify-center gap-2">
          {artist.genres.map((genre) => (
            <span
              key={genre}
              className="px-3 py-1 bg-primary/10 text-primary rounded-full text-sm capitalize"
            >
              {genre}
            </span>
          ))}
        </div>

        <p className="text-muted-foreground">
          Ready to test your {artist.name} knowledge? Listen to song clips and
          guess as quickly as possible!
        </p>

        <div className="space-y-3">
          <Button
            onClick={() => setShowGame(true)}
            size="lg"
            className="w-full"
          >
            Start Game
          </Button>

          <Button
            variant="outline"
            onClick={handleBackToHome}
            className="w-full"
          >
            Choose Different Artist
          </Button>
        </div>
      </motion.div>
    </motion.div>
  );
}
