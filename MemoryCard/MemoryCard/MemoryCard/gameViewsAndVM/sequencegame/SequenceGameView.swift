//
//  SequenceGameView.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//



import SwiftUI

// Sequence Game View
struct SequenceGameView: View {
    @ObservedObject var gameManager: BrainGameManager
    @StateObject private var game: SequenceGame
    @Environment(\.presentationMode) var presentationMode
    
    init(gameManager: BrainGameManager) {
        self.gameManager = gameManager
        _game = StateObject(wrappedValue: SequenceGame(level: gameManager.unlockedLevels[.sequence] ?? 1))
    }
    
    var body: some View {
        ZStack {
            Image("bg3")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.948)
            
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            GameContainerView(
                gameManager: gameManager,
                gameType: .sequence,
                gameState: game.gameState,
                score: game.score,
                level: game.level,
                timeRemaining: game.timeRemaining,
                onBack: { presentationMode.wrappedValue.dismiss() },
                onRestart: { game.startNewGame() }
            ) {
                VStack(spacing: 30) {
                    HStack {
                        Text("Lives: \(game.lives)")
                            .foregroundColor(.white)
                        Text("Combo: \(game.combo)")
                            .foregroundColor(.white)
                        Spacer()
                        Text("Length: \(game.currentSequence.count)")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    Text("Remember the sequence!")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                    
                    if game.showingSequence {
                        HStack(spacing: 15) {
                            ForEach(game.currentSequence, id: \.self) { symbol in
                                Text(symbol)
                                    .font(.system(size: 35))
                                    .scaleEffect(1.2)
                                    .transition(.scale)
                            }
                        }
                        .padding()
                    } else {
                        Text("Your turn! Tap the sequence")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                        ForEach(game.availableSymbols.prefix(8), id: \.self) { symbol in
                            Button(action: {
                                withAnimation(.spring()) {
                                    game.playerInput(symbol)
                                }
                            }) {
                                Text(symbol)
                                    .font(.system(size: 28))
                                    .frame(width: 60, height: 60)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            }
                            .disabled(game.showingSequence)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}