import SwiftUI

struct HorizontalArtistSection: View {
    let title: String
    let artists: [Artist]
    let colorScheme: PopularArtists.CategoryColor
    let onArtistTap: (Artist) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader
            artistsScroll
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Spacer()
            
            if artists.count > 6 {
                Text("\(artists.count) artists")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }
    
    private var artistsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(artists) { artist in
                    CompactArtistCard(
                        artist: artist,
                        colorScheme: colorScheme
                    ) {
                        onArtistTap(artist)
                    }
                }
            }
            .padding(.horizontal)
        }
        .scrollClipDisabled()
    }
}

struct CompactArtistCard: View {
    let artist: Artist
    let colorScheme: PopularArtists.CategoryColor
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Artist image with subtle gradient border
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: colorScheme.gradient.map { $0.opacity(0.3) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 94, height: 94)
                    
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
                    .frame(width: 88, height: 88)
                    .clipShape(Circle())
                }
                
                VStack(spacing: 4) {
                    Text(artist.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(minHeight: 34)
                    
                    if !artist.displayGenres.isEmpty {
                        Text(artist.displayGenres)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .frame(width: 100)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Featured Artist Card (Hero section)
struct HeroArtistCard: View {
    let artist: Artist
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background image with gradient overlay
                AsyncImage(url: URL(string: artist.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(.quaternary)
                }
                .frame(height: 200)
                .clipped()
                
                // Gradient overlay
                LinearGradient(
                    colors: [.clear, .clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Content overlay
                VStack {
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(artist.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            if !artist.displayGenres.isEmpty {
                                Text(artist.displayGenres)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: "play.circle.fill")
                                    .foregroundStyle(.white)
                                Text("Start Playing")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .buttonStyle(.plain)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            HeroArtistCard(artist: PopularArtists.featured.first!) {
                print("Hero tapped")
            }
            
            HorizontalArtistSection(
                title: "Featured Artists",
                artists: Array(PopularArtists.featured.prefix(6)),
                colorScheme: .blue
            ) { artist in
                print("Selected: \(artist.name)")
            }
            
            HorizontalArtistSection(
                title: "Trending Now",
                artists: Array(PopularArtists.trending.prefix(6)),
                colorScheme: .purple
            ) { artist in
                print("Selected: \(artist.name)")
            }
        }
        .padding(.vertical)
    }
}