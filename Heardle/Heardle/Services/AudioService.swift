import Foundation
import AVFoundation
import Combine

@Observable
class AudioService: NSObject {
    static let shared = AudioService()
    
    private var player: AVPlayer?
    private var currentTimeObserver: Any?
    private var playerTimeControlObserver: NSKeyValueObservation?
    
    var isPlaying: Bool = false
    var currentTime: Double = 0
    var duration: Double = 0
    var volume: Float = 0.7
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    deinit {
        cleanup()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func loadAudio(from url: String) async throws {
        guard let audioURL = URL(string: url) else {
            throw AudioError.invalidURL
        }
        
        await MainActor.run {
            cleanup()
            
            player = AVPlayer(url: audioURL)
            player?.volume = volume
            
            setupPlayerObservers()
        }
        
        // Wait for player to be ready
        try await waitForPlayerReady()
    }
    
    private func waitForPlayerReady() async throws {
        guard let player = player else { throw AudioError.playerNotReady }
        
        return try await withCheckedThrowingContinuation { continuation in
            var hasResumed = false
            var observation: NSKeyValueObservation?
            var timeoutTask: DispatchWorkItem?
            
            observation = player.observe(\.status) { player, _ in
                guard !hasResumed else { return }
                
                switch player.status {
                case .readyToPlay:
                    hasResumed = true
                    observation?.invalidate()
                    timeoutTask?.cancel()
                    continuation.resume()
                case .failed:
                    hasResumed = true
                    observation?.invalidate()
                    timeoutTask?.cancel()
                    continuation.resume(throwing: AudioError.loadFailed)
                default:
                    break
                }
            }
            
            // Clean up observation after 10 seconds
            timeoutTask = DispatchWorkItem {
                guard !hasResumed else { return }
                hasResumed = true
                observation?.invalidate()
                continuation.resume(throwing: AudioError.timeout)
            }
            
            if let timeoutTask = timeoutTask {
                DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: timeoutTask)
            }
        }
    }
    
    func play(for duration: TimeInterval) async {
        guard let player = player else { return }
        
        await MainActor.run {
            player.seek(to: .zero)
            player.play()
            isPlaying = true
        }
        
        // Fade in
        await fadeVolume(from: 0, to: volume, duration: 0.3)
        
        // Play for specified duration
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
        
        // Fade out and stop
        await fadeVolume(from: volume, to: 0, duration: 0.3)
        await stop()
    }
    
    func stop() async {
        await MainActor.run {
            player?.pause()
            isPlaying = false
            currentTime = 0
        }
    }
    
    private func fadeVolume(from startVolume: Float, to endVolume: Float, duration: TimeInterval) async {
        guard let player = player else { return }
        
        let steps = 20
        let stepDuration = duration / Double(steps)
        let volumeStep = (endVolume - startVolume) / Float(steps)
        
        for i in 0...steps {
            let currentVolume = startVolume + (volumeStep * Float(i))
            await MainActor.run {
                player.volume = currentVolume
            }
            try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
        }
    }
    
    private func setupPlayerObservers() {
        guard let player = player else { return }
        
        // Time observer
        currentTimeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 1000),
            queue: .main
        ) { [weak self] time in
            self?.currentTime = time.seconds
        }
        
        // Player state observer
        playerTimeControlObserver = player.observe(\.timeControlStatus) { [weak self] player, _ in
            DispatchQueue.main.async {
                self?.isPlaying = player.timeControlStatus == .playing
            }
        }
    }
    
    private func cleanup() {
        if let observer = currentTimeObserver {
            player?.removeTimeObserver(observer)
            currentTimeObserver = nil
        }
        
        playerTimeControlObserver?.invalidate()
        playerTimeControlObserver = nil
        
        player?.pause()
        player = nil
        isPlaying = false
        currentTime = 0
    }
    
    enum AudioError: Error, LocalizedError {
        case invalidURL
        case playerNotReady
        case loadFailed
        case timeout
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid audio URL"
            case .playerNotReady:
                return "Audio player not ready"
            case .loadFailed:
                return "Failed to load audio"
            case .timeout:
                return "Audio loading timeout"
            }
        }
    }
}

// MARK: - Audio Visualization Support
extension AudioService {
    func getAudioLevels() -> [Float] {
        // Simulated audio levels for visualization
        // In a real implementation, you'd use AVAudioEngine for real-time analysis
        return (0..<32).map { _ in Float.random(in: 0.1...0.9) }
    }
}