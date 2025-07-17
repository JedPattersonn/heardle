"use client";

import { useState } from "react";
import { Artist } from "@/types";
import Game from "@/components/Game";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { ArrowLeft, Music, Trophy, Zap, Clock } from "lucide-react";
import { useRouter } from "next/navigation";

interface ArtistGameClientProps {
  artist: Artist;
}

const FeatureHighlight = ({
  icon,
  title,
  description,
}: {
  icon: React.ReactNode;
  title: string;
  description: string;
}) => (
  <motion.div
    initial={{ opacity: 0, x: -20 }}
    animate={{ opacity: 1, x: 0 }}
    className="flex items-start gap-3 p-3 bg-muted/30 rounded-lg"
  >
    <div className="flex-shrink-0 w-8 h-8 bg-primary/10 rounded-lg flex items-center justify-center">
      {icon}
    </div>
    <div>
      <h4 className="font-medium text-sm">{title}</h4>
      <p className="text-xs text-muted-foreground">{description}</p>
    </div>
  </motion.div>
);

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
      className="w-full max-w-3xl space-y-8 text-center"
    >
      {/* Artist Header */}
      <div className="space-y-6">
        {artist.imageUrl && (
          <motion.div
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ delay: 0.2 }}
            className="relative w-40 h-40 mx-auto rounded-full overflow-hidden shadow-2xl"
          >
            <img
              src={artist.imageUrl}
              alt={artist.name}
              className="w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent" />
          </motion.div>
        )}

        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="space-y-4"
        >
          <h1 className="text-4xl font-bold bg-gradient-to-r from-primary to-primary/60 bg-clip-text text-transparent">
            {artist.name}
          </h1>

          <div className="flex flex-wrap justify-center gap-2">
            {artist.genres.map((genre) => (
              <span
                key={genre}
                className="px-4 py-2 bg-gradient-to-r from-primary/10 to-primary/20 text-primary rounded-full text-sm font-medium border border-primary/20 capitalize"
              >
                {genre}
              </span>
            ))}
          </div>

          <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
            Ready to test your {artist.name} knowledge? Listen to progressive
            song clips, guess quickly for bonus points, and build impressive
            streaks!
          </p>
        </motion.div>
      </div>

      {/* Game Features */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4 }}
        className="space-y-6"
      >
        <h2 className="text-2xl font-bold">How It Works</h2>
        <div className="grid md:grid-cols-2 gap-4 max-w-3xl mx-auto">
          <FeatureHighlight
            icon={<Music className="w-4 h-4 text-purple-500" />}
            title="Progressive Reveal"
            description="Start with 1 second clips that get longer with each attempt"
          />
          <FeatureHighlight
            icon={<Trophy className="w-4 h-4 text-yellow-500" />}
            title="Smart Scoring"
            description="Earn more points for quick guesses and correct answers"
          />
          <FeatureHighlight
            icon={<Zap className="w-4 h-4 text-orange-500" />}
            title="Streak Multipliers"
            description="Chain correct answers for exponential score growth"
          />
          <FeatureHighlight
            icon={<Clock className="w-4 h-4 text-blue-500" />}
            title="Speed Bonuses"
            description="Lightning-fast guesses under 3 seconds earn extra points"
          />
        </div>
      </motion.div>

      {/* Call to Action */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.5 }}
        className="space-y-6"
      >
        <div className="bg-gradient-to-r from-primary/5 via-primary/10 to-primary/5 border border-primary/20 rounded-2xl p-8 space-y-4">
          <h3 className="text-xl font-bold">Ready to Begin?</h3>
          <p className="text-muted-foreground">
            Jump into the game and start building your music knowledge score.
            With progressive difficulty and enhanced audio visualization,
            challenge yourself to get every song right!
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center max-w-md mx-auto">
            <Button
              onClick={() => setShowGame(true)}
              size="lg"
              className="flex-1 bg-gradient-to-r from-primary to-primary/80 hover:from-primary/90 hover:to-primary/70 shadow-lg hover:shadow-xl transition-all duration-200"
            >
              <Music className="w-5 h-5 mr-2" />
              Start Playing
            </Button>

            <Button
              variant="outline"
              onClick={handleBackToHome}
              size="lg"
              className="flex-1"
            >
              <ArrowLeft className="w-5 h-5 mr-2" />
              Choose Different Artist
            </Button>
          </div>
        </div>

        {/* Quick Stats */}
        <div className="grid grid-cols-3 gap-4 max-w-md mx-auto text-center">
          <div className="space-y-1">
            <div className="text-2xl font-bold text-primary">5</div>
            <div className="text-xs text-muted-foreground">Max Attempts</div>
          </div>
          <div className="space-y-1">
            <div className="text-2xl font-bold text-primary">3</div>
            <div className="text-xs text-muted-foreground">
              Difficulty Levels
            </div>
          </div>
          <div className="space-y-1">
            <div className="text-2xl font-bold text-primary">∞</div>
            <div className="text-xs text-muted-foreground">Songs Available</div>
          </div>
        </div>
      </motion.div>
    </motion.div>
  );
}
