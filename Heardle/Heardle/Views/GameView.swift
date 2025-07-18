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
                            onDismiss()
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
        ScrollView {
            VStack(spacing: 40) {
                Spacer(minLength: 20)
                
                artistHeader
                
                VStack(spacing: 30) {
                    gameInfoCard
                    difficultySelector
                    startButton
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 40)
            }
        }
    }
    
    private var artistHeader: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 180, height: 180)
                    .blur(radius: 20)
                
                AsyncImage(url: URL(string: artist.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(.quaternary)
                        .overlay {
                            Image(systemName: "music.note")
                                .font(.system(size: 50))
                                .foregroundStyle(.secondary)
                        }
                }
                .frame(width: 160, height: 160)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.8), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
            }
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "music.note.list")
                        .foregroundStyle(.blue)
                        .font(.title3)
                    
                    Text("Ready to Play?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                
                Text(artist.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var gameInfoCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                    .font(.title2)
                
                Text("How to Play")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Image(systemName: "1.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Listen to snippets")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Hear short clips of \(artist.name)'s songs")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "2.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Guess the song")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Type the song title as you recognize it")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "3.circle.fill")
                        .foregroundStyle(.orange)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Clips get longer")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Each attempt reveals more of the song")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.quaternary, lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var difficultySelector: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(.purple)
                    .font(.title3)
                
                Text("Choose Difficulty")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                Picker("Difficulty", selection: $gameState.selectedDifficulty) {
                    ForEach(Song.Difficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.displayName)
                            .tag(difficulty)
                    }
                }
                .pickerStyle(.segmented)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary.opacity(0.5))
                        .padding(-4)
                )
                
                HStack {
                    difficultyIcon(for: gameState.selectedDifficulty)
                    
                    Text(gameState.selectedDifficulty.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.quaternary, lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
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
            PostHogSDK.shared.capture("game_started", properties: ["artist_id": artist.id, "artist_name": artist.name, "mobile": true, "difficulty": gameState.selectedDifficulty.displayName])
            startGame()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.title2)
                
                Text("Start Game")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                if !availableSongs.isEmpty {
                    Image(systemName: "arrow.right")
                        .font(.title3)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                availableSongs.isEmpty ? 
                    LinearGradient(colors: [.gray, .gray], startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: availableSongs.isEmpty ? .clear : .blue.opacity(0.3), radius: 8, x: 0, y: 4)
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
        GameResultsView(gameState: gameState) {
            // Play again
            gameState.startNewGame()
            startGame()
        } onDismiss: {
            onDismiss()
        }
    }
    
    // MARK: - Methods
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
        gameState.submitGuess(guess.attributes.name, isCorrect: isCorrect)
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

#Preview {
    GameView(artist: Artist.example) {
        print("Game dismissed")
    }
}
