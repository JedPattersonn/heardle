import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var searchResults: [Artist] = []
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var selectedArtist: Artist?
    @State private var showingGame = false
    
    private let apiService = APIService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                headerSection
                searchSection
                resultsSection
                Spacer()
            }
            .padding()
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
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundStyle(.primary)
            
            Text("Guess the Song!")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            Text("Search for an artist to start playing")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    private var searchSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Search for an artist...", text: $searchText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        performSearch()
                    }
                
                if isSearching {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                        searchResults = []
                        searchError = nil
                    }
                    .foregroundStyle(.secondary)
                    .font(.caption)
                }
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            if let error = searchError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var resultsSection: some View {
        Group {
            if searchResults.isEmpty && !searchText.isEmpty && !isSearching {
                ContentUnavailableView(
                    "No Artists Found",
                    systemImage: "person.crop.circle.badge.questionmark",
                    description: Text("Try a different search term")
                )
            } else if !searchResults.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(searchResults) { artist in
                            ArtistRowView(artist: artist) {
                                selectedArtist = artist
                                showingGame = true
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
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
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: artist.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(.quaternary)
                        .overlay {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundStyle(.secondary)
                        }
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(artist.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if !artist.displayGenres.isEmpty {
                        Text(artist.displayGenres)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
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