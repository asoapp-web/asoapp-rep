//
//  GameCardView.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//



import SwiftUI
// MARK: - Game Card View
struct GameCardView: View {
    let gameType: GameType
    @ObservedObject var gameManager: BrainGameManager
    
    var body: some View {
        NavigationLink(destination: gameDestination) {
            VStack(spacing: 12) {
                GameIconView(gameType: gameType)
                
                Text(gameType.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Level \(gameManager.unlockedLevels[gameType] ?? 1)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                ProgressView(value: Double(gameManager.unlockedLevels[gameType] ?? 1), total: 10)
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .padding(.horizontal)
            }
            .padding()
            .frame(height: 150)
            .background(gameColor.opacity(0.7))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var gameDestination: some View {
        switch gameType {
        case .memory:
            return AnyView(MemoryGameView(gameManager: gameManager))
        case .sequence:
            return AnyView(SequenceGameView(gameManager: gameManager))
        case .logic:
            return AnyView(LogicGridGameView(gameManager: gameManager))
        case .pattern:
            return AnyView(PatternGameView(gameManager: gameManager))
        case .math:
            return AnyView(MathGameView(gameManager: gameManager))
        case .visual:
            return AnyView(VisualGameView(gameManager: gameManager))
        case .word:
            return AnyView(WordGameView(gameManager: gameManager))
        case .speed:
            return AnyView(SpeedGameView(gameManager: gameManager))
        }
    }
    
    private var gameColor: Color {
        switch gameType {
        case .memory: return .blue
        case .sequence: return .green
        case .logic: return .orange
        case .pattern: return .purple
        case .math: return .red
        case .visual: return .pink
        case .word: return .indigo
        case .speed: return .teal
        }
    }
}