//
//  PatternGame.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//


import SwiftUI

// MARK: - Pattern Game
class PatternGame: ObservableObject {
    @Published var patterns: [[String]] = []
    @Published var correctIndex: Int = 0
    @Published var level: Int = 1
    @Published var score: Int = 0
    @Published var gameState: GameState = .playing
    @Published var timeRemaining: Int = 25
    @Published var lives: Int = 3
    
    private var timer: Timer?
    private let symbols = ["●", "○", "■", "▲", "★", "♦", "♠", "♥", "♣"]
    private let complexPatterns = ["●●○", "■▲■", "★♦★", "♠♥♣"]
    
    init(level: Int = 1) {
        self.level = level
        startNewGame()
    }
    
    func startNewGame() {
        score = 0
        gameState = .playing
        timeRemaining = 25
        lives = 3
        generatePatterns()
        startTimer()
    }
    
    func generatePatterns() {
        patterns = []
        correctIndex = Int.random(in: 0..<4)
        
        var basePattern: [String] = []
        let gridSize = level >= 4 ? 4 : 3
        
        // Generate base pattern with increasing complexity
        for _ in 0..<(gridSize * gridSize) {
            basePattern.append(symbols.randomElement()!)
        }
        
        // Apply pattern rules at higher levels
        if level >= 3 {
            basePattern = applyPatternRules(to: basePattern, gridSize: gridSize)
        }
        
        for i in 0..<4 {
            if i == correctIndex {
                var differentPattern = basePattern
                let changes = min(level, 3) // More changes at higher levels
                for _ in 0..<changes {
                    let changeIndex = Int.random(in: 0..<differentPattern.count)
                    var newSymbol = symbols.randomElement()!
                    while newSymbol == differentPattern[changeIndex] {
                        newSymbol = symbols.randomElement()!
                    }
                    differentPattern[changeIndex] = newSymbol
                }
                patterns.append(differentPattern)
            } else {
                patterns.append(basePattern)
            }
        }
    }
    
    private func applyPatternRules(to pattern: [String], gridSize: Int) -> [String] {
        var modified = pattern
        // Add some logical pattern
        for i in 0..<gridSize {
            for j in 0..<gridSize {
                let index = i * gridSize + j
                if level >= 5 && i == j { // Diagonal pattern
                    modified[index] = "★"
                }
                if level >= 7 && (i + j) % 2 == 0 { // Checkerboard pattern
                    modified[index] = "●"
                }
            }
        }
        return modified
    }
    
    func checkAnswer(_ index: Int) {
        if index == correctIndex {
            let baseScore = 20 * level
            let timeBonus = max(0, timeRemaining / 2)
            score += baseScore + timeBonus
            level += 1
            
            if level > 10 {
                gameState = .won
                timer?.invalidate()
            } else {
                timeRemaining += 5 // Time bonus
                generatePatterns()
            }
        } else {
            lives -= 1
            if lives <= 0 {
                gameState = .lost
                timer?.invalidate()
            } else {
                generatePatterns()
            }
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