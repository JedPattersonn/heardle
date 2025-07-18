"use client";

import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { 
  Search, 
  Plus, 
  Trash2, 
  Music, 
  ExternalLink,
  Settings,
  Database
} from "lucide-react";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import Image from "next/image";

interface AppleMusicArtist {
  appleId: string;
  name: string;
  imageUrl: string | null;
  genres: string[];
  appleMusicUrl: string;
}

interface DatabaseArtist {
  id: number;
  appleId: string;
  name: string;
  imageUrl: string | null;
  genres: string[];
  category: string | null;
  sortOrder: number;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

const CATEGORIES = [
  "featured",
  "trending",
  "hip-hop",
  "rock",
  "classics",
  "pop",
  "r&b",
  "country",
  "electronic",
  "jazz",
];

export default function AdminPage() {
  const [searchQuery, setSearchQuery] = useState("");
  const [searchResults, setSearchResults] = useState<AppleMusicArtist[]>([]);
  const [databaseArtists, setDatabaseArtists] = useState<DatabaseArtist[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const { toast } = useToast();

  useEffect(() => {
    fetchDatabaseArtists();
  }, []);

  const fetchDatabaseArtists = async () => {
    try {
      const response = await fetch("/api/admin/artists");
      if (response.ok) {
        const artists = await response.json();
        setDatabaseArtists(artists);
      }
    } catch (error) {
      console.error("Failed to fetch database artists:", error);
      toast({
        title: "Error",
        description: "Failed to fetch artists from database",
        variant: "destructive",
      });
    }
  };

  const searchAppleMusic = async () => {
    if (!searchQuery.trim()) return;

    setIsSearching(true);
    try {
      const response = await fetch(
        `/api/admin/search-apple-music?q=${encodeURIComponent(searchQuery)}`
      );
      if (response.ok) {
        const results = await response.json();
        setSearchResults(results);
      } else {
        throw new Error("Search failed");
      }
    } catch (error) {
      console.error("Search error:", error);
      toast({
        title: "Error",
        description: "Failed to search Apple Music",
        variant: "destructive",
      });
    } finally {
      setIsSearching(false);
    }
  };

  const addArtistToDatabase = async (
    artist: AppleMusicArtist,
    category: string,
    sortOrder: number = 0
  ) => {
    setIsLoading(true);
    try {
      const response = await fetch("/api/admin/artists", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          appleId: artist.appleId,
          name: artist.name,
          imageUrl: artist.imageUrl,
          genres: artist.genres,
          category,
          sortOrder,
        }),
      });

      if (response.ok) {
        toast({
          title: "Success",
          description: `Added ${artist.name} to database`,
        });
        fetchDatabaseArtists();
      } else {
        const error = await response.json();
        throw new Error(error.error || "Failed to add artist");
      }
    } catch (error: any) {
      console.error("Add artist error:", error);
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  };

