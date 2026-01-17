//
//  MathGameView.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//


import SwiftUI

// Math Game View
struct MathGameView: View {
    @ObservedObject var gameManager: BrainGameManager
    @StateObject private var game: MathGame
    @Environment(\.presentationMode) var presentationMode
    @State private var userAnswer: String = ""
    
    init(gameManager: BrainGameManager) {
        self.gameManager = gameManager
        _game = StateObject(wrappedValue: MathGame(level: gameManager.unlockedLevels[.math] ?? 1))
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
                gameType: .math,
                gameState: game.gameState,
                score: game.score,
                level: game.level,
                timeRemaining: game.timeRemaining,
                onBack: { presentationMode.wrappedValue.dismiss() },
                onRestart: { game.startNewGame() }
            ) {
                VStack(spacing: 30) {
                    HStack {
                        Text("Correct: \(game.correctAnswers)")
                            .foregroundColor(.white)
                        Text("Wrong: \(game.wrongAnswers)")
                            .foregroundColor(.white)
                        Text("Streak: \(game.streak)")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    Text("Solve the Math Problem!")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text(game.currentProblem)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(15)
                    
                    TextField("Enter answer", text: $userAnswer)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 40)
                        .colorScheme(.dark)
                    
                    Button("Submit Answer") {
                        game.submitAnswer(userAnswer)
                        userAnswer = ""
                    }
                    .disabled(userAnswer.isEmpty)
                    .padding()
                    .background(userAnswer.isEmpty ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}
