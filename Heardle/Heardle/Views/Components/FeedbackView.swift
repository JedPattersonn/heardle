import SwiftUI

struct FeedbackView: View {
    let isCorrect: Bool
    let song: Song?
    let points: Int
    let bonusPoints: Int
    let guessTime: TimeInterval
    
    var body: some View {
        VStack(spacing: 24) {
            // Result icon
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(isCorrect ? .green : .red)
                .scaleEffect(1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isCorrect)
            
            // Song artwork
            if let song = song {
                AsyncImage(url: URL(string: song.attributes.artwork.imageUrl(size: 200))) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.quaternary)
                        .overlay {
                            Image(systemName: "music.note")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                        }
                }
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 8)
            }
            
            VStack(spacing: 8) {
                Text(isCorrect ? "Correct!" : "Not quite...")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(isCorrect ? .green : .red)
                
                if let song = song {
                    Text(song.attributes.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text(song.attributes.albumName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            if isCorrect {
                VStack(spacing: 8) {
                    if points > 0 {
                        HStack {
                            Image(systemName: "plus")
                            Text("\(points) points")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
                    }
                    
                    if bonusPoints > 0 {
                        HStack {
                            Image(systemName: "bolt.fill")
                            Text("+\(bonusPoints) bonus points")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.orange)
                    }
                    
                    Text("Guessed in \(String(format: "%.1f", guessTime))s")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    VStack(spacing: 40) {
        FeedbackView(
            isCorrect: true,
            song: Song.example,
            points: 5,
            bonusPoints: 2,
            guessTime: 2.3
        )
        
        FeedbackView(
            isCorrect: false,
            song: Song.example,
            points: 0,
            bonusPoints: 0,
            guessTime: 0
        )
    }
}