import SwiftUI

struct WelcomeView: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    @State private var animateGradient = false
    
    private let steps = [
        WelcomeStep(
            icon: "music.note.list",
            title: "Welcome to MusIQ!",
            description: "The ultimate music guessing game where you identify songs from short audio clips.",
            color: .blue
        ),
        WelcomeStep(
            icon: "headphones",
            title: "How to Play",
            description: "Listen to a 1-second clip, then guess the song. Each wrong guess or skip gives you a longer clip!",
            color: .purple
        ),
        WelcomeStep(
            icon: "trophy.fill",
            title: "Score Points",
            description: "Earn points for correct guesses, time bonuses for quick answers, and streak multipliers!",
            color: .orange
        ),
        WelcomeStep(
            icon: "person.2.fill",
            title: "Challenge Friends",
            description: "Share your scores and challenge friends to beat your high streaks and accuracy!",
            color: .green
        )
    ]
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    steps[currentStep].color.opacity(0.3),
                    steps[currentStep].color.opacity(0.1),
                    Color.clear
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateGradient)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Step content
                stepContent
                
                Spacer()
                
                // Navigation controls
                navigationControls
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
        }
        .onAppear {
            animateGradient = true
        }
    }
    
    private var stepContent: some View {
        VStack(spacing: 32) {
            // Icon with animation
            ZStack {
                Circle()
                    .fill(steps[currentStep].color.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [steps[currentStep].color, steps[currentStep].color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentStep)
            }
            
            // Text content
            VStack(spacing: 16) {
                Text(steps[currentStep].title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                
                Text(steps[currentStep].description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
            }
            .animation(.easeInOut(duration: 0.3), value: currentStep)
        }
    }
    
    private var navigationControls: some View {
        VStack(spacing: 20) {
            // Step indicator
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentStep ? steps[currentStep].color : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == currentStep ? 1.2 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
                }
            }
            
            // Navigation buttons
            HStack(spacing: 16) {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            currentStep -= 1
                        }
                    }
                    .buttonStyle(.bordered)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                }
                
                Spacer()
                
                if currentStep < steps.count - 1 {
                    Button("Next") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            currentStep += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(steps[currentStep].color)
                } else {
                    Button("Get Started") {
                        withAnimation(.easeInOut) {
                            isPresented = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(steps[currentStep].color)
                    .controlSize(.large)
                }
            }
        }
    }
}

struct WelcomeStep {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

#Preview {
    WelcomeView(isPresented: .constant(true))
}