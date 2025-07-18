import SwiftUI

struct CategorySectionView: View {
    let title: String
    let artists: [Artist]
    let colorScheme: PopularArtists.CategoryColor
    let onArtistTap: (Artist) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader
            artistsGrid
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: colorScheme.gradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 40, height: 3)
                    .cornerRadius(1.5)
            }
            
            Spacer()
            
            if artists.count > 4 {
                Text("\(artists.count) artists")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var artistsGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(artists) { artist in
                    ArtistCardView(
                        artist: artist,
                        colorScheme: colorScheme
                    ) {
                        onArtistTap(artist)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .scrollClipDisabled()
    }
}

struct ArtistCardView: View {
    let artist: Artist
    let colorScheme: PopularArtists.CategoryColor
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Artist image with gradient border and floating animation
                ZStack {
                    // Subtle shadow that moves with the card
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: colorScheme.gradient.map { $0.opacity(0.3) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 88, height: 88)
                        .offset(y: 4 + animationOffset * 0.5)
                        .blur(radius: 4)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: colorScheme.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 84, height: 84)
                        .offset(y: animationOffset)
                    
                    AsyncImage(url: URL(string: artist.imageUrl ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(.quaternary)
                            .overlay {
                                Image(systemName: "person.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.secondary)
                            }
                    }
                    .frame(width: 76, height: 76)
                    .clipShape(Circle())
                    .offset(y: animationOffset)
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
                .offset(y: animationOffset * 0.7)
            }
            .frame(width: 100)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onAppear {
            // Start floating animation with random delay
            let delay = Double.random(in: 0...2)
            withAnimation(
                .easeInOut(duration: 3.0 + Double.random(in: -0.5...0.5))
                .repeatForever(autoreverses: true)
                .delay(delay)
            ) {
                animationOffset = -3
            }
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Featured Artist Card (Larger)
struct FeaturedArtistCardView: View {
    let artist: Artist
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Large artist image
                AsyncImage(url: URL(string: artist.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(.quaternary)
                        .overlay {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                        }
                }
                .frame(height: 120)
                .clipped()
                
                // Artist info overlay
                VStack(alignment: .leading, spacing: 8) {
                    Text(artist.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    if !artist.displayGenres.isEmpty {
                        Text(artist.displayGenres)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .foregroundStyle(.blue)
                        Text("Start Playing")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.blue)
                        Spacer()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial)
            }
        }
        .buttonStyle(.plain)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            CategorySectionView(
                title: "Featured Artists",
                artists: Array(PopularArtists.featured.prefix(4)),
                colorScheme: .blue
            ) { artist in
                print("Selected: \(artist.name)")
            }
            
            CategorySectionView(
                title: "Trending Now",
                artists: Array(PopularArtists.trending.prefix(6)),
                colorScheme: .purple
            ) { artist in
                print("Selected: \(artist.name)")
            }
        }
        .padding()
    }
}