import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var searchResults: [Artist] = []
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var selectedArtist: Artist?
    @State private var showingGame = false
    @State private var showingSearch = false
    @State private var showingWelcome = !UserDefaults.standard.bool(forKey: "hasSeenWelcome")
    
    private let apiService = APIService.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    searchButton
                    
                    if showingSearch {
                        searchSection
                        searchResultsSection
                    } else {
                        popularArtistsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Heardle")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $showingGame) {
                if let artist = selectedArtist {
                    GameView(artist: artist) {
                        showingGame = false
                        selectedArtist = nil
                    }
                }
            }
            .refreshable {
                // Add pull-to-refresh for search results if needed
                if !searchText.isEmpty {
                    performSearch()
                }
            }
            .fullScreenCover(isPresented: $showingWelcome) {
                WelcomeView(isPresented: $showingWelcome)
                    .onDisappear {
                        UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
                    }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                // Animated music icon with gradient and pulse effect
                ZStack {
                    // Background pulsing circles
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .opacity(0.3 - Double(i) * 0.1)
                            .frame(width: 100 + CGFloat(i * 20), height: 100 + CGFloat(i * 20))
                            .scaleEffect(1.0 + Double(i) * 0.1)
                            .animation(
                                .easeInOut(duration: 2.0 + Double(i) * 0.5)
                                .repeatForever(autoreverses: true),
                                value: UUID()
                            )
                    }
                    
                    // Main circle with gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    // Music icon with gentle rotation
                    Image(systemName: "music.note.list")
                        .font(.system(size: 45, weight: .light))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(0))
                        .animation(
                            .easeInOut(duration: 4.0)
                            .repeatForever(autoreverses: true),
                            value: UUID()
                        )
                }
                .onAppear {
                    // Trigger animations
                }
                
                VStack(spacing: 8) {
                    Text("Welcome to Heardle!")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Guess the song from short audio clips")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.top, 20)
    }
    
    private var searchButton: some View {
        Button {
            withAnimation(.easeInOut) {
                showingSearch.toggle()
                if !showingSearch {
                    searchText = ""
                    searchResults = []
                    searchError = nil
                }
            }
        } label: {
            HStack {
                Image(systemName: "magnifyingglass")
                Text(showingSearch ? "Hide Search" : "Search for an artist")
                Spacer()
                Image(systemName: showingSearch ? "chevron.up" : "chevron.down")
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    private var searchSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Type artist name...", text: $searchText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        performSearch()
                    }
                    .onChange(of: searchText) { _, newValue in
                        if newValue.isEmpty {
                            searchResults = []
                            searchError = nil
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
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
            
            if let error = searchError {
                Label(error, systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var searchResultsSection: some View {
        Group {
            if !searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Search Results")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(searchResults) { artist in
                            ArtistRowView(artist: artist) {
                                selectArtist(artist)
                            }
                        }
                    }
                }
            } else if !searchText.isEmpty && !isSearching {
                ContentUnavailableView(
                    "No Artists Found",
                    systemImage: "person.crop.circle.badge.questionmark",
                    description: Text("Try searching for a different artist")
                )
                .frame(height: 200)
            }
        }
    }
    
    private var popularArtistsSection: some View {
        LazyVStack(spacing: 24) {
            ForEach(Array(PopularArtists.allCategories.enumerated()), id: \.offset) { index, category in
                CategorySectionView(
                    title: category.title,
                    artists: category.artists,
                    colorScheme: PopularArtists.CategoryColor.color(for: index)
                ) { artist in
                    selectArtist(artist)
                }
            }
        }
    }
    
    private func selectArtist(_ artist: Artist) {
        selectedArtist = artist
        showingGame = true
    }
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isSearching = true
        searchError = nil
        
        Task {
            do {
                let results = try await apiService.searchArtists(query: searchText)
                await MainActor.run {
                    self.searchResults = results
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
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
                // Artist image with subtle gradient border
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                    
                    AsyncImage(url: URL(string: artist.imageUrl ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(.quaternary)
                            .overlay {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                    }
                    .frame(width: 58, height: 58)
                    .clipShape(Circle())
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