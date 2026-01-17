//
//  HomeView.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//

import SwiftUI
// MARK: - Home View
struct HomeView: View {
    @ObservedObject var gameManager: BrainGameManager
    @State private var showingAbout = false
    
    var body: some View {
        ZStack {
            Image("bg2")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.948)
            
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                HeaderView()
                
                Spacer()
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                        ForEach(GameType.allCases, id: \.self) { gameType in
                            GameCardView(
                                gameType: gameType,
                                gameManager: gameManager
                            )
                        }
                    }
                    .padding()
                }
                
                Button(action: { showingAbout = true }) {
                    Text("About ChickenForges")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
}
