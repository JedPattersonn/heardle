//
//  ContentView.swift
//  Heardle
//
//  Created by Jed Patterson on 10/06/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedMode: GameMode?
    @State private var selectedTab = 0
    
    enum GameMode {
        case artist
        case genre
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                ScrollView {
                    ZStack {
                        // Background gradient
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "1DB954"), Color(hex: "191414")]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                        
                        VStack(spacing: 25) {
                            // Header
                            Text("Heardle")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.top, 40)
                            
                            Text("Guess the song from a snippet")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                            
                            // Stats Overview
                            HStack(spacing: 20) {
                                StatCard(title: "Win Streak", value: "3", icon: "flame.fill", color: .orange)
                                StatCard(title: "Best Score", value: "98%", icon: "star.fill", color: .yellow)
                            }
                            .padding(.horizontal)
                            
                            // Popular Now Section
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Popular Now")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        PopularCard(title: "Taylor Swift", image: "taylor", color: .pink)
                                        PopularCard(title: "Drake", image: "drake", color: .purple)
                                        PopularCard(title: "Rock Classics", image: "rock", color: .red)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Game Modes
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Choose Mode")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 20) {
                                    GameModeCard(
                                        title: "Artist Mode",
                                        description: "Guess songs from your favorite artists",
                                        systemImage: "music.note.list",
                                        color: Color(hex: "1DB954")
                                    ) {
                                        selectedMode = .artist
                                    }
                                    
                                    GameModeCard(
                                        title: "Genre Mode",
                                        description: "Test your knowledge across different genres",
                                        systemImage: "music.quarternote.3",
                                        color: Color(hex: "FF6B6B")
                                    ) {
                                        selectedMode = .genre
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Recent Games
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Recent Games")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 10) {
                                    RecentGameRow(artist: "The Weeknd", score: "85%", date: "2h ago")
                                    RecentGameRow(artist: "Pop Hits", score: "92%", date: "Yesterday")
                                    RecentGameRow(artist: "Rock Classics", score: "78%", date: "2 days ago")
                                }
                                .padding(.horizontal)
                            }
                            
                            Spacer()
                        }
                    }
                }
                .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            // Stats Tab
            Text("Stats")
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
                .tag(1)
            
            // Profile Tab
            Text("Profile")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(2)
        }
        .accentColor(Color(hex: "1DB954"))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct PopularCard: View {
    let title: String
    let image: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(color)
                    .frame(width: 150, height: 150)
                
                Image(systemName: "music.note")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

struct RecentGameRow: View {
    let artist: String
    let score: String
    let date: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(artist)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(date)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text(score)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct GameModeCard: View {
    let title: String
    let description: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: systemImage)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
