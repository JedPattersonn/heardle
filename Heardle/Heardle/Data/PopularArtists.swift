import Foundation
import SwiftUI

struct PopularArtists {
    static let featured: [Artist] = [
        Artist(
            id: "159260351",
            name: "Taylor Swift",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/3e/29/3e/3e293e9e-2c27-6782-a3d7-b6742c4e6e8e/pr_source.png/300x300bb.jpg",
            genres: ["Pop", "Country"]
        ),
        Artist(
            id: "909253",
            name: "The Beatles",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/c3/b3/7c/c3b37c77-aa5b-3c8f-3f17-8f8b5a7b4f42/pr_source.png/300x300bb.jpg",
            genres: ["Rock", "Pop"]
        ),
        Artist(
            id: "1065981054",
            name: "Billie Eilish",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/c8/95/0b/c8950b4d-7b5c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Pop", "Alternative"]
        ),
        Artist(
            id: "349593119",
            name: "Drake",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/8b/4a/9e/8b4a9e95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Hip-Hop", "Rap"]
        )
    ]
    
    static let trending: [Artist] = [
        Artist(
            id: "1419227",
            name: "Ariana Grande",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/5e/5d/88/5e5d888d-7c4b-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Pop", "R&B"]
        ),
        Artist(
            id: "1126808565",
            name: "Dua Lipa",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/2d/3f/1a/2d3f1a95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Pop", "Dance"]
        ),
        Artist(
            id: "73406786",
            name: "The Weeknd",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/6f/2c/9b/6f2c9b95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["R&B", "Pop"]
        ),
        Artist(
            id: "1558933962",
            name: "Olivia Rodrigo",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/9a/8c/7d/9a8c7d95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Pop", "Alternative"]
        ),
        Artist(
            id: "1419227",
            name: "Harry Styles",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/1e/2f/3a/1e2f3a95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Pop", "Rock"]
        ),
        Artist(
            id: "290462352",
            name: "Post Malone",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/4d/5e/6f/4d5e6f95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Hip-Hop", "Pop"]
        )
    ]
    
    static let classics: [Artist] = [
        Artist(
            id: "136975",
            name: "Queen",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/7e/8f/9a/7e8f9a95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Rock", "Classic Rock"]
        ),
        Artist(
            id: "5468295",
            name: "Michael Jackson",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/3c/4d/5e/3c4d5e95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Pop", "R&B"]
        ),
        Artist(
            id: "112058",
            name: "Fleetwood Mac",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/8a/9b/ac/8a9bac95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Rock", "Pop Rock"]
        ),
        Artist(
            id: "487143",
            name: "Stevie Wonder",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/6b/7c/8d/6b7c8d95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["R&B", "Soul"]
        )
    ]
    
    static let hiphop: [Artist] = [
        Artist(
            id: "73705833",
            name: "Kendrick Lamar",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/9d/ae/bf/9daebf95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Hip-Hop", "Rap"]
        ),
        Artist(
            id: "73705833",
            name: "J. Cole",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/1f/2a/3b/1f2a3b95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Hip-Hop", "Rap"]
        ),
        Artist(
            id: "549236696",
            name: "Travis Scott",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/AMCArtistImages211/v4/8a/7f/aa/8a7faa0f-1d60-8e4d-1ac0-d835e9d6574a/ami-identity-37880238a23a47d53d01a6f4e67f0167-2025-01-24T04-53-52.460Z_cropped.png/300x300bb.jpg",
            genres: ["Hip-Hop", "Rap"]
        ),
        Artist(
            id: "290462352",
            name: "Future",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/7f/8a/9b/7f8a9b95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Hip-Hop", "Rap"]
        )
    ]
    
    static let rock: [Artist] = [
        Artist(
            id: "816131",
            name: "Imagine Dragons",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/2e/3f/4a/2e3f4a95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Rock", "Alternative"]
        ),
        Artist(
            id: "1419227",
            name: "Coldplay",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/5b/6c/7d/5b6c7d95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Rock", "Alternative"]
        ),
        Artist(
            id: "456734",
            name: "Red Hot Chili Peppers",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/8e/9f/aa/8e9faa95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Rock", "Alternative"]
        ),
        Artist(
            id: "123456",
            name: "Foo Fighters",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/bb/cc/dd/bbccdd95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Rock", "Alternative"]
        )
    ]
    
    // Hero artist for the main feature
    static let heroArtist = featured.first!
    
    static let mostPopular: [Artist] = [
        Artist(
            id: "159260351",
            name: "Taylor Swift",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/3e/29/3e/3e293e9e-2c27-6782-a3d7-b6742c4e6e8e/pr_source.png/300x300bb.jpg",
            genres: ["Pop", "Country"]
        ),
        Artist(
            id: "1065981054",
            name: "Billie Eilish",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/c8/95/0b/c8950b4d-7b5c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Pop", "Alternative"]
        ),
        Artist(
            id: "349593119",
            name: "Drake",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/8b/4a/9e/8b4a9e95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Hip-Hop", "Rap"]
        ),
        Artist(
            id: "1419227",
            name: "Ariana Grande",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/5e/5d/88/5e5d888d-7c4b-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Pop", "R&B"]
        ),
        Artist(
            id: "73406786",
            name: "The Weeknd",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/6f/2c/9b/6f2c9b95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["R&B", "Pop"]
        ),
        Artist(
            id: "1558933962",
            name: "Olivia Rodrigo",
            imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/9a/8c/7d/9a8c7d95-4b7c-8b1a-1c9b-8d8c8f8f8f8f/pr_source.png/300x300bb.jpg",
            genres: ["Pop", "Alternative"]
        )
    ]
    
    static let allCategories: [(title: String, artists: [Artist])] = [
        ("Most Popular", mostPopular),
        ("Trending Now", trending),
        ("Hip-Hop & Rap", hiphop),
        ("Rock & Alternative", rock),
        ("Classics & Legends", classics)
    ]
}

// MARK: - Category Colors
extension PopularArtists {
    enum CategoryColor: CaseIterable {
        case blue, purple, pink, orange, green, red
        
        var gradient: [Color] {
            switch self {
            case .blue:
                return [.blue, .cyan]
            case .purple:
                return [.purple, .pink]
            case .pink:
                return [.pink, .orange]
            case .orange:
                return [.orange, .yellow]
            case .green:
                return [.green, .mint]
            case .red:
                return [.red, .pink]
            }
        }
        
        static func color(for index: Int) -> CategoryColor {
            let colors = CategoryColor.allCases
            return colors[index % colors.count]
        }
    }
}
