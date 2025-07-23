"use client";

import { useState, useEffect, useRef, useCallback } from "react";
import { Artist, Song, GameState } from "@/types";
import { Button } from "./ui/button";
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "./ui/command";
import { Popover, PopoverContent, PopoverTrigger } from "./ui/popover";
import {
  Check,
  ChevronsUpDown,
  Music,
  SkipForward,
  Repeat,
  ArrowLeft,
  X,
  Loader2,
  Trophy,
  Zap,
  Clock,
  Volume2,
  Pause,
  Play,
  Star,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Progress } from "./ui/progress";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardHeader, CardContent } from "./ui/card";
import Image from "next/image";
import Confetti, { MiniConfetti } from "./ui/confetti";
import posthog from "posthog-js";
import { track } from "@vercel/analytics/react";

interface GameProps {
  selectedArtist: Artist | null;
  onGameEnd: () => void;
}

const ScoreDisplay = ({
  score,
  streak,
  timeBonus,
}: {
  score: number;
  streak: number;
  timeBonus: boolean;
}) => (
  <div className="flex items-center justify-center space-x-4">
    <motion.div
      key={score}
      initial={{ scale: 1.2, opacity: 0 }}
      animate={{ scale: 1, opacity: 1 }}
      className="text-2xl font-bold text-primary flex items-center gap-2"
    >
      <Trophy className="w-6 h-6" />
      {score}
    </motion.div>

    {streak > 1 && (
      <motion.div
        initial={{ scale: 0 }}
        animate={{ scale: 1 }}
        className="flex items-center gap-1 bg-orange-500/20 text-orange-500 px-2 py-1 rounded-full text-sm font-medium"
      >
        <Zap className="w-4 h-4" />
        {streak}x streak
      </motion.div>
    )}

    {timeBonus && (
      <motion.div
        initial={{ scale: 0, rotate: -180 }}
        animate={{ scale: 1, rotate: 0 }}
        className="flex items-center gap-1 bg-green-500/20 text-green-500 px-2 py-1 rounded-full text-sm font-medium"
      >
        <Clock className="w-4 h-4" />
        Speed Bonus!
      </motion.div>
    )}
  </div>
);

