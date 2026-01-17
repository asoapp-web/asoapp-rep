//
//  MathGame.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//



import SwiftUI

// MARK: - Math Game
class MathGame: ObservableObject {
    @Published var currentProblem: String = ""
    @Published var correctAnswer: Int = 0
    @Published var level: Int = 1
    @Published var score: Int = 0
    @Published var gameState: GameState = .playing
    @Published var timeRemaining: Int = 30
    @Published var correctAnswers: Int = 0
    @Published var wrongAnswers: Int = 0
    @Published var streak: Int = 0
    
    private var timer: Timer?
    
    init(level: Int = 1) {
        self.level = level
        startNewGame()
    }
    
    func startNewGame() {
        score = 0
        correctAnswers = 0
        wrongAnswers = 0
        gameState = .playing
        timeRemaining = 30
        streak = 0
        generateProblem()
        startTimer()
    }
    
    func generateProblem() {
        let operations = getAvailableOperations()
        let operation = operations.randomElement()!
        
        var num1: Int
        var num2: Int
        
        switch level {
        case 1...2:
            num1 = Int.random(in: 1...10)
            num2 = Int.random(in: 1...10)
        case 3...4:
            num1 = Int.random(in: 10...50)
            num2 = Int.random(in: 1...20)
        case 5...6:
            num1 = Int.random(in: 50...100)
            num2 = Int.random(in: 10...50)
        default:
            num1 = Int.random(in: 100...200)
            num2 = Int.random(in: 20...100)
        }
        
        switch operation {
        case "+":
            correctAnswer = num1 + num2
        case "-":
            if num1 < num2 { swap(&num1, &num2) }
            correctAnswer = num1 - num2
        case "×":
            correctAnswer = num1 * num2
        case "÷":
            num2 = Int.random(in: 1...12)
            num1 = num2 * Int.random(in: 1...15)
            correctAnswer = num1 / num2
        case "%": // Percentage
            num1 = Int.random(in: 1...100)
            num2 = Int.random(in: 1...100)
            correctAnswer = (num1 * num2) / 100
        default:
            correctAnswer = num1 + num2
        }
        
        if operation == "%" {
            currentProblem = "\(num1)% of \(num2) = ?"
        } else {
            currentProblem = "\(num1) \(operation) \(num2) = ?"
        }
    }
    
    private func getAvailableOperations() -> [String] {
        switch level {
        case 1...2: return ["+", "-"]
        case 3...4: return ["+", "-", "×"]
        case 5...6: return ["+", "-", "×", "÷"]
        default: return ["+", "-", "×", "÷", "%"]
        }
    }
    
    func submitAnswer(_ answer: String) {
        guard let userAnswer = Int(answer) else { return }
        
        if userAnswer == correctAnswer {
            correctAnswers += 1
            streak += 1
            let baseScore = 15 * level
            let streakBonus = streak * 8
            let timeBonus = max(0, timeRemaining / 3)
            score += baseScore + streakBonus + timeBonus
            level += 1
        } else {
            wrongAnswers += 1
            streak = 0
            timeRemaining = max(5, timeRemaining - 5)
        }
        
        if level > 15 {
            gameState = .won
            timer?.invalidate()
        } else {
            generateProblem()
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