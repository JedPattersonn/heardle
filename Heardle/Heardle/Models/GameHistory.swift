import Foundation

struct GameRecord: Identifiable, Codable {
    let id: UUID = UUID()
    let artistId: String
    let artistName: String
    let artistImageUrl: String?
    let score: Int
    let streak: Int
    let bestStreak: Int
    let songsCompleted: Int
    let correctGuesses: Int
    let totalGuesses: Int
    let accuracy: Double
    let perfectGame: Bool
    let difficulty: Song.Difficulty
    let gameStartTime: Date
    let gameDuration: TimeInterval
    let averageGuessTime: Double
    
    // Computed properties for display
    var accuracyPercentage: String {
        return String(format: "%.0f%%", accuracy)
    }
    
    var durationFormatted: String {
        let minutes = Int(gameDuration) / 60
        let seconds = Int(gameDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var rank: GameRank {
        switch score {
        case 0...20: return .bronze
        case 21...40: return .silver
        case 41...60: return .gold
        case 61...80: return .platinum
        default: return .legendary
        }
    }
}

enum GameRank: String, CaseIterable {
    case bronze = "Bronze"
    case silver = "Silver" 
    case gold = "Gold"
    case platinum = "Platinum"
    case legendary = "Legendary"
    
    var color: Color {
        switch self {
        case .bronze: return .brown
        case .silver: return .gray
        case .gold: return .yellow
        case .platinum: return .cyan
        case .legendary: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .bronze: return "medal.fill"
        case .silver: return "medal.fill"
        case .gold: return "medal.fill"
        case .platinum: return "crown.fill"
        case .legendary: return "star.fill"
        }
    }
    
    var minScore: Int {
        switch self {
        case .bronze: return 0
        case .silver: return 21
        case .gold: return 41
        case .platinum: return 61
        case .legendary: return 81
        }
    }
}

@Observable
class GameHistoryManager {
    private let userDefaults = UserDefaults.standard
    private let historyKey = "gameHistory"
    
    var gameRecords: [GameRecord] = []
    
    init() {
        loadHistory()
    }
    
    func saveGameRecord(_ gameState: GameState, artist: Artist, gameDuration: TimeInterval) {
        let record = GameRecord(
            artistId: artist.id,
            artistName: artist.name,
            artistImageUrl: artist.imageUrl,
            score: gameState.score,
            streak: gameState.streak,
            bestStreak: gameState.bestStreak,
            songsCompleted: gameState.songsCompleted,
            correctGuesses: gameState.correctGuesses,
            totalGuesses: gameState.totalGuesses,
            accuracy: gameState.accuracy,
            perfectGame: gameState.perfectGame,
            difficulty: gameState.selectedDifficulty,
            gameStartTime: gameState.gameStartTime,
            gameDuration: gameDuration,
            averageGuessTime: gameState.averageGuessTime
        )
        
        gameRecords.append(record)
        saveHistory()
    }
    
    private func saveHistory() {
        do {
            let data = try JSONEncoder().encode(gameRecords)
            userDefaults.set(data, forKey: historyKey)
        } catch {
            print("Failed to save game history: \(error)")
        }
    }
    
    private func loadHistory() {
        guard let data = userDefaults.data(forKey: historyKey) else { return }
        
        do {
            gameRecords = try JSONDecoder().decode([GameRecord].self, from: data)
        } catch {
            print("Failed to load game history: \(error)")
            gameRecords = []
        }
    }
    
    func clearHistory() {
        gameRecords.removeAll()
        userDefaults.removeObject(forKey: historyKey)
    }
    
    // Statistics computed properties
    var totalGamesPlayed: Int {
        gameRecords.count
    }
    
    var highestScore: Int {
        gameRecords.map(\.score).max() ?? 0
    }
    
    var averageScore: Double {
        guard !gameRecords.isEmpty else { return 0 }
        return Double(gameRecords.map(\.score).reduce(0, +)) / Double(gameRecords.count)
    }
    
    var perfectGames: Int {
        gameRecords.filter(\.perfectGame).count
    }
    
    var bestStreak: Int {
        gameRecords.map(\.bestStreak).max() ?? 0
    }
    
    var averageAccuracy: Double {
        guard !gameRecords.isEmpty else { return 0 }
        return gameRecords.map(\.accuracy).reduce(0, +) / Double(gameRecords.count)
    }
    
    var mostPlayedArtist: String? {
        let artistCounts = Dictionary(grouping: gameRecords, by: \.artistName)
            .mapValues(\.count)
        return artistCounts.max(by: { $0.value < $1.value })?.key
    }
    
    var favoriteRank: GameRank {
        let rankCounts = Dictionary(grouping: gameRecords, by: \.rank)
            .mapValues(\.count)
        return rankCounts.max(by: { $0.value < $1.value })?.key ?? .bronze
    }
    
    // Leaderboards
    func topScores(limit: Int = 10) -> [GameRecord] {
        return gameRecords.sorted { $0.score > $1.score }.prefix(limit).map { $0 }
    }
    
    func topStreaks(limit: Int = 10) -> [GameRecord] {
        return gameRecords.sorted { $0.bestStreak > $1.bestStreak }.prefix(limit).map { $0 }
    }
    
    func perfectGamesHistory() -> [GameRecord] {
        return gameRecords.filter(\.perfectGame).sorted { $0.gameStartTime > $1.gameStartTime }
    }
    
    func recentGames(limit: Int = 20) -> [GameRecord] {
        return gameRecords.sorted { $0.gameStartTime > $1.gameStartTime }.prefix(limit).map { $0 }
    }
    
    func gamesForArtist(_ artistId: String) -> [GameRecord] {
        return gameRecords.filter { $0.artistId == artistId }.sorted { $0.gameStartTime > $1.gameStartTime }
    }
}

// MARK: - Extensions
import SwiftUI

extension Color {
    static let brown = Color(red: 0.55, green: 0.27, blue: 0.07)
}