const AudioVisualizer = ({
  isPlaying,
  audioRef,
}: {
  isPlaying: boolean;
  audioRef: React.RefObject<HTMLAudioElement>;
}) => {
  const [audioData, setAudioData] = useState<number[]>(new Array(32).fill(0));
  const animationRef = useRef<number>();
  const analyserRef = useRef<AnalyserNode | null>(null);
  const dataArrayRef = useRef<Uint8Array | null>(null);

  useEffect(() => {
    // Try to set up real audio analysis
    if (audioRef.current && isPlaying) {
      try {
        const audioContext = new (window.AudioContext ||
          (window as any).webkitAudioContext)();
        const source = audioContext.createMediaElementSource(audioRef.current);
        const analyser = audioContext.createAnalyser();

        analyser.fftSize = 64;
        const bufferLength = analyser.frequencyBinCount;
        const dataArray = new Uint8Array(bufferLength);

        source.connect(analyser);
        analyser.connect(audioContext.destination);

        analyserRef.current = analyser;
        dataArrayRef.current = dataArray;
      } catch (error) {
        console.log("Real audio analysis not available, using simulation");
      }
    }

    if (!isPlaying) {
      // Smooth fade to zero
      const fadeOut = () => {
        setAudioData((prev) => prev.map((val) => Math.max(0, val * 0.85)));
        if (audioData.some((val) => val > 1)) {
          animationRef.current = requestAnimationFrame(fadeOut);
        }
      };
      fadeOut();
      return;
    }

    const animate = () => {
      if (analyserRef.current && dataArrayRef.current) {
        // Real audio analysis
        analyserRef.current.getByteFrequencyData(dataArrayRef.current);
        const normalizedData = Array.from(dataArrayRef.current).map(
          (val) => (val / 255) * 100
        );
        setAudioData(normalizedData);
      } else {
        // Enhanced simulation with more realistic patterns
        setAudioData((prev) =>
          prev.map((_, index) => {
            const baseFreq =
              Math.sin(Date.now() * 0.01 + index * 0.5) * 50 + 50;
            const randomness = (Math.random() - 0.5) * 30;
            const wave = Math.sin(Date.now() * 0.005 + index * 0.3) * 20;
            return Math.max(5, Math.min(95, baseFreq + randomness + wave));
          })
        );
      }

      animationRef.current = requestAnimationFrame(animate);
    };

    animate();

    return () => {
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current);
      }
    };
  }, [isPlaying]);

  return (
    <div className="relative h-20 bg-gradient-to-t from-primary/10 via-primary/5 to-transparent rounded-lg p-3 overflow-hidden">
      {/* Background glow effect */}
      <div className="absolute inset-0 bg-gradient-to-r from-blue-500/10 via-purple-500/10 to-pink-500/10 rounded-lg" />

      <div className="relative flex items-end justify-center gap-1 h-full">
        {audioData.map((height, index) => (
          <motion.div
            key={index}
            className={cn(
              "w-2 rounded-full relative",
              isPlaying
                ? "bg-gradient-to-t from-primary via-primary/80 to-primary/60"
                : "bg-primary/20"
            )}
            animate={{
              height: `${Math.max(height * 0.6, 8)}%`,
              opacity: isPlaying ? 0.8 + height / 400 : 0.3,
            }}
            transition={{
              duration: 0.1,
              ease: "easeOut",
            }}
          >
            {/* Glow effect for taller bars */}
            {height > 60 && isPlaying && (
              <motion.div
                className="absolute inset-0 bg-primary/40 rounded-full blur-sm"
                animate={{
                  opacity: (height - 60) / 40,
                }}
              />
            )}
          </motion.div>
        ))}
      </div>

      {/* Sound waves effect */}
      {isPlaying && (
        <div className="absolute inset-0 pointer-events-none">
          {[...Array(3)].map((_, i) => (
            <motion.div
              key={i}
              className="absolute inset-0 border border-primary/20 rounded-lg"
              animate={{
                scale: [1, 1.1, 1],
                opacity: [0.3, 0, 0.3],
              }}
              transition={{
                duration: 2,
                delay: i * 0.6,
                repeat: Infinity,
                ease: "easeInOut",
              }}
            />
          ))}
        </div>
      )}
    </div>
  );
};

