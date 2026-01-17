//
//  WordGame.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//



import SwiftUI
// MARK: - Word Game
class WordGame: ObservableObject {
    @Published var currentPuzzle: WordPuzzle
    @Published var userInput: String = ""
    @Published var level: Int = 1
    @Published var score: Int = 0
    @Published var gameState: GameState = .playing
    @Published var timeRemaining: Int = 45
    @Published var showHint: Bool = false
    @Published var puzzlesSolved: Int = 0
    
    private var timer: Timer?
    private let wordPuzzles: [WordPuzzle] = [
        WordPuzzle(scrambled: "ELBTA", correct: "TABLE", hint: "Furniture with four legs"),
        WordPuzzle(scrambled: "RAEDC", correct: "CARED", hint: "Past tense of care"),
        WordPuzzle(scrambled: "TSARE", correct: "STARE", hint: "To look intently"),
        WordPuzzle(scrambled: "GINTES", correct: "INGEST", hint: "To consume or take in"),
        WordPuzzle(scrambled: "CRATEF", correct: "FRACTE", hint: "To break or crack"),
        WordPuzzle(scrambled: "LEVART", correct: "TRAVEL", hint: "To go on a journey"),
        WordPuzzle(scrambled: "BRILAL", correct: "RIBBAL", hint: "Mischievous person"),
        WordPuzzle(scrambled: "MENTLAA", correct: "MANTLE", hint: "Cloak or covering")
    ]
    
    init(level: Int = 1) {
        self.level = level
        self.currentPuzzle = wordPuzzles[0]
        startNewGame()
    }
    
    func startNewGame() {
        score = 0
        gameState = .playing
        timeRemaining = 45
        puzzlesSolved = 0
        showHint = false
        loadPuzzle()
        startTimer()
    }
    
    func loadPuzzle() {
        let puzzleIndex = (level - 1 + puzzlesSolved) % wordPuzzles.count
        currentPuzzle = wordPuzzles[puzzleIndex]
        userInput = ""
        showHint = false
    }
    
    func submitAnswer() {
        if userInput.uppercased() == currentPuzzle.correct {
            puzzlesSolved += 1
            let baseScore = 20 * level
            let timeBonus = max(0, timeRemaining / 2)
            score += baseScore + timeBonus
            
            if puzzlesSolved >= 3 {
                level += 1
                puzzlesSolved = 0
            }
            
            if level > 8 {
                gameState = .won
                timer?.invalidate()
            } else {
                timeRemaining += 10
                loadPuzzle()
            }
        } else {
            timeRemaining = max(10, timeRemaining - 10)
        }
    }
    
    func toggleHint() {
        showHint.toggle()
        if showHint {
            timeRemaining = max(5, timeRemaining - 8)
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