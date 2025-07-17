# Heardle iOS App

A SwiftUI mobile version of your Heardle web game - guess the song from short audio clips!

## Features

- 🎵 **Artist Search**: Search and select from thousands of artists
- 🎮 **Progressive Gameplay**: Audio clips get longer with each attempt (1s → 5s)
- 🏆 **Smart Scoring**: Points based on attempts, with time bonuses and streak multipliers
- 📱 **Native iOS Experience**: Haptic feedback, native audio controls, and smooth animations
- 🎨 **Beautiful UI**: Audio visualizer, progress indicators, and polished interface
- 📊 **Game Statistics**: Track accuracy, streaks, and performance
- 📤 **Share Results**: Share your scores with friends
- 🌙 **Dark Mode**: Full support for light and dark themes

## Architecture

### Models
- `Artist`: Artist data with Apple Music integration
- `Song`: Song metadata including artwork and preview URLs
- `GameState`: Observable game state management with scoring logic

### Services
- `APIService`: Network layer for artist search and song fetching
- `AudioService`: AVFoundation-based audio playback with fade effects

### Views
- `HomeView`: Artist search and selection
- `GameView`: Main gameplay interface with audio controls
- `GameResultsView`: Score summary and sharing capabilities
- Various reusable components for UI consistency

## Setup Instructions

### Prerequisites
1. **Xcode 15.0+** with iOS 17.0+ deployment target
2. **Web Backend**: Your Next.js web app must be running locally or deployed

### Configuration

1. **Update API Base URL**:
   ```swift
   // In Heardle/Services/APIService.swift
   private let baseURL = "https://your-domain.com" // Replace with your actual domain
   ```

2. **Configure Network Security** (for development):
   The `Info.plist` includes network security exceptions for localhost and Apple Music domains.

3. **Web Backend**:
   Ensure your web app is running and the mobile API endpoints are accessible:
   - `/api/mobile/artists?q={query}` - Artist search
   - `/api/mobile/songs?artistId={id}` - Song fetching

### Running the App

1. Open `Heardle.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run (⌘+R)

### Mobile API Enhancements

The app uses dedicated mobile API endpoints that provide:
- **Better Caching**: Appropriate cache headers for mobile networks
- **Image Optimization**: Fallback images for missing artwork
- **Filtered Results**: Only songs with valid preview URLs
- **Mobile-Optimized Responses**: Streamlined data for better performance

## Key Mobile UX Features

### Audio Experience
- **Smooth Playback**: Fade in/out effects for professional audio experience
- **Visual Feedback**: Real-time audio visualizer during playback
- **Native Controls**: iOS-style play/pause buttons and progress indicators

### Interactive Elements
- **Haptic Feedback**: Tactile responses for game interactions
- **Pull-to-Refresh**: Native iOS gesture support for search
- **Sheet Presentations**: Native iOS modals for song selection

### Performance Optimizations
- **Lazy Loading**: Efficient image loading with AsyncImage
- **Memory Management**: Proper cleanup of audio resources
- **Background Audio**: Support for audio playback in background

## Game Flow

1. **Search**: User searches for an artist
2. **Setup**: Select difficulty and start game
3. **Gameplay**: 
   - Listen to 1-second audio clip
   - Guess the song or skip for longer clip
   - Immediate feedback with artwork and scoring
4. **Results**: Final score with statistics and sharing options

## Technical Details

- **iOS 17.0+** with SwiftUI and Observation framework
- **AVFoundation** for audio playback
- **Async/Await** for network operations
- **MVVM Architecture** with Observable objects
- **Native Networking** with URLSession
- **Proper Error Handling** with user-friendly messages

## Future Enhancements

- [ ] Offline score persistence with Core Data
- [ ] Game Center integration for leaderboards
- [ ] Custom difficulty settings
- [ ] Playlist-based challenges
- [ ] Apple Music integration for full song playback
- [ ] Social features and challenges