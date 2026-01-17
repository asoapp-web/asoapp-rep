//
//  SpeedGame.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//





import SwiftUI
// MARK: - Speed Game
class SpeedGame: ObservableObject {
    @Published var items: [SpeedItem] = []
    @Published var level: Int = 1
    @Published var score: Int = 0
    @Published var gameState: GameState = .playing
    @Published var timeRemaining: Int = 30
    @Published var targetsHit: Int = 0
    @Published var combo: Int = 0
    @Published var spawnRate: Double = 2.0
    
    private var timer: Timer?
    private var spawnTimer: Timer?
    private let symbols = ["🎯", "⭐️", "🔴", "🔵", "🟢", "🟡", "🟣", "🟠"]
    private let targetSymbols = ["🎯", "⭐️"]
    
    init(level: Int = 1) {
        self.level = level
        startNewGame()
    }
    
    func startNewGame() {
        items = []
        score = 0
        gameState = .playing
        timeRemaining = 30
        targetsHit = 0
        combo = 0
        spawnRate = max(0.5, 2.0 - Double(level) * 0.1)
        startTimers()
    }
    
    func startTimers() {
        // Main game timer
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopGame()
                self.gameState = .lost
            }
        }
        
        // Item spawn timer
        spawnTimer?.invalidate()
        spawnTimer = Timer.scheduledTimer(withTimeInterval: spawnRate, repeats: true) { _ in
            self.spawnItem()
        }
    }
    
    func spawnItem() {
        let isTarget = Double.random(in: 0...1) > 0.7 // 30% chance for target
        let symbol = isTarget ? targetSymbols.randomElement()! : symbols.randomElement()!
        
        let newItem = SpeedItem(
            symbol: symbol,
            isTarget: isTarget
        )
        
        items.append(newItem)
        
        // Remove old items to prevent memory issues
        if items.count > 15 {
            items.removeFirst(5)
        }
    }
    
    func tapItem(_ item: SpeedItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
            
            if item.isTarget {
                targetsHit += 1
                combo += 1
                let baseScore = 10 * level
                let comboBonus = combo * 5
                let timeBonus = max(0, timeRemaining / 5)
                score += baseScore + comboBonus + timeBonus
                
                if targetsHit >= 5 * level {
                    level += 1
                    targetsHit = 0
                    spawnRate = max(0.3, spawnRate - 0.1)
                    spawnTimer?.invalidate()
                    startTimers()
                }
                
                if level > 10 {
                    gameState = .won
                    stopGame()
                }
            } else {
                combo = 0
                timeRemaining = max(5, timeRemaining - 2)
            }
        }
    }
    
    private func stopGame() {
        timer?.invalidate()
        spawnTimer?.invalidate()
    }
    
    deinit {
        stopGame()
    }
}