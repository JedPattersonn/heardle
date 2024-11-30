"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Artist } from "@/types";
import Image from "next/image";
import { motion } from "framer-motion";
import { Search as SearchIcon, User } from "lucide-react";

interface SearchProps {
  onArtistSelect: (artist: Artist) => void;
}

export default function Search({ onArtistSelect }: SearchProps) {
  const [query, setQuery] = useState("");
  const [artists, setArtists] = useState<Artist[]>([]);
  const [isLoading, setIsLoading] = useState(false);

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!query.trim()) return;

    setIsLoading(true);
    try {
      const response = await fetch(
        `/api/search?q=${encodeURIComponent(query)}`
      );
      const data = await response.json();
      setArtists(data || []);
    } catch (error) {
      console.error("Search error:", error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      className="w-full max-w-md space-y-6"
    >
      <form onSubmit={handleSearch} className="relative">
        <Input
          type="text"
          placeholder="Search for an artist..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          className="w-full pr-24 h-12 text-lg"
        />
        <Button
          type="submit"
          disabled={isLoading}
          className="absolute right-1 top-1 bottom-1"
        >
          {isLoading ? (
            <motion.div
              animate={{ rotate: 360 }}
              transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
            >
              <SearchIcon className="w-5 h-5" />
            </motion.div>
          ) : (
            <SearchIcon className="w-5 h-5" />
          )}
        </Button>
      </form>

      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        className="space-y-2"
      >
        {isLoading ? (
          <div className="space-y-3">
            {[1, 2, 3].map((i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.1 }}
                className="w-full h-16 bg-gray-100 dark:bg-gray-800 rounded-lg animate-pulse"
              />
            ))}
          </div>
        ) : (
          artists.length > 0 && (
            <div className="space-y-3">
              {artists.map((artist, index) => (
                <motion.div
                  key={artist.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{
                    opacity: 1,
                    y: 0,
                    transition: { delay: index * 0.05 },
                  }}
                >
                  <Button
                    variant="outline"
                    className="w-full h-16 text-left flex items-center gap-4 p-3 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors rounded-lg group"
                    onClick={() => onArtistSelect(artist)}
                  >
                    {artist.imageUrl ? (
                      <div className="relative w-10 h-10 overflow-hidden rounded-full">
                        {artist.imageUrl ? (
                          <Image
                            src={artist.imageUrl}
                            alt={`${artist.name} profile`}
                            fill
                            className="object-cover group-hover:scale-110 transition-transform"
                          />
                        ) : (
                          <User className="w-6 h-6 text-gray-500" />
                        )}
                      </div>
                    ) : (
                      <div className="w-10 h-10 rounded-full bg-gray-200 dark:bg-gray-700 flex items-center justify-center">
                        <span className="text-gray-500">?</span>
                      </div>
                    )}
                    <div className="flex-1 min-w-0">
                      <div className="font-medium truncate">{artist.name}</div>
                      {artist.genres && (
                        <div className="text-sm text-gray-500 truncate">
                          {artist.genres.slice(0, 2).join(", ")}
                        </div>
                      )}
                    </div>
                  </Button>
                </motion.div>
              ))}
            </div>
          )
        )}
      </motion.div>
    </motion.div>
  );
}
