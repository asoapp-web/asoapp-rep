//
//  SpeedGameView.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//


import SwiftUI
// Speed Game View
struct SpeedGameView: View {
    @ObservedObject var gameManager: BrainGameManager
    @StateObject private var game: SpeedGame
    @Environment(\.presentationMode) var presentationMode
    
    init(gameManager: BrainGameManager) {
        self.gameManager = gameManager
        _game = StateObject(wrappedValue: SpeedGame(level: gameManager.unlockedLevels[.speed] ?? 1))
    }
    
    var body: some View {
        ZStack {
            Image("bg5")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.948)
            
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            GameContainerView(
                gameManager: gameManager,
                gameType: .speed,
                gameState: game.gameState,
                score: game.score,
                level: game.level,
                timeRemaining: game.timeRemaining,
                onBack: { presentationMode.wrappedValue.dismiss() },
                onRestart: { game.startNewGame() }
            ) {
                VStack(spacing: 20) {
                    HStack {
                        Text("Targets: \(game.targetsHit)/\(5 * game.level)")
                            .foregroundColor(.white)
                        Text("Combo: \(game.combo)")
                            .foregroundColor(.white)
                        Spacer()
                        Text("Speed: \(String(format: "%.1f", game.spawnRate))s")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    Text("Tap the targets! 🎯⭐️")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                    
                    ZStack {
                        ForEach(game.items) { item in
                            SpeedItemView(item: item) {
                                game.tapItem(item)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Text("Tap only 🎯 and ⭐️ symbols!")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding()
                }
            }
        }
    }
}
