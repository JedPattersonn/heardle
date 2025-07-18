import SwiftUI

struct ScoreboardView: View {
    @State private var historyManager = GameHistoryManager()
    @State private var selectedTab: ScoreboardTab = .overview
    
    enum ScoreboardTab: String, CaseIterable {
        case overview = "Overview"
        case leaderboard = "Leaderboard"
        case history = "History"
        case stats = "Stats"
        
        var icon: String {
            switch self {
            case .overview: return "chart.bar.fill"
            case .leaderboard: return "trophy.fill"
            case .history: return "clock.fill"
            case .stats: return "chart.pie.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom tab bar
                tabBar
                
                // Content based on selected tab
                switch selectedTab {
                case .overview:
                    overviewContent
                case .leaderboard:
                    leaderboardContent
                case .history:
                    historyContent
                case .stats:
                    statsContent
                }
            }
            .navigationTitle("Scoreboards")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !historyManager.gameRecords.isEmpty {
                        Menu {
                            Button("Clear History", role: .destructive) {
                                historyManager.clearHistory()
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    }
    
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(ScoreboardTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: .medium))
                        
                        Text(tab.rawValue)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(selectedTab == tab ? .blue : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedTab == tab ? .blue.opacity(0.1) : .clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(.regularMaterial)
    }
    
    private var overviewContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if historyManager.gameRecords.isEmpty {
                    emptyStateView
                } else {
                    // Quick stats cards
                    quickStatsGrid
                    
                    // Recent achievement
                    if let recentGame = historyManager.recentGames(limit: 1).first {
                        recentAchievementCard(recentGame)
                    }
                    
                    // Top scores preview
                    topScoresPreview
                }
            }
            .padding()
        }
    }
    
    private var quickStatsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            StatCard(
                title: "Games Played",
                value: "\(historyManager.totalGamesPlayed)",
                icon: "gamecontroller.fill",
                color: .blue
            )
            
            StatCard(
                title: "High Score",
                value: "\(historyManager.highestScore)",
                icon: "star.fill",
                color: .yellow
            )
            
            StatCard(
                title: "Perfect Games",
                value: "\(historyManager.perfectGames)",
                icon: "crown.fill",
                color: .purple
            )
            
