import SwiftUI

//// Helper to allow conditional shape types
//struct AnyShape: Shape {
//    private let _path: (CGRect) -> Path
//    
//    init<S: Shape>(_ shape: S) {
//        _path = { rect in
//            shape.path(in: rect)
//        }
//    }
//    
//    func path(in rect: CGRect) -> Path {
//        _path(rect)
//    }
//}

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
                // Artist/Playlist image with subtle gradient border
                ZStack {
                    if artist.isPlaylist == true {
                        // Square background for playlists
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: colorScheme.gradient.map { $0.opacity(0.3) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 94, height: 94)
                    } else {
                        // Circular background for artists
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: colorScheme.gradient.map { $0.opacity(0.3) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 94, height: 94)
                    }
                    
                    AsyncImage(url: URL(string: artist.imageUrl ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        if artist.isPlaylist == true {
                            RoundedRectangle(cornerRadius: 8)
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
                    .frame(width: 88, height: 88)
                    .clipShape(artist.isPlaylist == true ? AnyShape(RoundedRectangle(cornerRadius: 8)) : AnyShape(Circle()))
                    
                    // Playlist indicator
                    if artist.isPlaylist == true {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "music.note.list")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                    .padding(4)
                                    .background(.blue, in: Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: 1)
                                    )
                            }
                        }
                        .frame(width: 88, height: 88)
                    }
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
                        .overlay {
                            if artist.isPlaylist == true {
                                Image(systemName: "music.note.list")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)
                            }
                        }
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
                    // Playlist indicator at top right
                    if artist.isPlaylist == true {
                        HStack {
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "music.note.list")
                                    .font(.caption)
                                Text("Playlist")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.blue.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
                        }
                        .padding()
                    }
                    
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
