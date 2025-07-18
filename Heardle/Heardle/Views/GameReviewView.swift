import SwiftUI

struct GameReviewView: View {
    let gameState: GameState
    let artist: Artist
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header section
                    headerSection
                    
                    // Game summary
                    gameSummarySection
                    
                    // Song results
                    songResultsSection
                }
                .padding()
            }
            .navigationTitle("Game Review")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Artist info
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: artist.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(.quaternary)
                        .overlay {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundStyle(.secondary)
                        }
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(artist.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Game Review")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundStyle(.blue)
                        Text(gameState.gameStartTime, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var gameSummarySection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.blue)
                    .font(.title3)
                
                Text("Game Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                SummaryCard(
                    title: "Final Score",
                    value: "\(gameState.score)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                SummaryCard(
                    title: "Songs Played",
                    value: "\(gameState.songResults.count)",
                    icon: "music.note",
                    color: .blue
                )
                
                SummaryCard(
                    title: "Correct",
                    value: "\(gameState.correctGuesses)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                SummaryCard(
                    title: "Best Streak",
                    value: "\(gameState.bestStreak)",
                    icon: "flame.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var songResultsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundStyle(.purple)
                    .font(.title3)
                
                Text("Song Results")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(gameState.songResults.count) songs")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(gameState.songResults.enumerated()), id: \.element.id) { index, result in
                    SongResultRow(result: result, songNumber: index + 1)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct SongResultRow: View {
    let result: SongResult
    let songNumber: Int
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with song number and result
            HStack {
                // Song number
                ZStack {
                    Circle()
                        .fill(result.resultColor.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Text("\(songNumber)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(result.resultColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.song.attributes.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text("by \(result.song.attributes.artistName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Result badge
                HStack(spacing: 4) {
                    Image(systemName: resultIcon)
                        .foregroundStyle(result.resultColor)
                        .font(.caption)
                    
                    Text(result.resultText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(result.resultColor)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(result.resultColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
            }
            
            // Details row
            HStack {
                DetailItem(
                    label: "Attempts",
                    value: "\(result.attemptsUsed)/5",
                    icon: "number.circle"
                )
                
                if !result.wasSkipped {
                    DetailItem(
                        label: "Time",
                        value: String(format: "%.1fs", result.guessTime),
                        icon: "clock"
                    )
                }
                
                if result.totalPoints > 0 {
                    DetailItem(
                        label: "Points",
                        value: "\(result.totalPoints)",
                        icon: "star"
                    )
                }
                
                Spacer()
            }
            
            // Show guessed song if incorrect
            if !result.isCorrect && !result.wasSkipped, let guessedName = result.guessedName {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                    
                    Text("You guessed: \(guessedName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var resultIcon: String {
        if result.wasSkipped {
            return "forward.fill"
        } else if result.isCorrect {
            return "checkmark.circle.fill"
        } else {
            return "xmark.circle.fill"
        }
    }
}

struct DetailItem: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .font(.caption2)
            
            Text("\(label): \(value)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
