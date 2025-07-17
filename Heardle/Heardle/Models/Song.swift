import Foundation

struct Song: Identifiable, Codable {
    let id: String
    let attributes: SongAttributes
    let difficulty: Difficulty
    
    enum Difficulty: String, Codable, CaseIterable {
        case easy = "easy"
        case medium = "medium"
        case hard = "hard"
        
        var displayName: String {
            switch self {
            case .easy: return "Easy"
            case .medium: return "Medium"
            case .hard: return "Hard"
            }
        }
        
        var description: String {
            switch self {
            case .easy: return "Most popular songs - perfect for casual fans"
            case .medium: return "Includes popular songs plus some deeper cuts"
            case .hard: return "All songs - from hits to rare tracks"
            }
        }
    }
}

struct SongAttributes: Codable {
    let name: String
    let artistName: String
    let albumName: String
    let artwork: Artwork
    let durationInMillis: Int
    let previews: [Preview]
}

struct Artwork: Codable {
    let url: String
    
    func imageUrl(size: Int = 300) -> String {
        return url.replacingOccurrences(of: "{w}x{h}", with: "\(size)x\(size)")
    }
}

struct Preview: Codable {
    let url: String
}

extension Song {
    static let example = Song(
        id: "1440857781",
        attributes: SongAttributes(
            name: "Anti-Hero",
            artistName: "Taylor Swift",
            albumName: "Midnights",
            artwork: Artwork(url: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/5e/5d/88/5e5d888d-7c4b-8b1a-1c9b-8d8c8f8f8f8f/artwork.jpg/{w}x{h}bb.jpg"),
            durationInMillis: 200000,
            previews: [Preview(url: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview126/v4/1e/1e/1e/1e1e1e1e-1e1e-1e1e-1e1e-1e1e1e1e1e1e/mzaf_1234567890.plus.aac.p.m4a")]
        ),
        difficulty: .medium
    )
}