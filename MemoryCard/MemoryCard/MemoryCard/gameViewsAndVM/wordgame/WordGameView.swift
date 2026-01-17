//
//  WordGameView.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//


import SwiftUI
// Word Game View
struct WordGameView: View {
    @ObservedObject var gameManager: BrainGameManager
    @StateObject private var game: WordGame
    @Environment(\.presentationMode) var presentationMode
    
    init(gameManager: BrainGameManager) {
        self.gameManager = gameManager
        _game = StateObject(wrappedValue: WordGame(level: gameManager.unlockedLevels[.word] ?? 1))
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
                gameType: .word,
                gameState: game.gameState,
                score: game.score,
                level: game.level,
                timeRemaining: game.timeRemaining,
                onBack: { presentationMode.wrappedValue.dismiss() },
                onRestart: { game.startNewGame() }
            ) {
                VStack(spacing: 30) {
                    HStack {
                        Text("Solved: \(game.puzzlesSolved)/3")
                            .foregroundColor(.white)
                        Spacer()
                        Button("Hint") {
                            game.toggleHint()
                        }
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.orange.opacity(0.7))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    Text("Unscramble the Word!")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text(game.currentPuzzle.scrambled)
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(15)
                    
                    if game.showHint {
                        Text("Hint: \(game.currentPuzzle.hint)")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                            .background(Color.orange.opacity(0.3))
                            .cornerRadius(10)
                    }
                    
                    TextField("Enter word", text: $game.userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 40)
                        .colorScheme(.dark)
                        .textInputAutocapitalization(.characters)
                    
                    Button("Submit Answer") {
                        game.submitAnswer()
                    }
                    .disabled(game.userInput.isEmpty)
                    .padding()
                    .background(game.userInput.isEmpty ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}