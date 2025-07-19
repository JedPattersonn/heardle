import Foundation

struct Artist: Identifiable, Codable {
    let id: String
    let name: String
    let imageUrl: String?
    let genres: [String]
    let isPlaylist: Bool?
    
    var displayGenres: String {
        genres.prefix(2).joined(separator: ", ")
    }
}

struct ArtistSearchResponse: Codable {
    let artists: [Artist]
}

extension Artist {
    static let example = Artist(
        id: "159260351",
        name: "Taylor Swift",
        imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/3e/29/3e/3e293e9e-2c27-6782-a3d7-b6742c4e6e8e/pr_source.png/300x300bb.jpg",
        genres: ["Pop", "Country"],
        isPlaylist: false
    )
}