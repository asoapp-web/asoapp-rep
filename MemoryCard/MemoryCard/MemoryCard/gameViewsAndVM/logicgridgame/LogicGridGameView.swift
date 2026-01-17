//
//  LogicGridGameView.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//



import SwiftUI

// Logic Grid Game View
struct LogicGridGameView: View {
    @ObservedObject var gameManager: BrainGameManager
    @StateObject private var game: LogicGridGame
    @Environment(\.presentationMode) var presentationMode
    
    init(gameManager: BrainGameManager) {
        self.gameManager = gameManager
        _game = StateObject(wrappedValue: LogicGridGame(level: gameManager.unlockedLevels[.logic] ?? 1))
    }
    
    var body: some View {
        ZStack {
            Image("bg1")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.948)
            
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            GameContainerView(
                gameManager: gameManager,
                gameType: .logic,
                gameState: game.gameState,
                score: game.score,
                level: game.level,
                timeRemaining: game.timeRemaining,
                onBack: { presentationMode.wrappedValue.dismiss() },
                onRestart: { game.startNewGame() }
            ) {
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Solved: \(game.puzzlesSolved)/3")
                                .foregroundColor(.white)
                            Spacer()
                            Button("Hint") {
                                game.useHint()
                            }
                            .disabled(game.usedHints >= 2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.orange.opacity(0.7))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        Text("Logic Grid Puzzle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                        
                        Text(game.currentPuzzle.question)
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(15)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                            ForEach(game.currentOptions, id: \.self) { option in
                                LogicOptionButton(
                                    option: option,
                                    isSelected: game.selectedAnswer == option,
                                    isCorrect: game.showResult && option == game.currentPuzzle.correctAnswer,
                                    onTap: { game.selectAnswer(option) }
                                )
                            }
                        }
                        .padding()
                        
                        if game.showResult {
                            Text(game.selectedAnswer == game.currentPuzzle.correctAnswer ? "Correct! 🎉" : "Wrong! 😞")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                }
            }
        }
    }
}
