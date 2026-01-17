//
//  BrainGameManager.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//


import SwiftUI

// MARK: - Game Manager
class BrainGameManager: ObservableObject {
    @Published var currentGame: GameType = .memory
    @Published var totalScore: Int = 0
    @Published var unlockedLevels: [GameType: Int] = [:]
    @Published var achievements: [String] = []
    
    init() {
        for game in GameType.allCases {
            unlockedLevels[game] = 1
        }
    }
    
    func completeLevel(_ game: GameType, level: Int, score: Int) {
        totalScore += score
        if unlockedLevels[game] == level {
            unlockedLevels[game] = level + 1
        }
        
        // Check for achievements
        if totalScore >= 1000 && !achievements.contains("Score Master") {
            achievements.append("Score Master")
        }
        if level >= 10 && !achievements.contains("Level Expert") {
            achievements.append("Level Expert")
        }
    }
}
