import Foundation
import SwiftUI

// Individual song result for game review
struct SongResult: Identifiable {
    let id = UUID()
    let song: Song
    let isCorrect: Bool
    let guessedSong: Song?
    let guessedName: String?
    let attemptsUsed: Int
    let guessTime: TimeInterval
    let pointsEarned: Int
    let bonusPoints: Int
    let wasSkipped: Bool
    
    var totalPoints: Int {
        pointsEarned + bonusPoints
    }
    
    var resultText: String {
        if wasSkipped {
            return "Skipped"
        } else if isCorrect {
            return "Correct"
        } else {
            return "Incorrect"
        }
    }
    
    var resultColor: Color {
        if wasSkipped {
            return .orange
        } else if isCorrect {
            return .green
        } else {
            return .red
        }
    }
}

@Observable
class GameState {
    var currentSong: Song?
    var isPlaying: Bool = false
    var currentTime: Double = 0
    var maxTime: Double = 1
    var guessAttempts: Int = 0
    var score: Int = 0
    var streak: Int = 0
    var bestStreak: Int = 0
    var songsCompleted: Int = 0
    var correctGuesses: Int = 0
    var totalGuesses: Int = 0
    var gameStartTime: Date = Date()
    var roundStartTime: Date = Date()
    var timeBonus: Bool = false
    var perfectGame: Bool = true
    var selectedDifficulty: Song.Difficulty = .medium
    
    // Song results for game review
    var songResults: [SongResult] = []
    
    // Game phases
    enum GamePhase {
        case setup
        case playing
        case feedback
        case complete
    }
    
    var gamePhase: GamePhase = .setup
    
    // Feedback state
    struct FeedbackState {
        var show: Bool = false
        var isCorrect: Bool = false
        var song: Song?
        var points: Int = 0
        var bonusPoints: Int = 0
        var guessTime: TimeInterval = 0
    }
    
    var feedback = FeedbackState()
    
    // Computed properties
    var accuracy: Double {
        guard totalGuesses > 0 else { return 0 }
        return Double(correctGuesses) / Double(totalGuesses) * 100
    }
    
    var averageGuessTime: Double {
        guard songsCompleted > 0 else { return 0 }
        return Date().timeIntervalSince(gameStartTime) / Double(songsCompleted)
    }
    
    var currentPlayDuration: Int {
        return guessAttempts + 1
    }
    
    var nextPlayDuration: Int? {
        let next = currentPlayDuration + 1
        return next <= 5 ? next : nil
    }
    
    // Methods
    func startNewGame() {
        currentSong = nil
        isPlaying = false
        currentTime = 0
        maxTime = 1
        guessAttempts = 0
        score = 0
        streak = 0
        songsCompleted = 0
        correctGuesses = 0
        totalGuesses = 0
        gameStartTime = Date()
        roundStartTime = Date()
        timeBonus = false
        perfectGame = true
        gamePhase = .setup
        feedback = FeedbackState()
        songResults = []
    }
    
    func startNewRound(with song: Song) {
        currentSong = song
        guessAttempts = 0
        roundStartTime = Date()
        timeBonus = false
        gamePhase = .playing
    }
    
    func calculateScore(for attempts: Int, guessTime: TimeInterval, isCorrect: Bool) -> (basePoints: Int, bonusPoints: Int, timeBonus: Bool) {
        guard isCorrect else { return (0, 0, false) }
        
        let basePoints = max(6 - attempts, 1)
        var bonusPoints = 0
        let timeBonus = guessTime < 3.0
        
        if timeBonus {
            bonusPoints += 2
        }
        
        let streakMultiplier = streak > 0 ? min(1 + Double(streak) * 0.1, 3) : 1
        let finalBasePoints = Int(Double(basePoints) * streakMultiplier)
        
        return (finalBasePoints, bonusPoints, timeBonus)
    }
    
    func submitGuess(_ guess: String, isCorrect: Bool, guessedSong: Song? = nil) {
        let guessTime = Date().timeIntervalSince(roundStartTime)
        let (basePoints, bonusPoints, timeBonus) = calculateScore(
            for: guessAttempts,
            guessTime: guessTime,
            isCorrect: isCorrect
        )
        
        let totalPoints = basePoints + bonusPoints
        
        if isCorrect {
            streak += 1
            bestStreak = max(bestStreak, streak)
            score += totalPoints
            correctGuesses += 1
            self.timeBonus = timeBonus
        } else {
            streak = 0
            perfectGame = false
        }
        
        totalGuesses += 1
        songsCompleted += 1
        
        // Record song result for review
        if let song = currentSong {
            let songResult = SongResult(
                song: song,
                isCorrect: isCorrect,
                guessedSong: guessedSong,
                guessedName: isCorrect ? song.attributes.name : guess,
                attemptsUsed: guessAttempts + 1,
                guessTime: guessTime,
                pointsEarned: basePoints,
                bonusPoints: bonusPoints,
                wasSkipped: false
            )
            songResults.append(songResult)
        }
        
        feedback = FeedbackState(
            show: true,
            isCorrect: isCorrect,
            song: currentSong,
            points: basePoints,
            bonusPoints: bonusPoints,
            guessTime: guessTime
        )
        
        gamePhase = .feedback
    }
    
    func skipCurrentSong() {
        if guessAttempts < 4 {
            guessAttempts += 1
            perfectGame = false
        } else {
            // Final skip - end round
            streak = 0
            songsCompleted += 1
            perfectGame = false
            
            // Record skipped song result
            if let song = currentSong {
                let songResult = SongResult(
                    song: song,
                    isCorrect: false,
                    guessedSong: nil,
                    guessedName: nil,
                    attemptsUsed: 5, // Max attempts used
                    guessTime: Date().timeIntervalSince(roundStartTime),
                    pointsEarned: 0,
                    bonusPoints: 0,
                    wasSkipped: true
                )
                songResults.append(songResult)
            }
            
            feedback = FeedbackState(
                show: true,
                isCorrect: false,
                song: currentSong,
                points: 0,
                bonusPoints: 0,
                guessTime: 0
            )
            gamePhase = .feedback
        }
    }
    
    func completeGame() {
        gamePhase = .complete
    }
    
    func hideFeedback() {
        feedback.show = false
    }
}