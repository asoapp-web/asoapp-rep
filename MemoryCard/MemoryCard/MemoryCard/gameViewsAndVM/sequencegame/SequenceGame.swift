//
//  SequenceGame.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//


import SwiftUI

// MARK: - Sequence Game
class SequenceGame: ObservableObject {
    @Published var currentSequence: [String] = []
    @Published var playerSequence: [String] = []
    @Published var level: Int = 1
    @Published var score: Int = 0
    @Published var gameState: GameState = .playing
    @Published var timeRemaining: Int = 30
    @Published var showingSequence = true
    @Published var lives: Int = 3
    @Published var combo: Int = 0
    
    let availableSymbols = ["🔴", "🔵", "🟢", "🟡", "🟣", "🟠", "⚫️", "⚪️", "🟤", "❤️", "💙", "💚"]
    
    private var timer: Timer?
    
    init(level: Int = 1) {
        self.level = level
        startNewGame()
    }
    
    func startNewGame() {
        currentSequence = []
        playerSequence = []
        score = 0
        gameState = .playing
        timeRemaining = 30
        lives = 3
        combo = 0
        generateSequence()
    }
    
    func generateSequence() {
        showingSequence = true
        let sequenceLength = min(level + 3, 15) // Max 15 symbols
        
        // Add complexity: repeating patterns at higher levels
        if level >= 5 {
            currentSequence = generatePatternSequence(length: sequenceLength)
        } else {
            currentSequence = (0..<sequenceLength).map { _ in
                availableSymbols.randomElement()!
            }
        }
        
        playerSequence = []
        
        let displayTime = Double(sequenceLength) * (level >= 8 ? 0.5 : 0.8)
        DispatchQueue.main.asyncAfter(deadline: .now() + displayTime) {
            withAnimation {
                self.showingSequence = false
            }
            self.startTimer()
        }
    }
    
    private func generatePatternSequence(length: Int) -> [String] {
        var sequence: [String] = []
        let patternLength = Int.random(in: 2...4)
        let pattern = (0..<patternLength).map { _ in availableSymbols.randomElement()! }
        
        for i in 0..<length {
            sequence.append(pattern[i % patternLength])
            // Occasionally break the pattern
            if level >= 7 && i % 4 == 3 && Bool.random() {
                sequence.append(availableSymbols.randomElement()!)
            }
        }
        return sequence
    }
    
    func playerInput(_ symbol: String) {
        guard !showingSequence else { return }
        
        playerSequence.append(symbol)
        
        for (index, playerSymbol) in playerSequence.enumerated() {
            if index >= currentSequence.count || playerSymbol != currentSequence[index] {
                // Wrong sequence
                lives -= 1
                combo = 0
                if lives <= 0 {
                    gameState = .lost
                    timer?.invalidate()
                } else {
                    // Show error but continue
                    playerSequence = []
                }
                return
            }
        }
        
        // Correct so far
        if playerSequence.count == currentSequence.count {
            // Completed sequence
            combo += 1
            let baseScore = 15 * level
            let comboBonus = combo * 10
            let timeBonus = max(0, timeRemaining / 5)
            score += baseScore + comboBonus + timeBonus
            
            level += 1
            timeRemaining += 5 // Bonus time
            generateSequence()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.invalidate()
                self.gameState = .lost
            }
        }
    }
}