  const removeArtistFromDatabase = async (artistId: number) => {
    setIsLoading(true);
    try {
      const response = await fetch(`/api/admin/artists/${artistId}`, {
        method: "DELETE",
      });

      if (response.ok) {
        toast({
          title: "Success",
          description: "Artist removed from database",
        });
        fetchDatabaseArtists();
      } else {
        throw new Error("Failed to remove artist");
      }
    } catch (error) {
      console.error("Remove artist error:", error);
      toast({
        title: "Error",
        description: "Failed to remove artist",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  };

  const isArtistInDatabase = (appleId: string) => {
    return databaseArtists.some((artist) => artist.appleId === appleId);
  };

  return (
    <div className="container mx-auto p-6 max-w-6xl">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold flex items-center gap-2">
          <Settings className="w-8 h-8" />
          Heardle Admin
        </h1>
        <p className="text-muted-foreground mt-2">
          Search Apple Music and manage your preset artists
        </p>
      </div>

      {/* Search Section */}
      <Card className="mb-8">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Search className="w-5 h-5" />
            Search Apple Music
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex gap-2">
            <Input
              placeholder="Search for artists..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && searchAppleMusic()}
              className="flex-1"
            />
            <Button 
              onClick={searchAppleMusic} 
              disabled={isSearching || !searchQuery.trim()}
            >
              {isSearching ? "Searching..." : "Search"}
            </Button>
          </div>

          {/* Search Results */}
          {searchResults.length > 0 && (
            <div className="space-y-4">
              <h3 className="text-lg font-semibold">Search Results</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {searchResults.map((artist) => (
                  <SearchResultCard
                    key={artist.appleId}
                    artist={artist}
                    isInDatabase={isArtistInDatabase(artist.appleId)}
                    onAdd={addArtistToDatabase}
                    isLoading={isLoading}
                  />
                ))}
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Database Artists Section */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Database className="w-5 h-5" />
            Database Artists ({databaseArtists.length})
          </CardTitle>
        </CardHeader>
        <CardContent>
          {databaseArtists.length === 0 ? (
            <p className="text-muted-foreground">No artists in database yet.</p>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {databaseArtists.map((artist) => (
                <DatabaseArtistCard
                  key={artist.id}
                  artist={artist}
                  onRemove={removeArtistFromDatabase}
                  isLoading={isLoading}
                />
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}

function SearchResultCard({
  artist,
  isInDatabase,
  onAdd,
  isLoading,
}: {
  artist: AppleMusicArtist;
  isInDatabase: boolean;
  onAdd: (artist: AppleMusicArtist, category: string) => void;
  isLoading: boolean;
}) {
  const [selectedCategory, setSelectedCategory] = useState("featured");

  return (
    <Card className="overflow-hidden">
      <div className="aspect-square relative">
        {artist.imageUrl ? (
          <Image
            src={artist.imageUrl}
            alt={artist.name}
            fill
            className="object-cover"
          />
        ) : (
          <div className="w-full h-full bg-muted flex items-center justify-center">
            <Music className="w-16 h-16 text-muted-foreground" />
          </div>
        )}
      </div>
      
      <CardContent className="p-4">
        <h3 className="font-semibold text-lg mb-2">{artist.name}</h3>
        
        <div className="flex flex-wrap gap-1 mb-3">
          {artist.genres.slice(0, 3).map((genre) => (
            <Badge key={genre} variant="secondary" className="text-xs">
              {genre}
            </Badge>
          ))}
        </div>

        <div className="space-y-2">
          <Select
            value={selectedCategory}
            onValueChange={setSelectedCategory}
            disabled={isInDatabase}
          >
            <SelectTrigger className="w-full">
              <SelectValue placeholder="Select category" />
            </SelectTrigger>
            <SelectContent>
              {CATEGORIES.map((category) => (
                <SelectItem key={category} value={category}>
                  {category.charAt(0).toUpperCase() + category.slice(1)}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          <div className="flex gap-2">
            <Button
              onClick={() => onAdd(artist, selectedCategory)}
              disabled={isInDatabase || isLoading}
              className="flex-1"
              size="sm"
            >
              <Plus className="w-4 h-4 mr-1" />
              {isInDatabase ? "Already Added" : "Add to DB"}
            </Button>
            
            <Button
              variant="outline"
              size="sm"
              asChild
            >
              <a 
                href={artist.appleMusicUrl} 
                target="_blank" 
                rel="noopener noreferrer"
              >
                <ExternalLink className="w-4 h-4" />
              </a>
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

function DatabaseArtistCard({
  artist,
  onRemove,
  isLoading,
}: {
  artist: DatabaseArtist;
  onRemove: (id: number) => void;
  isLoading: boolean;
}) {
  return (
    <Card className="overflow-hidden">
      <div className="aspect-square relative">
        {artist.imageUrl ? (
          <Image
            src={artist.imageUrl}
            alt={artist.name}
            fill
            className="object-cover"
          />
        ) : (
          <div className="w-full h-full bg-muted flex items-center justify-center">
            <Music className="w-16 h-16 text-muted-foreground" />
          </div>
        )}
      </div>
      
      <CardContent className="p-4">
        <h3 className="font-semibold text-lg mb-2">{artist.name}</h3>
        
        <div className="flex flex-wrap gap-1 mb-2">
          {artist.genres.slice(0, 3).map((genre) => (
            <Badge key={genre} variant="secondary" className="text-xs">
              {genre}
            </Badge>
          ))}
        </div>

        {artist.category && (
          <Badge className="mb-3" variant="outline">
            {artist.category}
          </Badge>
        )}

        <div className="flex gap-2">
          <Button
            onClick={() => onRemove(artist.id)}
            disabled={isLoading}
            variant="destructive"
            size="sm"
            className="flex-1"
          >
            <Trash2 className="w-4 h-4 mr-1" />
            Remove
          </Button>
        </div>
        
        <p className="text-xs text-muted-foreground mt-2">
          Added: {new Date(artist.createdAt).toLocaleDateString()}
        </p>
      </CardContent>
    </Card>
  );
}