//
//  MemoryGame.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//


import SwiftUI

// MARK: - Memory Game
class MemoryGame: ObservableObject {
    @Published var cards: [MemoryCard] = []
    @Published var level: Int = 1
    @Published var score: Int = 0
    @Published var gameState: GameState = .playing
    @Published var timeRemaining: Int = 60
    @Published var hintsRemaining: Int = 3
    @Published var moves: Int = 0
    @Published var streak: Int = 0
    
    private var timer: Timer?
    private var firstSelectedCardIndex: Int?
    
    init(level: Int = 1) {
        self.level = level
        startNewGame()
    }
    
    func startNewGame() {
        level = 1
        score = 0
        gameState = .playing
        hintsRemaining = 3
        moves = 0
        streak = 0
        setupLevel()
    }
    
    func setupLevel() {
        let pairsCount = min(level + 2, 8) // Max 8 pairs
        let symbols = ["🧠", "🌟", "🚀", "🎯", "💡", "⚡️", "🎮", "🏆", "🎨", "🎭", "🎪", "🎲", "🔑", "💎", "🔮", "⭐️"]
        
        var newCards: [MemoryCard] = []
        
        // ВАЖНО: В каждой игровой сессии минимум одна пара карточек с ChickenEmoji
        // Добавляем пару ChickenEmoji
        newCards.append(MemoryCard(content: "ChickenEmoji"))
        newCards.append(MemoryCard(content: "ChickenEmoji"))
        
        // Добавляем остальные пары карточек
        let remainingPairs = pairsCount - 1 // Уже добавили одну пару
        for i in 0..<remainingPairs {
            let symbol = symbols[i % symbols.count]
            newCards.append(MemoryCard(content: symbol))
            newCards.append(MemoryCard(content: symbol))
        }
        
        // Add distraction cards at higher levels
        if level >= 4 {
            let distractionSymbols = ["❌", "⚙️", "🔧", "📌"]
            for _ in 0..<(level - 2) {
                if let symbol = distractionSymbols.randomElement() {
                    newCards.append(MemoryCard(content: symbol))
                }
            }
        }
        
        cards = newCards.shuffled()
        timeRemaining = max(30, 60 - (level * 8)) // Minimum 30 seconds
        startTimer()
    }
    
    func selectCard(_ card: MemoryCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }),
              !cards[index].isFaceUp,
              !cards[index].isMatched,
              gameState == .playing else { return }
        
        cards[index].isFaceUp = true
        moves += 1
        
        if let firstIndex = firstSelectedCardIndex {
            if cards[firstIndex].content == cards[index].content {
                cards[firstIndex].isMatched = true
                cards[index].isMatched = true
                streak += 1
                let baseScore = 10 * level
                let streakBonus = streak * 5
                let timeBonus = max(0, timeRemaining / 10)
                score += baseScore + streakBonus + timeBonus
                
                if cards.filter({ !$0.content.contains("❌") && !$0.content.contains("⚙️") && !$0.content.contains("🔧") && !$0.content.contains("📌") }).allSatisfy({ $0.isMatched }) {
                    levelCompleted()
                }
            } else {
                streak = 0
                // Check if it's a distraction card
                if cards[index].content == "❌" || cards[index].content == "⚙️" || cards[index].content == "🔧" || cards[index].content == "📌" {
                    score = max(0, score - 20)
                    timeRemaining = max(5, timeRemaining - 5)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.cards[firstIndex].isFaceUp = false
                    self.cards[index].isFaceUp = false
                }
            }
            firstSelectedCardIndex = nil
        } else {
            firstSelectedCardIndex = index
        }
    }
    
    func useHint() {
        guard hintsRemaining > 0, gameState == .playing else { return }
        
        let unmatchedCards = cards.enumerated().filter {
            !$0.element.isMatched && !$0.element.isFaceUp &&
            !["❌", "⚙️", "🔧", "📌"].contains($0.element.content)
        }
        
        if unmatchedCards.count >= 2 {
            hintsRemaining -= 1
            let firstCard = unmatchedCards[0]
            let matchingCard = unmatchedCards.first(where: { $0.element.content == firstCard.element.content })
            
            if let matchingIndex = matchingCard?.offset {
                cards[firstCard.offset].isFaceUp = true
                cards[matchingIndex].isFaceUp = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.cards[firstCard.offset].isFaceUp = false
                    self.cards[matchingIndex].isFaceUp = false
                }
            }
        }
    }
    
    private func levelCompleted() {
        timer?.invalidate()
        if level >= 8 {
            gameState = .won
        } else {
            level += 1
            hintsRemaining += 1 // Reward with extra hint
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.setupLevel()
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
    
    deinit {
        timer?.invalidate()
    }
}