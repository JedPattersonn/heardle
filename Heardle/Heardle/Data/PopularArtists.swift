import Foundation
import SwiftUI

@Observable
class PopularArtists {
    private let apiService = APIService.shared
    
    var categories: [ArtistCategory] = []
    var isLoading = false
    var error: String?
    
    var heroArtist: Artist? {
        // Return the first artist from the first category as the hero
        categories.first?.artists.first
    }
    
    init() {
        // Don't auto-load on init to avoid caching
    }
    
    @MainActor
    func loadCategories() async {
        isLoading = true
        error = nil
        
        do {
            categories = try await apiService.fetchArtistCategories()
        } catch {
            self.error = error.localizedDescription
            // Fallback to empty state
            categories = []
        }
        
        isLoading = false
    }
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
