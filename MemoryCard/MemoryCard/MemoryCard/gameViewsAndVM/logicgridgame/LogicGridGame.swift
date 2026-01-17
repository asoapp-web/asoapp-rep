//
//  LogicGridGame.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//

import SwiftUI
// MARK: - Logic Grid Game
class LogicGridGame: ObservableObject {
    @Published var currentPuzzle: LogicPuzzle
    @Published var selectedAnswer: String = ""
    @Published var showResult: Bool = false
    @Published var level: Int = 1
    @Published var score: Int = 0
    @Published var gameState: GameState = .playing
    @Published var timeRemaining: Int = 45
    @Published var puzzlesSolved: Int = 0
    @Published var usedHints: Int = 0
    
    private var timer: Timer?
    private let puzzles: [LogicPuzzle] = [
        LogicPuzzle(
            question: "All trees are plants. Some plants are green. Therefore:",
            options: ["All trees are green", "Some trees are green", "No trees are green", "Cannot be determined"],
            correctAnswer: "Cannot be determined",
            explanation: "We don't know if trees fall into the 'some plants' that are green."
        ),
        LogicPuzzle(
            question: "If A > B and B > C, then:",
            options: ["A < C", "A = C", "A > C", "C > A"],
            correctAnswer: "A > C",
            explanation: "This follows the transitive property of inequality."
        ),
        LogicPuzzle(
            question: "No fish are mammals. All dolphins are mammals. Therefore:",
            options: ["Some dolphins are fish", "No dolphins are fish", "All fish are dolphins", "Dolphins are not animals"],
            correctAnswer: "No dolphins are fish",
            explanation: "If no fish are mammals and all dolphins are mammals, no dolphins can be fish."
        ),
        LogicPuzzle(
            question: "Some doctors are researchers. All researchers are scientists. Therefore:",
            options: ["All doctors are scientists", "Some doctors are scientists", "No doctors are scientists", "All scientists are doctors"],
            correctAnswer: "Some doctors are scientists",
            explanation: "The doctors who are researchers must also be scientists."
        ),
        LogicPuzzle(
            question: "If all squares are rectangles and all rectangles have four sides, then:",
            options: ["All squares have four sides", "Some squares have three sides", "No rectangles have four sides", "Squares are not rectangles"],
            correctAnswer: "All squares have four sides",
            explanation: "This follows the logical chain of inclusion."
        )
    ]
    
    var currentOptions: [String] {
        currentPuzzle.options.shuffled()
    }
    
    init(level: Int = 1) {
        self.level = level
        self.currentPuzzle = puzzles[0]
        startNewGame()
    }
    
    func startNewGame() {
        score = 0
        gameState = .playing
        timeRemaining = 45
        puzzlesSolved = 0
        usedHints = 0
        loadPuzzle()
        startTimer()
    }
    
    func loadPuzzle() {
        let puzzleIndex = (level - 1 + puzzlesSolved) % puzzles.count
        currentPuzzle = puzzles[puzzleIndex]
        selectedAnswer = ""
        showResult = false
    }
    
    func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        showResult = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if answer == self.currentPuzzle.correctAnswer {
                self.puzzlesSolved += 1
                let baseScore = 25 * self.level
                let timeBonus = max(0, self.timeRemaining / 3)
                self.score += baseScore + timeBonus
                
                if self.puzzlesSolved >= 3 {
                    self.level += 1
                    self.puzzlesSolved = 0
                }
                
                if self.level > 6 {
                    self.gameState = .won
                    self.timer?.invalidate()
                } else {
                    self.timeRemaining += 10 // Time bonus for correct answer
                    self.loadPuzzle()
                }
            } else {
                self.timeRemaining = max(10, self.timeRemaining - 15)
                self.loadPuzzle()
            }
        }
    }
    
    func useHint() {
        guard usedHints < 2 else { return }
        usedHints += 1
        timeRemaining = max(10, timeRemaining - 10)
        // In a real app, you would reveal part of the answer here
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
