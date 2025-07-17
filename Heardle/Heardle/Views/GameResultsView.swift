import SwiftUI

struct GameResultsView: View {
    let gameState: GameState
    let onPlayAgain: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // Trophy header
            VStack(spacing: 16) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.yellow)
                
                Text("Game Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                
                ScoreDisplayView(
                    score: gameState.score,
                    streak: gameState.bestStreak,
                    timeBonus: false
                )
            }
            
            // Stats grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatCardView(
                    title: "Correct",
                    value: "\(gameState.correctGuesses)",
                    color: .green
                )
                
                StatCardView(
                    title: "Accuracy",
                    value: "\(String(format: "%.1f", gameState.accuracy))%",
                    color: .blue
                )
                
                StatCardView(
                    title: "Best Streak",
                    value: "\(gameState.bestStreak)",
                    color: .purple
                )
                
                StatCardView(
                    title: "Avg Time",
                    value: "\(String(format: "%.1f", gameState.averageGuessTime))s",
                    color: .orange
                )
            }
            
            // Perfect game indicator
            if gameState.perfectGame && gameState.correctGuesses > 0 {
                VStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.title)
                        .foregroundStyle(.yellow)
                    
                    Text("Perfect Game!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.yellow)
                    
                    Text("All correct on first try")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.yellow.opacity(0.1))
                        .stroke(.yellow.opacity(0.3), lineWidth: 1)
                )
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                Button("Play Again") {
                    onPlayAgain()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("Change Artist") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Button("Share Results") {
                    shareResults()
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func shareResults() {
        let text = generateShareText()
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
        }
        
        window.rootViewController?.present(activityVC, animated: true)
    }
    
    private func generateShareText() -> String {
        let accuracy = String(format: "%.1f", gameState.accuracy)
        let perfectGameText = gameState.perfectGame && gameState.correctGuesses > 0 ? " 🌟 Perfect Game!" : ""
        
        return """
        🎵 Just played Heardle!
        
        Score: \(gameState.score) points
        Correct: \(gameState.correctGuesses)
        Accuracy: \(accuracy)%
        Best Streak: \(gameState.bestStreak)\(perfectGameText)
        
        Can you beat my score? 🎯
        """
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let gameState = GameState()
    gameState.score = 85
    gameState.correctGuesses = 8
    gameState.totalGuesses = 10
    gameState.bestStreak = 5
    gameState.perfectGame = true
    
    return GameResultsView(
        gameState: gameState,
        onPlayAgain: {},
        onDismiss: {}
    )
}