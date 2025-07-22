import SwiftUI
import AVFoundation

struct WelcomeView: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    @State private var animateGradient = false
    @State private var selectedGenres: Set<String> = []
    @State private var selectedDifficulty: GameDifficulty = .medium
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlayingDemo = false
    
    private let steps = [
        WelcomeStep(
            icon: "waveform",
            title: "Welcome to MusIQ!",
            description: "Guess songs from short audio clips. Start with 1 second and unlock more time with each attempt.",
            color: .blue,
            type: .welcome
        ),
        WelcomeStep(
            icon: "music.quarternote.3",
            title: "Choose Your Vibe",
            description: "Select music genres you love to personalize your experience.",
            color: .purple,
            type: .genreSelection
        ),
        WelcomeStep(
            icon: "target",
            title: "Set Your Challenge",
            description: "Pick your difficulty level. You can always change this later.",
            color: .orange,
            type: .difficultySelection
        ),
        WelcomeStep(
            icon: "play.circle.fill",
            title: "Try a Quick Demo",
            description: "Ready to play? Here's how it works with a sample clip.",
            color: .green,
            type: .demo
        )
    ]
    
    private let availableGenres = [
        "Pop", "Rock", "Hip-Hop", "R&B", "Country", "Electronic", 
        "Indie", "Alternative", "Jazz", "Classical", "Reggae", "Folk"
    ]
    
    var body: some View {
        ZStack {
            // Enhanced animated gradient background
            LinearGradient(
                colors: [
                    steps[currentStep].color.opacity(0.4),
                    steps[currentStep].color.opacity(0.2),
                    steps[currentStep].color.opacity(0.05),
                    Color.clear
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animateGradient)
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .opacity(currentStep > 0 ? 1 : 0)
                    .animation(.easeInOut, value: currentStep)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                
                Spacer()
                
                // Step content
                stepContent
                
                Spacer()
                
                // Navigation controls
                navigationControls
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .onAppear {
            animateGradient = true
        }
    }
    
    private var stepContent: some View {
        Group {
            switch steps[currentStep].type {
            case .welcome:
                welcomeStepContent
            case .genreSelection:
                genreSelectionContent
            case .difficultySelection:
                difficultySelectionContent
            case .demo:
                demoStepContent
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentStep)
    }
    
    private var welcomeStepContent: some View {
        VStack(spacing: 40) {
            // Enhanced icon with audio waveform animation
            ZStack {
                Circle()
                    .fill(steps[currentStep].color.opacity(0.15))
                    .frame(width: 140, height: 140)
                
                // Animated waveform background
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(steps[currentStep].color.opacity(0.3))
                            .frame(width: 3, height: CGFloat.random(in: 20...60))
                            .animation(
                                .easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.1),
                                value: animateGradient
                            )
                    }
                }
                .offset(y: -5)
                
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [steps[currentStep].color, steps[currentStep].color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(1.1)
            }
            
            VStack(spacing: 20) {
                Text(steps[currentStep].title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                
                Text(steps[currentStep].description)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
            }
        }
    }
    
    private var genreSelectionContent: some View {
        VStack(spacing: 32) {
            // Icon
            ZStack {
                Circle()
                    .fill(steps[currentStep].color.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 45, weight: .medium))
                    .foregroundStyle(steps[currentStep].color)
            }
            
            VStack(spacing: 16) {
                Text(steps[currentStep].title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(steps[currentStep].description)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            
            // Genre selection grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(availableGenres, id: \.self) { genre in
                    Button {
                        if selectedGenres.contains(genre) {
                            selectedGenres.remove(genre)
                        } else {
                            selectedGenres.insert(genre)
                        }
                    } label: {
                        Text(genre)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                selectedGenres.contains(genre) ? 
                                steps[currentStep].color.opacity(0.2) : 
                                Color(.systemGray6)
                            )
                            .foregroundStyle(
                                selectedGenres.contains(genre) ? 
                                steps[currentStep].color : 
                                .primary
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(
                                        selectedGenres.contains(genre) ? 
                                        steps[currentStep].color : 
                                        Color.clear, 
                                        lineWidth: 1
                                    )
                            )
                    }
                    .scaleEffect(selectedGenres.contains(genre) ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3), value: selectedGenres)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var difficultySelectionContent: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(steps[currentStep].color.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 45, weight: .medium))
                    .foregroundStyle(steps[currentStep].color)
            }
            
            VStack(spacing: 16) {
                Text(steps[currentStep].title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(steps[currentStep].description)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 16) {
                ForEach(GameDifficulty.allCases, id: \.self) { difficulty in
                    Button {
                        selectedDifficulty = difficulty
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(difficulty.displayName)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text(difficulty.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: selectedDifficulty == difficulty ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedDifficulty == difficulty ? steps[currentStep].color : .secondary)
                        }
                        .padding()
                        .background(
                            selectedDifficulty == difficulty ? 
                            steps[currentStep].color.opacity(0.1) : 
                            Color(.systemGray6)
                        )
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedDifficulty == difficulty ? 
                                    steps[currentStep].color : 
                                    Color.clear, 
                                    lineWidth: 1
                                )
                        )
                    }
                    .scaleEffect(selectedDifficulty == difficulty ? 1.02 : 1.0)
                    .animation(.spring(response: 0.3), value: selectedDifficulty)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var demoStepContent: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(steps[currentStep].color.opacity(0.15))
                    .frame(width: 120, height: 120)
                
                Button {
                    playDemoAudio()
                } label: {
                    Image(systemName: isPlayingDemo ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(steps[currentStep].color)
                        .scaleEffect(isPlayingDemo ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3), value: isPlayingDemo)
                }
            }
            
            VStack(spacing: 16) {
                Text(steps[currentStep].title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(steps[currentStep].description)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 12) {
                Text("🎵 Sample: \"Bohemian Rhapsody\" by Queen")
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                
                Text("Tap the play button to hear a 1-second clip!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var navigationControls: some View {
        VStack(spacing: 24) {
            // Enhanced step indicator
            HStack(spacing: 12) {
                ForEach(0..<steps.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(index <= currentStep ? steps[currentStep].color : Color.secondary.opacity(0.3))
                        .frame(width: index == currentStep ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
                }
            }
            
            // Enhanced navigation buttons
            HStack(spacing: 20) {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            currentStep -= 1
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                }
                
                Spacer()
                
                Button(nextButtonText) {
                    if currentStep < steps.count - 1 {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            currentStep += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(steps[currentStep].color)
                .disabled(isNextButtonDisabled)
                .opacity(isNextButtonDisabled ? 0.6 : 1.0)
            }
        }
    }
    
    private var nextButtonText: String {
        switch currentStep {
        case steps.count - 1:
            return "Start Playing!"
        case 1:
            return selectedGenres.isEmpty ? "Skip" : "Continue"
        default:
            return "Continue"
        }
    }
    
    private var isNextButtonDisabled: Bool {
        return false
    }
    
    private func completeOnboarding() {
        saveUserPreferences()
        withAnimation(.easeInOut) {
            isPresented = false
        }
    }
    
    private func saveUserPreferences() {
        UserDefaults.standard.set(Array(selectedGenres), forKey: "preferredGenres")
        UserDefaults.standard.set(selectedDifficulty.rawValue, forKey: "preferredDifficulty")
    }
    
    private func playDemoAudio() {
        // In a real implementation, this would play a demo audio clip
        // For now, just toggle the playing state
        isPlayingDemo.toggle()
        
        if isPlayingDemo {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isPlayingDemo = false
            }
        }
    }
}

struct WelcomeStep {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let type: StepType
}

enum StepType {
    case welcome
    case genreSelection
    case difficultySelection
    case demo
}

enum GameDifficulty: String, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    var displayName: String {
        switch self {
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
        }
    }
    
    var description: String {
        switch self {
        case .easy:
            return "More time, popular songs only"
        case .medium:
            return "Balanced gameplay experience"
        case .hard:
            return "Quick thinking, all songs"
        }
    }
}

#Preview {
    WelcomeView(isPresented: .constant(true))
}