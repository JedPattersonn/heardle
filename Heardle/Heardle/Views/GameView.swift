import SwiftUI
import PostHog

struct GameView: View {
    let artist: Artist
    let onDismiss: () -> Void
    
    @State private var gameState = GameState()
    @State private var availableSongs: [Song] = []
    @State private var isLoadingSongs = false
    @State private var loadError: String?
    @State private var selectedGuess: Song?
    @State private var showingGuessPicker = false
    @State private var historyManager = GameHistoryManager()
    @State private var gameHasBeenSaved = false
    @State private var showingEndGameOptions = false
    @State private var showingGameReview = false
    
    private let apiService = APIService.shared
    private let audioService = AudioService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if isLoadingSongs {
                    loadingView
                } else if let error = loadError {
                    errorView(error)
                } else {
                    switch gameState.gamePhase {
                    case .setup:
                        setupView
                    case .playing:
                        gameplayView
                    case .feedback:
                        feedbackView
                    case .complete:
                        resultsView
                    }
                }
            }
            .padding()
            .navigationTitle(artist.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(gameState.gamePhase != .setup)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if gameState.gamePhase != .setup {
                        Button("End Game") {
                            // Show options if there are song results to review
                            if !gameState.songResults.isEmpty {
                                showingEndGameOptions = true
                            } else {
                                saveGameIfNeeded()
                                onDismiss()
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadSongs()
        }
        .onDisappear {
            Task {
                await audioService.stop()
            }
            saveGameIfNeeded()
        }
        .confirmationDialog("End Game", isPresented: $showingEndGameOptions) {
            Button("Review Game") {
                saveGameIfNeeded()
                showingGameReview = true
            }
            
            Button("Exit Without Review") {
                saveGameIfNeeded()
                onDismiss()
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Would you like to review your game before leaving?")
        }
        .sheet(isPresented: $showingGameReview) {
            GameReviewView(gameState: gameState, artist: artist)
                .onDisappear {
                    onDismiss()
                }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading songs...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 20) {
            ContentUnavailableView(
                "Failed to Load Songs",
                systemImage: "exclamationmark.triangle",
                description: Text(error)
            )
            
            Button("Try Again") {
                loadSongs()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - Setup View
    private var setupView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            compactArtistHeader
            
            VStack(spacing: 24) {
                compactDifficultySelector
                startButton
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    private var compactArtistHeader: some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: artist.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(.quaternary)
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.system(size: 30))
                            .foregroundStyle(.secondary)
                    }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(.white.opacity(0.8), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 8) {
                Text(artist.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Ready to play?")
                    .font(.headline)
                    .foregroundStyle(.blue)
            }
            
            highScoreDisplay
        }
        .padding(.horizontal, 24)
    }
    
    private var highScoreDisplay: some View {
        let artistGames = historyManager.gamesForArtist(artist.id)
        let highScore = artistGames.filter { $0.difficulty == gameState.selectedDifficulty }.map(\.score).max() ?? 0
        let totalGames = artistGames.filter { $0.difficulty == gameState.selectedDifficulty }.count
        
        return Group {
            if totalGames > 0 {
                HStack(spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                    
                    VStack(spacing: 2) {
                        Text("High Score")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Text("\(highScore)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                    }
                    
                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    
                    VStack(spacing: 2) {
                        Text("Games")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Text("\(totalGames)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.quaternary.opacity(0.5), lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.02), radius: 2, x: 0, y: 1)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.blue)
                        .font(.caption)
                    
                    Text("First time playing!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue.opacity(0.1))
                )
            }
        }
    }
    
    private var compactDifficultySelector: some View {
        VStack(spacing: 16) {
            Text("Choose Difficulty")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Picker("Difficulty", selection: $gameState.selectedDifficulty) {
                ForEach(Song.Difficulty.allCases, id: \.self) { difficulty in
                    Text(difficulty.displayName)
                        .tag(difficulty)
                }
            }
            .pickerStyle(.segmented)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.quaternary.opacity(0.3))
                    .padding(-4)
            )
            
            HStack(spacing: 8) {
                difficultyIcon(for: gameState.selectedDifficulty)
                
                Text(gameState.selectedDifficulty.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.quaternary.opacity(0.5), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
    
    
    private func difficultyIcon(for difficulty: Song.Difficulty) -> some View {
        Group {
            switch difficulty {
            case .easy:
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green)
            case .medium:
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
            case .hard:
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.red)
            }
        }
        .font(.title3)
    }
    
    private var startButton: some View {
        Button {
            #if !DEBUG
            let userId = PostHogSDK.shared.getDistinctId()
                        
            PostHogSDK.shared.capture("game_started", properties: [
                "artist_id": artist.id, 
                "artist_name": artist.name, 
                "mobile": true, 
                "difficulty": gameState.selectedDifficulty.displayName,
                "user_id": userId,
            ])
            #endif
            startGame()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "play.fill")
                    .font(.title)
                
                Text("Start Game")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                availableSongs.isEmpty ? 
                    LinearGradient(colors: [.gray, .gray], startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: availableSongs.isEmpty ? .clear : .blue.opacity(0.4), radius: 12, x: 0, y: 6)
            .scaleEffect(availableSongs.isEmpty ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: availableSongs.isEmpty)
        }
        .disabled(availableSongs.isEmpty)
        .buttonStyle(.plain)
    }
    
    // MARK: - Gameplay View
    private var gameplayView: some View {
        VStack(spacing: 24) {
            scoreHeader
            audioSection
            guessSection
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private var scoreHeader: some View {
        HStack {
            ScoreDisplayView(
                score: gameState.score,
                streak: gameState.streak,
                timeBonus: gameState.timeBonus
            )
            
            Spacer()
        }
    }
    
    private var audioSection: some View {
        VStack(spacing: 16) {
            AudioVisualizerView(isPlaying: audioService.isPlaying)
            
            // Progress indicator
            VStack(spacing: 8) {
                ProgressView(value: Double(gameState.currentPlayDuration), total: 5.0)
                    .progressViewStyle(.linear)
                
                HStack {
                    Text("Current: \(gameState.currentPlayDuration)s")
                    Spacer()
                    if let next = gameState.nextPlayDuration {
                        Text("Next: \(next)s")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            // Audio controls
            HStack(spacing: 16) {
                Button {
                    Task {
                        await playCurrentSong()
                    }
                } label: {
                    HStack {
                        Image(systemName: audioService.isPlaying ? "pause.fill" : "play.fill")
                        Text(audioService.isPlaying ? "Playing..." : "Listen Again")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(audioService.isPlaying)
                
                Button {
                    skipSong()
                } label: {
                    HStack {
                        Image(systemName: gameState.currentPlayDuration >= 5 ? "xmark" : "forward.fill")
                        Text(gameState.currentPlayDuration >= 5 ? "Give Up" : "Skip (+\(gameState.nextPlayDuration ?? 5)s)")
                    }
                }
                .buttonStyle(.bordered)
                .foregroundStyle(gameState.currentPlayDuration >= 5 ? .red : .primary)
            }
        }
    }
    
    private var guessSection: some View {
        VStack(spacing: 16) {
            Button {
                showingGuessPicker = true
            } label: {
                HStack {
                    Text(selectedGuess?.attributes.name ?? "Select a song...")
                        .foregroundStyle(selectedGuess == nil ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            .sheet(isPresented: $showingGuessPicker) {
                SongPickerView(
                    songs: availableSongs,
                    selectedSong: $selectedGuess,
                    isPresented: $showingGuessPicker
                )
            }
            
            Button("Submit Guess") {
                submitGuess()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(selectedGuess == nil)
        }
    }
    
    // MARK: - Feedback View
    private var feedbackView: some View {
        FeedbackView(
            isCorrect: gameState.feedback.isCorrect,
            song: gameState.feedback.song,
            points: gameState.feedback.points,
            bonusPoints: gameState.feedback.bonusPoints,
            guessTime: gameState.feedback.guessTime,
            onNextSong: nextSong
        )
    }
    
    // MARK: - Results View
    private var resultsView: some View {
        GameResultsView(gameState: gameState, artist: artist) {
            // Play again
            gameState.startNewGame()
            gameHasBeenSaved = false
            startGame()
        } onDismiss: {
            onDismiss()
        }
        .onAppear {
            // Save game record when results appear (if not already saved)
            saveGameIfNeeded()
        }
    }
    
    // MARK: - Methods
    private func saveGameIfNeeded() {
        // Only save if the game has started and hasn't been saved yet
        guard !gameHasBeenSaved && gameState.gamePhase != .setup else { return }
        
        let gameDuration = Date().timeIntervalSince(gameState.gameStartTime)
        historyManager.saveGameRecord(gameState, artist: artist, gameDuration: gameDuration)
        gameHasBeenSaved = true
    }
    
    private func loadSongs() {
        isLoadingSongs = true
        loadError = nil
        
        Task {
            do {
                let songs = try await apiService.fetchSongs(for: artist.id)
                await MainActor.run {
                    self.availableSongs = songs
                    self.isLoadingSongs = false
                }
            } catch {
                await MainActor.run {
                    self.loadError = error.localizedDescription
                    self.isLoadingSongs = false
                }
            }
        }
    }
    
    private func startGame() {
        let filteredSongs = apiService.filterSongs(availableSongs, by: gameState.selectedDifficulty)
        guard !filteredSongs.isEmpty else { return }
        
        // Reset the save flag for new game
        gameHasBeenSaved = false
        
        let randomSong = filteredSongs.randomElement()!
        gameState.startNewRound(with: randomSong)
        
        Task {
            await playCurrentSong()
        }
    }
    
    private func playCurrentSong() async {
        guard let song = gameState.currentSong,
              let previewURL = song.attributes.previews.first?.url else { return }
        
        do {
            try await audioService.loadAudio(from: previewURL)
            await audioService.play(for: TimeInterval(gameState.currentPlayDuration))
        } catch {
            print("Audio playback error: \(error)")
        }
    }
    
    private func skipSong() {
        gameState.skipCurrentSong()
        
        if gameState.gamePhase == .playing {
            Task {
                await playCurrentSong()
            }
        }
    }
    
    private func submitGuess() {
        guard let guess = selectedGuess,
              let currentSong = gameState.currentSong else { return }
        
        let isCorrect = guess.id == currentSong.id
        gameState.submitGuess(guess.attributes.name, isCorrect: isCorrect, guessedSong: guess)
    }
    
    private func nextSong() {
        gameState.hideFeedback()
        selectedGuess = nil
        
        let filteredSongs = apiService.filterSongs(availableSongs, by: gameState.selectedDifficulty)
        let unplayedSongs = filteredSongs.filter { $0.id != gameState.currentSong?.id }
        
        if unplayedSongs.isEmpty {
            gameState.completeGame()
        } else {
            let nextSong = unplayedSongs.randomElement()!
            gameState.startNewRound(with: nextSong)
            
            Task {
                await playCurrentSong()
            }
        }
    }
}
