//
//  MemoryGameView.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//


// MARK: - Individual Game Views
import SwiftUI
// Memory Game View
struct MemoryGameView: View {
    @ObservedObject var gameManager: BrainGameManager
    @StateObject private var game: MemoryGame
    @Environment(\.presentationMode) var presentationMode
    
    init(gameManager: BrainGameManager) {
        self.gameManager = gameManager
        _game = StateObject(wrappedValue: MemoryGame(level: gameManager.unlockedLevels[.memory] ?? 1))
    }
    
    var body: some View {
        ZStack {
            Image("bg4")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.948)
            
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            GameContainerView(
                gameManager: gameManager,
                gameType: .memory,
                gameState: game.gameState,
                score: game.score,
                level: game.level,
                timeRemaining: game.timeRemaining,
                onBack: { presentationMode.wrappedValue.dismiss() },
                onRestart: { game.startNewGame() }
            ) {
                VStack {
                    HStack {
                        Text("Moves: \(game.moves)")
                            .foregroundColor(.white)
                        Text("Streak: \(game.streak)")
                            .foregroundColor(.white)
                        Spacer()
                        Text("Lives: \(game.hintsRemaining)")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: gridColumns), spacing: 10) {
                        ForEach(game.cards) { card in
                            MemoryCardView(card: card)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        game.selectCard(card)
                                    }
                                }
                        }
                    }
                    .padding()
                    
                    HintButtonView(hintsRemaining: game.hintsRemaining) {
                        game.useHint()
                    }
                }
            }
        }
    }
    
    private var gridColumns: Int {
        switch game.level {
        case 1...2: return 3
        case 3...4: return 4
        case 5...6: return 5
        default: return 6
        }
    }
}
