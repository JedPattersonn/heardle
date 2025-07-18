import SwiftUI

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
        VStack(spacing: 30) {
            artistHeader
            difficultySelector
            startButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var artistHeader: some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: artist.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(.quaternary)
                    .overlay {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                    }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            
            Text("Ready to Play?")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("You'll hear snippets of songs by \(artist.name). Try to guess the song titles! Clips get longer with each attempt.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var difficultySelector: some View {
        VStack(spacing: 16) {
            Text("Difficulty")
                .font(.headline)
            
            Picker("Difficulty", selection: $gameState.selectedDifficulty) {
                ForEach(Song.Difficulty.allCases, id: \.self) { difficulty in
                    Text(difficulty.displayName)
                        .tag(difficulty)
                }
            }
            .pickerStyle(.segmented)
            
            Text(gameState.selectedDifficulty.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var startButton: some View {
        Button("Start Game") {
            startGame()
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(availableSongs.isEmpty)
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