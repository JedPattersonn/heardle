import Foundation

struct ArtistCategory: Codable, Identifiable {
    let id = UUID()
    let title: String
    let artists: [Artist]
    
    private enum CodingKeys: String, CodingKey {
        case title, artists
    }
}