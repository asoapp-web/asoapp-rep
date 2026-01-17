//
//  VisualGame.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//



import SwiftUI
// MARK: - Visual Game
class VisualGame: ObservableObject {
    @Published var patterns: [[String]] = []
    @Published var correctIndex: Int = 0
    @Published var level: Int = 1
    @Published var score: Int = 0
    @Published var gameState: GameState = .playing
    @Published var timeRemaining: Int = 20
    @Published var rotationAngles: [Double] = []
    
    private var timer: Timer?
    private let symbols = ["●", "○", "■", "▲", "★", "♦", "♠", "♥", "♣", "✸", "✦", "❂"]
    
    init(level: Int = 1) {
        self.level = level
        startNewGame()
    }
    
    func startNewGame() {
        score = 0
        gameState = .playing
        timeRemaining = 20
        generatePatterns()
        startTimer()
    }
    
    func generatePatterns() {
        patterns = []
        rotationAngles = []
        correctIndex = Int.random(in: 0..<4)
        
        let gridSize = level >= 4 ? 4 : 3
        var basePattern: [String] = []
        
        // Generate base pattern
        for _ in 0..<(gridSize * gridSize) {
            basePattern.append(symbols.randomElement()!)
        }
        
        // Apply transformations for the different pattern
        for i in 0..<4 {
            if i == correctIndex {
                var differentPattern = basePattern
                let transformation = level >= 3 ? Int.random(in: 0..<3) : 0
                
                switch transformation {
                case 0: // Change symbols
                    let changes = min(level, 4)
                    for _ in 0..<changes {
                        let changeIndex = Int.random(in: 0..<differentPattern.count)
                        var newSymbol = symbols.randomElement()!
                        while newSymbol == differentPattern[changeIndex] {
                            newSymbol = symbols.randomElement()!
                        }
                        differentPattern[changeIndex] = newSymbol
                    }
                case 1: // Rotate pattern
                    differentPattern = rotatePattern(differentPattern, gridSize: gridSize)
                case 2: // Mirror pattern
                    differentPattern = mirrorPattern(differentPattern, gridSize: gridSize)
                default:
                    break
                }
                patterns.append(differentPattern)
                rotationAngles.append(0)
            } else {
                patterns.append(basePattern)
                // Add slight rotation to make it harder
                let rotation = level >= 6 ? Double.random(in: -5...5) : 0
                rotationAngles.append(rotation)
            }
        }
    }
    
    private func rotatePattern(_ pattern: [String], gridSize: Int) -> [String] {
        var rotated = pattern
        for i in 0..<gridSize {
            for j in 0..<gridSize {
                let newIndex = j * gridSize + (gridSize - 1 - i)
                rotated[newIndex] = pattern[i * gridSize + j]
            }
        }
        return rotated
    }
    
    private func mirrorPattern(_ pattern: [String], gridSize: Int) -> [String] {
        var mirrored = pattern
        for i in 0..<gridSize {
            for j in 0..<gridSize {
                let mirrorIndex = i * gridSize + (gridSize - 1 - j)
                mirrored[mirrorIndex] = pattern[i * gridSize + j]
            }
        }
        return mirrored
    }
    
    func checkAnswer(_ index: Int) {
        if index == correctIndex {
            let baseScore = 18 * level
            let timeBonus = max(0, timeRemaining)
            score += baseScore + timeBonus
            level += 1
            
            if level > 12 {
                gameState = .won
                timer?.invalidate()
            } else {
                timeRemaining += 3 // Time bonus
                generatePatterns()
            }
        } else {
            timeRemaining = max(5, timeRemaining - 8)
            generatePatterns()
            
            if timeRemaining <= 0 {
                gameState = .lost
                timer?.invalidate()
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