export default function Game({ selectedArtist, onGameEnd }: GameProps) {
  const [songs, setSongs] = useState<Song[]>([]);
  const [difficulty, setDifficulty] = useState<"easy" | "medium" | "hard">(
    "medium"
  );
  const [gameState, setGameState] = useState<GameState>({
    currentSong: null,
    isPlaying: false,
    currentTime: 0,
    maxTime: 1,
    guessAttempts: 0,
    score: 0,
    streak: 0,
    bestStreak: 0,
    songsCompleted: 0,
    correctGuesses: 0,
    totalGuesses: 0,
    gameStartTime: 0,
    roundStartTime: 0,
    timeBonus: false,
    perfectGame: true,
  });
  const [guess, setGuess] = useState("");
  const [open, setOpen] = useState(false);
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const audioTimeoutRef = useRef<NodeJS.Timeout>();
  const [isStarting, setIsStarting] = useState(true);
  const [gamePhase, setGamePhase] = useState<
    "setup" | "playing" | "feedback" | "complete"
  >("setup");
  const [feedback, setFeedback] = useState<{
    show: boolean;
    isCorrect: boolean;
    song: Song | null;
    points: number;
    bonusPoints: number;
    guessTime: number;
  }>({
    show: false,
    isCorrect: false,
    song: null,
    points: 0,
    bonusPoints: 0,
    guessTime: 0,
  });
  const [error, setError] = useState<string | null>(null);
  const [confettiTrigger, setConfettiTrigger] = useState(false);
  const [miniConfettiTrigger, setMiniConfettiTrigger] = useState(false);

  useEffect(() => {
    return () => {
      if (audioTimeoutRef.current) {
        clearTimeout(audioTimeoutRef.current);
      }
      if (audioRef.current) {
        audioRef.current.pause();
        audioRef.current.src = "";
      }
    };
  }, []);

  useEffect(() => {
    if (selectedArtist && gamePhase === "playing") {
      fetchSongs();
    }
    return () => {
      if (audioRef.current) {
        audioRef.current.pause();
        audioRef.current.src = "";
      }
    };
  }, [selectedArtist, difficulty, gamePhase]);

  const fetchSongs = async () => {
    try {
      const response = await fetch(`/api/songs?artistId=${selectedArtist!.id}`);
      if (!response.ok) {
        throw new Error(`Failed to fetch songs: ${response.statusText}`);
      }
      const data = await response.json();
      if (Array.isArray(data)) {
        const filteredSongs = data.filter((song) => {
          if (difficulty === "easy") return song.difficulty === "easy";
          if (difficulty === "medium")
            return ["easy", "medium"].includes(song.difficulty);
          return true;
        });
        setSongs(filteredSongs);
        if (filteredSongs.length > 0) {
          playNextSong(filteredSongs);
        }
      } else {
        throw new Error("Invalid response format");
      }
    } catch (error) {
      console.error("Failed to fetch songs:", error);
      setError("Failed to load songs. Please try again later.");
    }
  };

  const calculateScore = useCallback(
    (attempts: number, guessTime: number, isCorrect: boolean) => {
      if (!isCorrect)
        return { basePoints: 0, bonusPoints: 0, timeBonus: false };

      let basePoints = Math.max(6 - attempts, 1);
      let bonusPoints = 0;
      let timeBonus = false;

      // Time bonus for quick guesses (under 3 seconds)
      if (guessTime < 3000) {
        bonusPoints += 2;
        timeBonus = true;
      }

      // Streak multiplier
      const streakMultiplier =
        gameState.streak > 0 ? Math.min(1 + gameState.streak * 0.1, 3) : 1;
      basePoints = Math.floor(basePoints * streakMultiplier);

      return { basePoints, bonusPoints, timeBonus };
    },
    [gameState.streak]
  );

  const loadAndPlayAudio = async (url: string, duration: number) => {
    if (!audioRef.current) return;

    if (audioTimeoutRef.current) {
      clearTimeout(audioTimeoutRef.current);
    }
    audioRef.current.pause();
    audioRef.current.src = "";

    try {
      audioRef.current.src = url;
      audioRef.current.currentTime = 0;
      audioRef.current.volume = 0;

      await new Promise((resolve) => {
        if (!audioRef.current) return;
        audioRef.current.oncanplaythrough = resolve;
        audioRef.current.load();
      });

      // Smooth fade in
      await audioRef.current.play();
      setGameState((prev) => ({ ...prev, isPlaying: true }));

      // Fade in animation
      let volume = 0;
      const fadeInterval = setInterval(() => {
        volume += 0.05;
        if (audioRef.current && volume >= 0.7) {
          audioRef.current.volume = 0.7;
          clearInterval(fadeInterval);
        } else if (audioRef.current) {
          audioRef.current.volume = volume;
        }
      }, 50);

      audioTimeoutRef.current = setTimeout(() => {
        if (audioRef.current) {
          // Fade out
          let volume = audioRef.current.volume;
          const fadeOutInterval = setInterval(() => {
            volume -= 0.1;
            if (audioRef.current && volume <= 0) {
              audioRef.current.pause();
              audioRef.current.volume = 0;
              setGameState((prev) => ({ ...prev, isPlaying: false }));
              clearInterval(fadeOutInterval);
            } else if (audioRef.current) {
              audioRef.current.volume = volume;
            }
          }, 50);
        }
      }, duration * 1000);
    } catch (error) {
      console.error("Audio playback error:", error);
      setGameState((prev) => ({ ...prev, isPlaying: false }));
    }
  };

  const playCurrentSong = async () => {
    if (!gameState.currentSong?.attributes?.previews?.[0]?.url) return;
    const playDuration = gameState.guessAttempts + 1;
    await loadAndPlayAudio(
      gameState.currentSong.attributes.previews[0].url,
      playDuration
    );
  };

  const playNextSong = async (availableSongs: Song[] = songs) => {
    if (!availableSongs?.length) return;

    const unplayedSongs = availableSongs.filter(
      (song) => song.id !== gameState.currentSong?.id
    );

    if (!unplayedSongs.length) {
      handleGameComplete();
      return;
    }

    const randomIndex = Math.floor(Math.random() * unplayedSongs.length);
    const nextSong = unplayedSongs[randomIndex];

    setGameState((prev) => ({
      ...prev,
      currentSong: nextSong,
      isPlaying: true,
      currentTime: 0,
      guessAttempts: 0,
      roundStartTime: Date.now(),
    }));

    if (nextSong.attributes?.previews?.[0]?.url) {
      await loadAndPlayAudio(nextSong.attributes.previews[0].url, 1);
    }

    setGamePhase("playing");
  };

  const handleGuess = (e: React.FormEvent) => {
    e.preventDefault();
    if (!gameState.currentSong?.attributes?.name || !guess) return;

    const guessTime = Date.now() - gameState.roundStartTime;
    const isCorrect =
      guess.toLowerCase() ===
      gameState.currentSong.attributes.name.toLowerCase();

    const { basePoints, bonusPoints, timeBonus } = calculateScore(
      gameState.guessAttempts,
      guessTime,
      isCorrect
    );

    const totalPoints = basePoints + bonusPoints;

    if (isCorrect) {
      const newStreak = gameState.streak + 1;

      setGameState((prev) => ({
        ...prev,
        score: prev.score + totalPoints,
        streak: newStreak,
        bestStreak: Math.max(prev.bestStreak, newStreak),
        correctGuesses: prev.correctGuesses + 1,
        totalGuesses: prev.totalGuesses + 1,
        songsCompleted: prev.songsCompleted + 1,
        timeBonus,
      }));

      // Trigger confetti for special achievements
      if (newStreak >= 5 || timeBonus || bonusPoints > 0) {
        setConfettiTrigger(true);
        setTimeout(() => setConfettiTrigger(false), 100);
      } else {
        setMiniConfettiTrigger(true);
        setTimeout(() => setMiniConfettiTrigger(false), 100);
      }

      setFeedback({
        show: true,
        isCorrect: true,
        song: gameState.currentSong,
        points: basePoints,
        bonusPoints,
        guessTime,
      });
    } else {
      // Wrong answer - show feedback immediately and let user move on
      setGameState((prev) => ({
        ...prev,
        streak: 0,
        totalGuesses: prev.totalGuesses + 1,
        songsCompleted: prev.songsCompleted + 1,
        perfectGame: false,
      }));

      setFeedback({
        show: true,
        isCorrect: false,
        song: gameState.currentSong,
        points: 0,
        bonusPoints: 0,
        guessTime,
      });
    }

    // Clear timeouts
    if (audioTimeoutRef.current) {
      clearTimeout(audioTimeoutRef.current);
    }

    setGamePhase("feedback");
  };

  const handleSkip = () => {
    if (gameState.guessAttempts < 4) {
      const newAttempts = gameState.guessAttempts + 1;
      setGameState((prev) => ({
        ...prev,
        guessAttempts: newAttempts,
        perfectGame: false,
      }));
      if (gameState.currentSong?.attributes?.previews?.[0]?.url) {
        setTimeout(() => {
          loadAndPlayAudio(
            gameState.currentSong!.attributes.previews[0].url,
            newAttempts + 1
          );
        }, 0);
      }
    } else {
      // Final skip - show answer
      setGameState((prev) => ({
        ...prev,
        streak: 0,
        songsCompleted: prev.songsCompleted + 1,
        perfectGame: false,
      }));

      setFeedback({
        show: true,
        isCorrect: false,
        song: gameState.currentSong,
        points: 0,
        bonusPoints: 0,
        guessTime: 0,
      });
      setGamePhase("feedback");
    }
  };

  const handleNextSong = () => {
    setFeedback({
      show: false,
      isCorrect: false,
      song: null,
      points: 0,
      bonusPoints: 0,
      guessTime: 0,
    });
    setGuess("");
    setOpen(false);
    playNextSong();
  };

  const handleGameComplete = () => {
    setGamePhase("complete");
    if (audioRef.current) {
      audioRef.current.pause();
    }

    // Trigger special confetti for perfect games
    if (gameState.perfectGame && gameState.correctGuesses > 0) {
      setTimeout(() => {
        setConfettiTrigger(true);
        setTimeout(() => setConfettiTrigger(false), 100);
      }, 500);
    }
  };

  const handleRelisten = () => {
    playCurrentSong();
  };

  const handleStartGame = () => {
    if (process.env.NODE_ENV === "production") {
      posthog.capture("game_started", {
        artist_id: selectedArtist?.id,
        artist_name: selectedArtist?.name,
      });
    }

    setGameState((prev) => ({
      ...prev,
      gameStartTime: Date.now(),
      roundStartTime: Date.now(),
    }));
    setIsStarting(false);
    setGamePhase("playing");
    fetchSongs();
  };

  if (error) {
    return (
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mt-8 w-full max-w-md"
      >
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12 space-y-4">
            <X className="w-12 h-12 text-destructive" />
            <p className="text-lg font-medium text-destructive">{error}</p>
            <Button onClick={() => onGameEnd()}>Go Back</Button>
          </CardContent>
        </Card>
      </motion.div>
    );
  }

  if (!selectedArtist) {
    return (
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mt-8"
      >
        Search for an artist to start playing!
      </motion.div>
    );
  }

  if (!songs?.length && gamePhase === "playing") {
    return (
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mt-8 w-full max-w-md"
      >
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12 space-y-4">
            <motion.div
              animate={{
                rotate: 360,
                scale: [1, 1.1, 1],
              }}
              transition={{
                rotate: { duration: 2, repeat: Infinity, ease: "linear" },
                scale: { duration: 1, repeat: Infinity },
              }}
            >
              <Loader2 className="w-12 h-12 text-primary" />
            </motion.div>
            <p className="text-lg font-medium text-muted-foreground">
              Loading songs...
            </p>
          </CardContent>
        </Card>
      </motion.div>
    );
  }

  if (isStarting) {
    return (
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mt-8 w-full max-w-md"
      >
        <Card>
          <CardHeader className="text-center space-y-4">
            {selectedArtist.imageUrl && (
              <motion.div
                initial={{ scale: 0.9, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                transition={{ delay: 0.2 }}
                className="relative w-32 h-32 mx-auto rounded-full overflow-hidden"
              >
                <Image
                  src={selectedArtist.imageUrl}
                  alt={selectedArtist.name}
                  fill
                  className="object-cover"
                />
              </motion.div>
            )}
            <motion.h2
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3 }}
              className="text-2xl font-bold"
            >
              Ready to Play?
            </motion.h2>
          </CardHeader>
          <CardContent className="space-y-6">
            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.4 }}
              className="text-gray-600 dark:text-gray-400 text-center"
            >
              You&apos;ll hear snippets of songs by {selectedArtist.name}. Try
              to guess the song titles! Clips get longer with each attempt.
            </motion.p>

            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.5 }}
              className="space-y-4"
            >
              {/* Difficulty Selection */}
              <div className="space-y-3">
                <label className="text-sm font-medium">Difficulty:</label>
                <div className="grid grid-cols-3 gap-2">
                  <Button
                    variant={difficulty === "easy" ? "default" : "outline"}
                    onClick={() => setDifficulty("easy")}
                    className="w-full"
                  >
                    Easy
                  </Button>
                  <Button
                    variant={difficulty === "medium" ? "default" : "outline"}
                    onClick={() => setDifficulty("medium")}
                    className="w-full"
                  >
                    Medium
                  </Button>
                  <Button
                    variant={difficulty === "hard" ? "default" : "outline"}
                    onClick={() => setDifficulty("hard")}
                    className="w-full"
                  >
                    Hard
                  </Button>
                </div>
                <p className="text-xs text-muted-foreground text-center">
                  {difficulty === "easy" &&
                    "Most popular songs - perfect for casual fans"}
                  {difficulty === "medium" &&
                    "Includes popular songs plus some deeper cuts"}
                  {difficulty === "hard" &&
                    "All songs - from hits to rare tracks"}
                </p>
              </div>

              <Button onClick={handleStartGame} className="w-full" size="lg">
                Start Game
              </Button>
            </motion.div>
          </CardContent>
        </Card>
      </motion.div>
    );
  }

  if (gamePhase === "complete") {
    const accuracy =
      gameState.totalGuesses > 0
        ? (gameState.correctGuesses / gameState.totalGuesses) * 100
        : 0;
    const avgGuessTime =
      gameState.songsCompleted > 0
        ? (Date.now() - gameState.gameStartTime) /
          gameState.songsCompleted /
          1000
        : 0;

    return (
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="mt-8 w-full max-w-md"
      >
        <Card>
          <CardHeader className="text-center space-y-4">
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ type: "spring", bounce: 0.5, delay: 0.2 }}
              className="w-16 h-16 mx-auto rounded-full bg-gradient-to-r from-yellow-400 to-orange-500 flex items-center justify-center"
            >
              <Trophy className="w-8 h-8 text-white" />
            </motion.div>
            <h2 className="text-2xl font-bold">Game Complete!</h2>
            <ScoreDisplay
              score={gameState.score}
              streak={gameState.bestStreak}
              timeBonus={false}
            />
          </CardHeader>

          <CardContent className="space-y-6">
            <div className="grid grid-cols-2 gap-4 text-center">
              <div className="p-4 bg-muted/50 rounded-lg">
                <div className="text-2xl font-bold text-green-500">
                  {gameState.correctGuesses}
                </div>
                <div className="text-sm text-muted-foreground">Correct</div>
              </div>
              <div className="p-4 bg-muted/50 rounded-lg">
                <div className="text-2xl font-bold text-blue-500">
                  {accuracy.toFixed(1)}%
                </div>
                <div className="text-sm text-muted-foreground">Accuracy</div>
              </div>
              <div className="p-4 bg-muted/50 rounded-lg">
                <div className="text-2xl font-bold text-purple-500">
                  {gameState.bestStreak}
                </div>
                <div className="text-sm text-muted-foreground">Best Streak</div>
              </div>
              <div className="p-4 bg-muted/50 rounded-lg">
                <div className="text-2xl font-bold text-orange-500">
                  {avgGuessTime.toFixed(1)}s
                </div>
                <div className="text-sm text-muted-foreground">Avg Time</div>
              </div>
            </div>

            {gameState.perfectGame && gameState.correctGuesses > 0 && (
              <motion.div
                initial={{ scale: 0, rotate: -180 }}
                animate={{ scale: 1, rotate: 0 }}
                className="text-center p-4 bg-gradient-to-r from-yellow-500/20 to-orange-500/20 rounded-lg border border-yellow-500/30"
              >
                <Star className="w-8 h-8 text-yellow-500 mx-auto mb-2" />
                <div className="font-bold text-yellow-500">Perfect Game!</div>
                <div className="text-sm text-muted-foreground">
                  All correct on first try
                </div>
              </motion.div>
            )}

            <div className="flex gap-2">
              <Button onClick={handleStartGame} className="flex-1">
                Play Again
              </Button>
              <Button onClick={onGameEnd} variant="outline" className="flex-1">
                Change Artist
              </Button>
            </div>
          </CardContent>
        </Card>
      </motion.div>
    );
  }

  const currentDuration = gameState.guessAttempts + 1;
  const nextDuration = currentDuration < 5 ? currentDuration + 1 : null;

  return (
    <>
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mt-8 w-full max-w-md"
      >
        <Card className="relative overflow-hidden">
          <CardHeader className="text-center space-y-4">
            <Button
              variant="ghost"
              size="sm"
              onClick={onGameEnd}
              className="absolute left-4 top-4"
            >
              <ArrowLeft className="w-4 h-4 mr-2" />
              Change Artist
            </Button>

            {selectedArtist.imageUrl && (
              <div className="relative w-24 h-24 mx-auto rounded-full overflow-hidden">
                <Image
                  src={selectedArtist.imageUrl}
                  alt={selectedArtist.name}
                  fill
                  className="object-cover"
                />
              </div>
            )}

            <h2 className="text-2xl font-bold">{selectedArtist.name}</h2>
            <ScoreDisplay
              score={gameState.score}
              streak={gameState.streak}
              timeBonus={gameState.timeBonus}
            />
          </CardHeader>

          <CardContent className="space-y-6">
            {gameState.currentSong && (
              <>
                <audio ref={audioRef} crossOrigin="anonymous" />

                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="space-y-6"
                >
                  {/* Enhanced Audio Visualizer */}
                  <AudioVisualizer
                    isPlaying={gameState.isPlaying}
                    audioRef={audioRef}
                  />

                  {/* Progress Bar */}
                  <div className="space-y-2">
                    <Progress
                      value={(currentDuration / 5) * 100}
                      className="w-full h-3"
                    />
                    <div className="flex justify-between items-center text-sm">
                      <span className="flex items-center gap-1">
                        <Volume2 className="w-4 h-4" />
                        Current: {currentDuration}s
                      </span>
                      {nextDuration && <span>Next: {nextDuration}s</span>}
                    </div>
                  </div>

                  {/* Controls */}
                  <div className="flex space-x-2">
                    <Button
                      variant="outline"
                      onClick={handleRelisten}
                      className="flex-1"
                      disabled={gameState.isPlaying}
                    >
                      {gameState.isPlaying ? (
                        <Pause className="w-4 h-4 mr-2" />
                      ) : (
                        <Play className="w-4 h-4 mr-2" />
                      )}
                      {gameState.isPlaying ? "Playing..." : "Listen Again"}
                    </Button>
                    <Button
                      variant={currentDuration >= 5 ? "destructive" : "outline"}
                      onClick={handleSkip}
                      className="flex-1"
                    >
                      {currentDuration >= 5 ? (
                        <>
                          <X className="w-4 h-4 mr-2" />I Give Up
                        </>
                      ) : (
                        <>
                          <SkipForward className="w-4 h-4 mr-2" />
                          Skip (+{nextDuration}s)
                        </>
                      )}
                    </Button>
                  </div>
                </motion.div>
              </>
            )}

            {/* Feedback Overlay */}
            <AnimatePresence>
              {feedback.show && feedback.song && (
                <motion.div
                  initial={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.9 }}
                  className="absolute inset-0 flex items-center justify-center bg-background/95 backdrop-blur-sm z-10"
                >
                  <div className="text-center space-y-4 p-6 max-w-sm">
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ type: "spring", bounce: 0.5 }}
                      className="w-16 h-16 mx-auto rounded-full bg-white dark:bg-gray-800 flex items-center justify-center shadow-lg"
                    >
                      {feedback.isCorrect ? (
                        <Check className="w-8 h-8 text-green-500" />
                      ) : (
                        <X className="w-8 h-8 text-red-500" />
                      )}
                    </motion.div>

                    {feedback.song.attributes.artwork && (
                      <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="relative w-32 h-32 mx-auto rounded-lg overflow-hidden shadow-lg"
                      >
                        <Image
                          src={feedback.song.attributes.artwork.url.replace(
                            "{w}x{h}",
                            "300x300"
                          )}
                          alt={feedback.song.attributes.name}
                          fill
                          className="object-cover"
                        />
                      </motion.div>
                    )}

                    <motion.div
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: 0.2 }}
                      className="space-y-2"
                    >
                      <h3 className="text-xl font-bold">
                        {feedback.isCorrect ? "Correct!" : "Not quite..."}
                      </h3>
                      <p className="text-lg font-medium">
                        {feedback.song.attributes.name}
                      </p>

                      {feedback.isCorrect && (
                        <div className="space-y-1">
                          <p className="text-sm text-green-500 font-medium">
                            +{feedback.points} points
                          </p>
                          {feedback.bonusPoints > 0 && (
                            <p className="text-sm text-blue-500 font-medium">
                              +{feedback.bonusPoints} bonus points
                            </p>
                          )}
                          <p className="text-xs text-muted-foreground">
                            Guessed in {(feedback.guessTime / 1000).toFixed(1)}s
                          </p>
                        </div>
                      )}

                      <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        transition={{ delay: 0.4 }}
                      >
                        <Button
                          onClick={handleNextSong}
                          className="mt-4"
                          size="lg"
                        >
                          <SkipForward className="w-5 h-5 mr-2" />
                          Next Song
                        </Button>
                      </motion.div>
                    </motion.div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>

            {/* Guess Form */}
            {gamePhase === "playing" && (
              <motion.form
                onSubmit={handleGuess}
                className="space-y-4"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.2 }}
              >
                <Popover open={open} onOpenChange={setOpen}>
                  <PopoverTrigger asChild>
                    <Button
                      variant="outline"
                      role="combobox"
                      aria-expanded={open}
                      className="w-full justify-between h-12"
                    >
                      <span className="truncate flex-1 text-left">
                        {guess
                          ? songs.find(
                              (song) =>
                                song.attributes.name.toLowerCase() ===
                                guess.toLowerCase()
                            )?.attributes.name
                          : "Select a song..."}
                      </span>
                      <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
                    </Button>
                  </PopoverTrigger>
                  <PopoverContent className="w-full p-0" align="start">
                    <Command>
                      <CommandInput placeholder="Search songs..." />
                      <CommandList>
                        <CommandEmpty>No song found.</CommandEmpty>
                        <CommandGroup>
                          {songs
                            ?.filter(
                              (song, index, self) =>
                                index ===
                                self.findIndex(
                                  (s) =>
                                    s.attributes.name === song.attributes.name
                                )
                            )
                            .map((song) => (
                              <CommandItem
                                key={song.id}
                                value={song.attributes.name}
                                onSelect={(currentValue) => {
                                  setGuess(
                                    currentValue === guess ? "" : currentValue
                                  );
                                  setOpen(false);
                                }}
                              >
                                <Music className="mr-2 h-4 w-4" />
                                {song.attributes.name}
                                <Check
                                  className={cn(
                                    "ml-auto h-4 w-4",
                                    guess === song.attributes.name
                                      ? "opacity-100"
                                      : "opacity-0"
                                  )}
                                />
                              </CommandItem>
                            ))}
                        </CommandGroup>
                      </CommandList>
                    </Command>
                  </PopoverContent>
                </Popover>
                <Button
                  type="submit"
                  className="w-full h-12 text-lg"
                  disabled={!guess}
                >
                  Submit Guess
                </Button>
              </motion.form>
            )}
          </CardContent>
        </Card>
      </motion.div>

      {/* Confetti Effects */}
      <Confetti
        trigger={confettiTrigger}
        particleCount={gameState.streak >= 10 ? 80 : 50}
        colors={
          gameState.streak >= 10
            ? ["#FFD700", "#FFA500", "#FF6347", "#FF1493"]
            : undefined
        }
      />
      <MiniConfetti trigger={miniConfettiTrigger} />
    </>
  );
}
