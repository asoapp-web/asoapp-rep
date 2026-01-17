//
//  AboutView.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//

import SwiftUI
struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Image("bg3")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.948)
            
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                    
                    Spacer()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        HeaderView()
                            .padding(.bottom, 20)
                        
                        AboutSectionView(
                            title: "Welcome to MindForge!",
                            content: "This advanced brain training app is designed to challenge your mind with unique puzzle games that test memory, logic, pattern recognition, and problem-solving skills."
                        )
                        
                        AboutSectionView(
                            title: "Game Features",
                            content: """
                            • 8 Different MindForge Categories
                            • Hundreds of Challenging Levels
                            • Progressive Difficulty System
                            • Real-time Score Tracking
                            • Time-based Challenges
                            • Hint System for Difficult Levels
                            • Beautiful Animated Interfaces
                            • Completely Free to Play
                            """
                        )
                        
                        AboutSectionView(
                            title: "Benefits",
                            content: """
                            • Improve Memory Retention
                            • Enhance Logical Reasoning
                            • Boost Problem-Solving Skills
                            • Increase Processing Speed
                            • Develop Pattern Recognition
                            • Strengthen Cognitive Abilities
                            """
                        )
                        
                        AboutSectionView(
                            title: "All Games Included",
                            content: """
                            🧠 Memory Matrix - Test your memory with card matching
                            🔢 Sequence Master - Remember and repeat patterns
                            🎯 Logic Grid - Solve logical reasoning puzzles
                            🌀 Pattern Paradox - Find the different pattern
                            📊 Math Marathon - Solve arithmetic challenges
                            👁️ Visual Vortex - Advanced pattern recognition
                            📝 Word Wizard - Unscramble word puzzles
                            ⚡ Speed Sprint - Fast-paced reaction game
                            """
                        )
                    }
                    .padding()
                }
            }
        }
    }
}

struct AboutSectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(content)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

 
