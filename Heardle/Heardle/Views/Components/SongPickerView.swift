import SwiftUI

struct SongPickerView: View {
    let songs: [Song]
    @Binding var selectedSong: Song?
    @Binding var isPresented: Bool
    
    @State private var searchText = ""
    
    private var filteredSongs: [Song] {
        if searchText.isEmpty {
            return songs
        } else {
            return songs.filter { song in
                song.attributes.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField("Search songs...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(.regularMaterial)
                
                Divider()
                
                // Songs list
                if filteredSongs.isEmpty {
                    ContentUnavailableView(
                        "No Songs Found",
                        systemImage: "music.note.list",
                        description: Text(searchText.isEmpty ? "No songs available" : "Try a different search term")
                    )
                } else {
                    List(filteredSongs) { song in
                        SongRowView(
                            song: song,
                            isSelected: selectedSong?.id == song.id
                        ) {
                            selectedSong = song
                            isPresented = false
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Select Song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct SongRowView: View {
    let song: Song
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: song.attributes.artwork.imageUrl())) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary)
                        .overlay {
                            Image(systemName: "music.note")
                                .foregroundStyle(.secondary)
                        }
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.attributes.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Text(song.attributes.albumName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SongPickerView(
        songs: [Song.example],
        selectedSong: .constant(nil),
        isPresented: .constant(true)
    )
}