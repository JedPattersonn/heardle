import SwiftUI

// Helper to allow conditional shape types
struct AnyShape: Shape {
    private let _path: (CGRect) -> Path
    
    init<S: Shape>(_ shape: S) {
        _path = { rect in
            shape.path(in: rect)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

struct HomeView: View {
    @State private var searchText = ""
    @State private var searchResults: [Artist] = []
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var selectedArtist: Artist?
    @State private var showingGame = false
    @State private var showingSearch = false
    @State private var showingWelcome = !UserDefaults.standard.bool(forKey: "hasSeenWelcome")
    @State private var searchTask: Task<Void, Never>?
    @State private var popularArtists = PopularArtists()
    @State private var showingScoreboard = false
    
    private let apiService = APIService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Compact header
                compactHeader
                
                // Main content
                if showingSearch {
                    searchContent
                } else if popularArtists.isLoading {
                    loadingView
                } else if let error = popularArtists.error {
                    errorView(error)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Hero section
                            if let heroArtist = popularArtists.heroArtist {
                                HeroArtistCard(artist: heroArtist) { 
                                    selectArtist(heroArtist)
                                }
                                .padding(.top, 8)
                            }
                            
                            // Horizontal sections
                            ForEach(Array(popularArtists.categories.enumerated()), id: \.offset) { index, category in
                                HorizontalArtistSection(
                                    title: category.title,
                                    artists: category.artists,
                                    colorScheme: PopularArtists.CategoryColor.color(for: index)
                                ) { artist in
                                    selectArtist(artist)
                                }
                            }
                            
                            // Bottom spacing
                            Color.clear.frame(height: 20)
                        }
                    }
                    .refreshable {
                        await popularArtists.loadCategories()
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showingGame) {
                if let artist = selectedArtist {
                    GameView(artist: artist) {
                        showingGame = false
                        selectedArtist = nil
                    }
                }
            }
            .fullScreenCover(isPresented: $showingWelcome) {
                WelcomeView(isPresented: $showingWelcome)
                    .onDisappear {
                        UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
                    }
            }
            .sheet(isPresented: $showingScoreboard) {
                ScoreboardView()
            }
            .onAppear {
                Task {
                    await popularArtists.loadCategories()
                }
            }
        }
    }
    
    // Compact header like Spotify/Apple Music
    private var compactHeader: some View {
        VStack(spacing: 0) {
            HStack {
                // Small logo/icon
                HStack(spacing: 8) {
                    Image(systemName: "music.note.list")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Heardle")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    // Scoreboard icon
                    Button {
                        showingScoreboard = true
                    } label: {
                        Image(systemName: "trophy.fill")
                            .font(.title3)
                            .foregroundStyle(.yellow)
                    }
                    
                    // Search icon
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingSearch.toggle()
                            if !showingSearch {
                                searchText = ""
                                searchResults = []
                                searchError = nil
                            }
                        }
                    } label: {
                        Image(systemName: showingSearch ? "xmark" : "magnifyingglass")
                            .font(.title3)
                            .foregroundStyle(.primary)
                    }
                    .animation(.easeInOut(duration: 0.2), value: showingSearch)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(.regularMaterial)
            
            // Subtle divider
            if showingSearch {
                Divider()
                    .transition(.opacity)
            }
        }
    }
    
    // Search content view
    private var searchContent: some View {
        VStack(spacing: 0) {
            // Search bar
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField("Search artists...", text: $searchText)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            performSearch()
                        }
                        .onChange(of: searchText) { _, newValue in
                            if newValue.isEmpty {
                                searchResults = []
                                searchError = nil
                                searchTask?.cancel()
                                isSearching = false
                            } else {
                                performDebouncedSearch(query: newValue)
                            }
                        }
                    
                    if isSearching {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            searchResults = []
                            searchError = nil
                            searchTask?.cancel()
                            isSearching = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                
                if let error = searchError {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            
            // Search results
            if !searchResults.isEmpty {
                List(searchResults) { artist in
                    ArtistRowView(artist: artist) {
                        selectArtist(artist)
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            } else if !searchText.isEmpty && !isSearching {
                Spacer()
                ContentUnavailableView(
                    "No Artists Found",
                    systemImage: "person.crop.circle.badge.questionmark",
                    description: Text("Try searching for a different artist")
                )
                Spacer()
            } else {
                // Show popular searches or recent when no search text
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundStyle(.secondary)
                    
                    Text("Search for any artist")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("Find your favorite artists and start playing Heardle!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            }
        }
    }
    
    // Loading view
    private var loadingView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading artists...")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
    }
    
    // Error view
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "wifi.slash")
                .font(.system(size: 50))
                .foregroundStyle(.red)
            
            Text("Failed to load artists")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(error)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                Task {
                    await popularArtists.loadCategories()
                }
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
    }
    
    private func selectArtist(_ artist: Artist) {
        selectedArtist = artist
        showingGame = true
    }
    
    private func performDebouncedSearch(query: String) {
        // Cancel the previous search task
        searchTask?.cancel()
        
        // Create a new search task with debouncing
        searchTask = Task {
            // Wait for 500ms before searching
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            // Check if task was cancelled
            guard !Task.isCancelled else { return }
            
            // Perform the search
            await performSearchInternal(query: query)
        }
    }
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // Cancel debounced search and search immediately
        searchTask?.cancel()
        
        Task {
            await performSearchInternal(query: searchText)
        }
    }
    
    private func performSearchInternal(query: String) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        
        await MainActor.run {
            isSearching = true
            searchError = nil
        }
        
        do {
            let results = try await apiService.searchArtists(query: trimmedQuery)
            await MainActor.run {
                // Only update results if the query still matches current search text
                if trimmedQuery == self.searchText.trimmingCharacters(in: .whitespacesAndNewlines) {
                    self.searchResults = results
                    self.isSearching = false
                }
            }
        } catch {
            await MainActor.run {
                // Only update error if the query still matches current search text
                if trimmedQuery == self.searchText.trimmingCharacters(in: .whitespacesAndNewlines) {
                    self.searchError = error.localizedDescription
                    self.isSearching = false
                }
            }
        }
    }
}

struct ArtistRowView: View {
    let artist: Artist
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Artist/Playlist image with subtle gradient border
                ZStack {
                    if artist.isPlaylist == true {
                        // Square background for playlists
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)
                    } else {
                        // Circular background for artists
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)
                    }
                    
                    AsyncImage(url: URL(string: artist.imageUrl ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        if artist.isPlaylist == true {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.quaternary)
                                .overlay {
                                    Image(systemName: "music.note.list")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                }
                        } else {
                            Circle()
                                .fill(.quaternary)
                                .overlay {
                                    Image(systemName: "person.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                }
                        }
                    }
                    .frame(width: 58, height: 58)
                    .clipShape(artist.isPlaylist == true ? AnyShape(RoundedRectangle(cornerRadius: 6)) : AnyShape(Circle()))
                    
                    // Playlist indicator
                    if artist.isPlaylist == true {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "music.note.list")
                                    .font(.caption2)
                                    .foregroundStyle(.white)
                                    .padding(3)
                                    .background(.blue, in: Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: 1)
                                    )
                            }
                        }
                        .frame(width: 58, height: 58)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(artist.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    if !artist.displayGenres.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "music.note")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(artist.displayGenres)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    
                    Text("Play")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isPressed ? .blue.opacity(0.3) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    HomeView()
}

#Preview("Artist Row") {
    ArtistRowView(artist: Artist.example) {
        print("Artist selected")
    }
    .padding()
}