            StatCard(
                title: "Best Streak",
                value: "\(historyManager.bestStreak)",
                icon: "flame.fill",
                color: .orange
            )
        }
    }
    
    private func recentAchievementCard(_ game: GameRecord) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
                    .font(.title2)
                
                Text("Latest Achievement")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            GameRecordCard(record: game, showArtist: true)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var topScoresPreview: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "medal.fill")
                    .foregroundStyle(.green)
                    .font(.title2)
                
                Text("Top Scores")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if historyManager.topScores().count > 3 {
                    Button("View All") {
                        selectedTab = .leaderboard
                    }
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                }
            }
            
            VStack(spacing: 8) {
                ForEach(Array(historyManager.topScores(limit: 3).enumerated()), id: \.element.id) { index, record in
                    HStack {
                        // Rank indicator
                        ZStack {
                            Circle()
                                .fill(rankColor(for: index))
                                .frame(width: 32, height: 32)
                            
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        
                        // Game info
                        VStack(alignment: .leading, spacing: 2) {
                            Text(record.artistName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            
                            Text(record.gameStartTime, style: .date)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        // Score
                        Text("\(record.score)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var leaderboardContent: some View {
        VStack(spacing: 0) {
            if historyManager.gameRecords.isEmpty {
                emptyStateView
            } else {
                // Leaderboard type selector
                leaderboardTypeSelector
                
                // Leaderboard list
                List {
                    ForEach(Array(historyManager.topScores().enumerated()), id: \.element.id) { index, record in
                        LeaderboardRow(record: record, rank: index + 1)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    private var leaderboardTypeSelector: some View {
        HStack {
            Text("High Scores")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            // Could add more leaderboard types here (streaks, accuracy, etc.)
        }
        .padding()
        .background(.regularMaterial)
    }
    
    private var historyContent: some View {
        VStack(spacing: 0) {
            if historyManager.gameRecords.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(historyManager.recentGames()) { record in
                        GameRecordCard(record: record, showArtist: true)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    private var statsContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if historyManager.gameRecords.isEmpty {
                    emptyStateView
                } else {
                    // Detailed statistics
                    detailedStatsSection
                    
                    // Performance breakdown
                    performanceBreakdownSection
                }
            }
            .padding()
        }
    }
    
    private var detailedStatsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.blue)
                    .font(.title2)
                
                Text("Detailed Statistics")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                StatCard(
                    title: "Average Score",
                    value: String(format: "%.1f", historyManager.averageScore),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                
                StatCard(
                    title: "Average Accuracy",
                    value: String(format: "%.0f%%", historyManager.averageAccuracy),
                    icon: "target",
                    color: .red
                )
                
                if let mostPlayed = historyManager.mostPlayedArtist {
                    StatCard(
                        title: "Most Played",
                        value: mostPlayed,
                        icon: "person.fill",
                        color: .purple,
                        isLongText: true
                    )
                }
                
                StatCard(
                    title: "Favorite Rank",
                    value: historyManager.favoriteRank.rawValue,
                    icon: historyManager.favoriteRank.icon,
                    color: historyManager.favoriteRank.color
                )
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var performanceBreakdownSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundStyle(.purple)
                    .font(.title2)
                
                Text("Performance Breakdown")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Rank distribution
            VStack(spacing: 8) {
                ForEach(GameRank.allCases, id: \.self) { rank in
                    let count = historyManager.gameRecords.filter { $0.rank == rank }.count
                    if count > 0 {
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: rank.icon)
                                    .foregroundStyle(rank.color)
                                    .font(.subheadline)
                                
                                Text(rank.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                            
                            Text("\(count)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Games Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start playing to see your scores and statistics here!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private func rankColor(for index: Int) -> Color {
        switch index {
        case 0: return .yellow // Gold
        case 1: return .gray   // Silver
        case 2: return .brown  // Bronze
        default: return .blue
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var isLongText: Bool = false
    
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
                    .font(isLongText ? .subheadline : .title2)
                    .fontWeight(.bold)
                    .lineLimit(isLongText ? 2 : 1)
                    .minimumScaleFactor(0.8)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct LeaderboardRow: View {
    let record: GameRecord
    let rank: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            ZStack {
                Circle()
                    .fill(rankBackground)
                    .frame(width: 40, height: 40)
                
                Text("\(rank)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(rankForeground)
            }
            
            // Artist info
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: record.artistImageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(.quaternary)
                        .overlay {
                            Image(systemName: "person.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.artistName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Image(systemName: record.rank.icon)
                            .foregroundStyle(record.rank.color)
                            .font(.caption)
                        
                        Text(record.rank.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(record.score)")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(record.accuracyPercentage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var rankBackground: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .blue.opacity(0.1)
        }
    }
    
    private var rankForeground: Color {
        switch rank {
        case 1, 2, 3: return .white
        default: return .blue
        }
    }
}

struct GameRecordCard: View {
    let record: GameRecord
    var showArtist: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                if showArtist {
                    AsyncImage(url: URL(string: record.artistImageUrl ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(.quaternary)
                            .overlay {
                                Image(systemName: "person.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(record.artistName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        
                        Text(record.gameStartTime, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(record.gameStartTime, style: .date)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                // Rank badge
                HStack(spacing: 4) {
                    Image(systemName: record.rank.icon)
                        .foregroundStyle(record.rank.color)
                        .font(.caption)
                    
                    Text(record.rank.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(record.rank.color)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(record.rank.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
            }
            
            // Stats
            HStack {
                StatItem(label: "Score", value: "\(record.score)", icon: "star.fill", color: .yellow)
                StatItem(label: "Accuracy", value: record.accuracyPercentage, icon: "target", color: .red)
                StatItem(label: "Streak", value: "\(record.bestStreak)", icon: "flame.fill", color: .orange)
                
                if record.perfectGame {
                    StatItem(label: "Perfect", value: "✓", icon: "crown.fill", color: .purple)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct StatItem: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.caption)
            
            Text(value)
                .font(.caption2)
                .fontWeight(.semibold)
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScoreboardView()
}
