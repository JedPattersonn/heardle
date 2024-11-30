"use client";

import { useState, useEffect, useRef } from "react";
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
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Progress } from "./ui/progress";
import { motion } from "framer-motion";
import { Card, CardHeader, CardContent } from "./ui/card";
import Image from "next/image";

interface GameProps {
  selectedArtist: Artist | null;
  onGameEnd: () => void;
}

const ScoreDisplay = ({ score }: { score: number }) => (
  <div className="flex items-center justify-center space-x-2">
    <motion.div
      key={score}
      initial={{ scale: 1.2, opacity: 0 }}
      animate={{ scale: 1, opacity: 1 }}
      className="text-2xl font-bold text-primary"
    >
      {score}
    </motion.div>
    <span className="text-lg font-medium text-muted-foreground">points</span>
  </div>
);

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
  });
  const [guess, setGuess] = useState("");
  const [open, setOpen] = useState(false);
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const audioTimeoutRef = useRef<NodeJS.Timeout>();
  const [isStarting, setIsStarting] = useState(true);
  const [feedback, setFeedback] = useState<{
    show: boolean;
    isCorrect: boolean;
    song: Song | null;
  }>({ show: false, isCorrect: false, song: null });
  const [error, setError] = useState<string | null>(null);

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
    if (selectedArtist) {
      fetchSongs();
    }
    return () => {
      if (audioRef.current) {
        audioRef.current.pause();
        audioRef.current.src = "";
      }
    };
  }, [selectedArtist, difficulty]);

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
        playNextSong(filteredSongs);
      } else {
        throw new Error("Invalid response format");
      }
    } catch (error) {
      console.error("Failed to fetch songs:", error);
      setError("Failed to load songs. Please try again later.");
    }
  };

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

      await new Promise((resolve) => {
        if (!audioRef.current) return;
        audioRef.current.oncanplaythrough = resolve;
        audioRef.current.load();
      });

      await audioRef.current.play();

      audioTimeoutRef.current = setTimeout(() => {
        if (audioRef.current) {
          audioRef.current.pause();
        }
      }, duration * 1000);
    } catch (error) {
      console.error("Audio playback error:", error);
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
      setGameState((prev) => ({ ...prev, isPlaying: false }));
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
    }));

    if (nextSong.attributes?.previews?.[0]?.url) {
      await loadAndPlayAudio(nextSong.attributes.previews[0].url, 1);
    }
  };

  const handleGuess = (e: React.FormEvent) => {
    e.preventDefault();
    if (!gameState.currentSong?.attributes?.name) return;

    const isCorrect =
      guess.toLowerCase() ===
      gameState.currentSong.attributes.name.toLowerCase();

    if (isCorrect) {
      const attemptScore = Math.max(5 - gameState.guessAttempts, 1);
      setFeedback({
        show: true,
        isCorrect: true,
        song: gameState.currentSong,
      });
      setGameState((prev) => ({
        ...prev,
        score: prev.score + attemptScore,
      }));
    } else {
      if (gameState.guessAttempts < 4) {
        setGameState((prev) => ({
          ...prev,
          guessAttempts: prev.guessAttempts + 1,
        }));
        playCurrentSong();
      } else {
        setFeedback({
          show: true,
          isCorrect: false,
          song: gameState.currentSong,
        });
      }
    }
  };

  const handleSkip = () => {
    if (gameState.guessAttempts < 4) {
      const newAttempts = gameState.guessAttempts + 1;
      setGameState((prev) => ({
        ...prev,
        guessAttempts: newAttempts,
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
      setFeedback({
        show: true,
        isCorrect: false,
        song: gameState.currentSong,
      });
    }
  };

  const handleNextSong = () => {
    setFeedback({ show: false, isCorrect: false, song: null });
    setGuess("");
    setOpen(false);
    playNextSong();
  };

  const handleRelisten = () => {
    playCurrentSong();
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

  if (!songs?.length) {
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
              to guess the song titles!
            </motion.p>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.5 }}
              className="space-y-4"
            >
              <div className="flex flex-col space-y-2">
                <label className="text-sm font-medium">
                  Select Difficulty:
                </label>
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
                <p className="text-xs text-muted-foreground mt-2">
                  {difficulty === "easy" &&
                    "Most popular songs - perfect for casual fans"}
                  {difficulty === "medium" &&
                    "Includes popular songs plus some deeper cuts"}
                  {difficulty === "hard" &&
                    "All songs - from hits to rare tracks"}
                </p>
              </div>
              <Button
                onClick={() => {
                  setIsStarting(false);
                  fetchSongs();
                }}
                className="w-full"
                size="lg"
              >
                Start Game
              </Button>
            </motion.div>
          </CardContent>
        </Card>
      </motion.div>
    );
  }

  const isGameOver = !songs.some(
    (song) => song.id !== gameState.currentSong?.id
  );
  const currentDuration = gameState.guessAttempts + 1;
  const nextDuration = currentDuration < 5 ? currentDuration + 1 : null;

  return (
    <>
      <style jsx global>{`
        @keyframes success {
          0% {
            transform: scale(1);
          }
          50% {
            transform: scale(1.02);
          }
          100% {
            transform: scale(1);
          }
        }
      `}</style>
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mt-8 w-full max-w-md"
      >
        <Card className="relative">
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
            <ScoreDisplay score={gameState.score} />
          </CardHeader>

          <CardContent className="space-y-6">
            {gameState.currentSong && (
              <>
                <audio ref={audioRef} />
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="space-y-6"
                >
                  <Progress
                    value={(currentDuration / 5) * 100}
                    className="w-full"
                  />

                  <div className="flex justify-between items-center text-sm">
                    <span>Current: {currentDuration}s</span>
                    {nextDuration && <span>Next: {nextDuration}s</span>}
                  </div>

                  <div className="flex space-x-2">
                    <Button
                      variant="outline"
                      onClick={handleRelisten}
                      className="flex-1"
                    >
                      <Repeat className="w-4 h-4 mr-2" />
                      Listen Again
                    </Button>
                    <Button
                      variant={currentDuration >= 5 ? "destructive" : "outline"}
                      onClick={handleSkip}
                      className="flex-1"
                    >
                      {currentDuration >= 5 ? (
                        <>
                          <SkipForward className="w-4 h-4 mr-2" />I Give Up
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

            {feedback.show && feedback.song && (
              <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
                className="absolute inset-0 flex items-center justify-center bg-background/95 backdrop-blur-sm z-10"
              >
                <div className="text-center space-y-4 p-6">
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
                    <p className="text-lg">{feedback.song.attributes.name}</p>
                    {feedback.isCorrect && (
                      <p className="text-sm text-green-500">
                        +{Math.max(5 - gameState.guessAttempts, 1)} points
                      </p>
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

            {isGameOver ? (
              <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                className="text-center space-y-4"
              >
                <h3 className="text-lg font-bold">Game Over!</h3>
                <p>Final Score: {gameState.score}</p>
                <Button onClick={onGameEnd}>Play Again</Button>
              </motion.div>
            ) : (
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
                      className="w-full justify-between"
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
                <Button type="submit" className="w-full">
                  Submit Guess
                </Button>
              </motion.form>
            )}
          </CardContent>
        </Card>
      </motion.div>
    </>
  );
}
