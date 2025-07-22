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
    @State private var showFirstTimeHint = !UserDefaults.standard.bool(forKey: "hasPlayedBefore")
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
                            // Quick start section for first-time users
                            if showFirstTimeHint {
                                QuickStartCard {
                                    showFirstTimeHint = false
                                }
                                .padding(.top, 8)
                            }
                            
                            // Hero section
                            if let heroArtist = popularArtists.heroArtist {
                                HeroArtistCard(artist: heroArtist) { 
                                    selectArtist(heroArtist)
                                }
                                .padding(.top, showFirstTimeHint ? 12 : 8)
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
    
    // Enhanced header inspired by Flighty's clean design
    private var compactHeader: some View {
        VStack(spacing: 0) {
            HStack {
                // Enhanced logo with subtle animation
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.2), .purple.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "waveform")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("MusIQ")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        if showFirstTimeHint {
                            Text("Tap any artist to start!")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 18) {
                    // Enhanced scoreboard button
                    Button {
                        showingScoreboard = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.yellow.opacity(0.1))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "trophy.fill")
                                .font(.title3)
                                .foregroundStyle(.yellow)
                        }
                    }
                    .scaleEffect(0.95)
                    .animation(.spring(response: 0.3), value: showingScoreboard)
                    
                    // Enhanced search button
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showingSearch.toggle()
                            if !showingSearch {
                                searchText = ""
                                searchResults = []
                                searchError = nil
                            }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(showingSearch ? .blue.opacity(0.15) : .clear)
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: showingSearch ? "xmark" : "magnifyingglass")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(showingSearch ? .blue : .primary)
                        }
                    }
                    .scaleEffect(showingSearch ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showingSearch)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .background(.ultraThinMaterial)
            
            // Enhanced divider
            if showingSearch {
                Rectangle()
                    .fill(.quaternary)
                    .frame(height: 0.5)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
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
                    
                    Text("Find your favorite artists and start playing MusIQ!")
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
        
        // Mark that user has played before
        if showFirstTimeHint {
            UserDefaults.standard.set(true, forKey: "hasPlayedBefore")
            showFirstTimeHint = false
        }
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

// Quick start card for first-time users (Tripsy-inspired)
struct QuickStartCard: View {
    let onDismiss: () -> Void
    @State private var animateWave = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green.opacity(0.2), .blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    // Animated waveform
                    HStack(spacing: 2) {
                        ForEach(0..<3) { index in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(.green)
                                .frame(width: 2, height: CGFloat.random(in: 8...16))
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.1),
                                    value: animateWave
                                )
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("🎵 Ready to play?")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Pick any artist below and guess songs from 1-second clips!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut) {
                        onDismiss()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                        .font(.title3)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.green.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.green.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .onAppear {
            animateWave = true
        }
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

#Preview("Quick Start Card") {
    QuickStartCard {
        print("Dismissed")
    }
    .padding()
}