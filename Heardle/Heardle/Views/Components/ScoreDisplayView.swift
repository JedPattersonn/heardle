import SwiftUI

struct ScoreDisplayView: View {
    let score: Int
    let streak: Int
    let timeBonus: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Score
            HStack(spacing: 4) {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
                Text("\(score)")
                    .fontWeight(.bold)
            }
            
            // Streak
            if streak > 1 {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(.orange)
                    Text("\(streak)x")
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.orange.opacity(0.2), in: Capsule())
            }
            
            // Time bonus indicator
            if timeBonus {
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.green)
                    Text("Speed!")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.green.opacity(0.2), in: Capsule())
            }
        }
        .font(.subheadline)
    }
}

#Preview {
    VStack(spacing: 20) {
        ScoreDisplayView(score: 25, streak: 1, timeBonus: false)
        ScoreDisplayView(score: 52, streak: 3, timeBonus: false)
        ScoreDisplayView(score: 78, streak: 5, timeBonus: true)
    }
    .padding()
}