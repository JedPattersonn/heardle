import Foundation

@Observable
class APIService {
    static let shared = APIService()
    
    // private let baseURL = "http://localhost:3000"
    private let baseURL = "https://www.heardle.fun"
    private let session = URLSession.shared
    
    private init() {}
    
    enum APIError: Error, LocalizedError {
        case invalidURL
        case invalidResponse
        case decodingError
        case networkError(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidResponse:
                return "Invalid response from server"
            case .decodingError:
                return "Failed to decode response"
            case .networkError(let message):
                return "Network error: \(message)"
            }
        }
    }
    
    // MARK: - Artist Search
    func searchArtists(query: String) async throws -> [Artist] {
        guard !query.isEmpty else { return [] }
        
        guard let url = URL(string: "\(baseURL)/api/mobile/artists?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            let artists = try JSONDecoder().decode([Artist].self, from: data)
            return artists
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        } catch {
            print("Network error: \(error)")
            throw APIError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Songs Fetch
    func fetchSongs(for artistId: String) async throws -> [Song] {
        guard let url = URL(string: "\(baseURL)/api/mobile/songs?artistId=\(artistId)") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            let songs = try JSONDecoder().decode([Song].self, from: data)
            return songs
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        } catch {
            print("Network error: \(error)")
            throw APIError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Artists Categories
    func fetchArtistCategories() async throws -> [ArtistCategory] {
        guard let url = URL(string: "\(baseURL)/api/artists/categories") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            let categories = try JSONDecoder().decode([ArtistCategory].self, from: data)
            return categories
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        } catch {
            print("Network error: \(error)")
            throw APIError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Helper Methods
    func filterSongs(_ songs: [Song], by difficulty: Song.Difficulty) -> [Song] {
        switch difficulty {
        case .easy:
            return songs.filter { $0.difficulty == .easy }
        case .medium:
            return songs.filter { $0.difficulty == .easy || $0.difficulty == .medium }
        case .hard:
            return songs
        }
    }
}

// MARK: - Mock Data for Development
extension APIService {
    static let mockArtists: [Artist] = [
        Artist(id: "1", name: "Taylor Swift", imageUrl: "https://example.com/taylor.jpg", genres: ["Pop", "Country"]),
        Artist(id: "2", name: "The Beatles", imageUrl: "https://example.com/beatles.jpg", genres: ["Rock", "Pop"]),
        Artist(id: "3", name: "Billie Eilish", imageUrl: "https://example.com/billie.jpg", genres: ["Pop", "Alternative"])
    ]
    
    static let mockSongs: [Song] = [
        Song.example
    ]
}