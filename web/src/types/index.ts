export interface MusicKitInstance {
  api: {
    search: (term: string, options: SearchOptions) => Promise<SearchResponse>;
    song: (id: string) => Promise<Song>;
  };
  player: {
    play: () => Promise<void>;
    pause: () => void;
    seekToTime: (time: number) => Promise<void>;
    nowPlayingItem: Song | null;
  };
}

export interface SearchOptions {
  types: string[];
  limit: number;
}

export interface SearchResponse {
  artists: {
    data: Artist[];
  };
}

export interface Artist {
  id: string;
  name: string;
  imageUrl: string;
  genres: string[];
}

export interface Song {
  id: string;
  attributes: {
    name: string;
    artistName: string;
    albumName: string;
    artwork: {
      url: string;
    };
    durationInMillis: number;
    previews: {
      url: string;
    }[];
  };
  difficulty: "easy" | "medium" | "hard";
}

// Game types
export interface GameState {
  currentSong: Song | null;
  isPlaying: boolean;
  currentTime: number;
  maxTime: number;
  guessAttempts: number;
  score: number;
}

// Search types
export interface SearchState {
  query: string;
  results: Artist[];
  isLoading: boolean;
  error: string | null;
}
