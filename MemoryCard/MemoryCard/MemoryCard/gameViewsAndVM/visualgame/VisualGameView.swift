//
//  VisualGameView.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//


import SwiftUI
// Visual Game View
struct VisualGameView: View {
    @ObservedObject var gameManager: BrainGameManager
    @StateObject private var game: VisualGame
    @Environment(\.presentationMode) var presentationMode
    
    init(gameManager: BrainGameManager) {
        self.gameManager = gameManager
        _game = StateObject(wrappedValue: VisualGame(level: gameManager.unlockedLevels[.visual] ?? 1))
    }
    
    var body: some View {
        ZStack {
            Image("bg2")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.948)
            
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            GameContainerView(
                gameManager: gameManager,
                gameType: .visual,
                gameState: game.gameState,
                score: game.score,
                level: game.level,
                timeRemaining: game.timeRemaining,
                onBack: { presentationMode.wrappedValue.dismiss() },
                onRestart: { game.startNewGame() }
            ) {
                VStack(spacing: 30) {
                    Text("Find the Different Pattern!")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                        ForEach(0..<4, id: \.self) { index in
                            VisualPatternView(
                                pattern: game.patterns[index],
                                rotation: game.rotationAngles[index],
                                onTap: { game.checkAnswer(index) }
                            )
                        }
                    }
                    .padding()
                    
                    Text("Level \(game.level)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
    }
}
