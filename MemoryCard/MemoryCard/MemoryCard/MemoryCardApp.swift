//
//  MemoryCardApp.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
 

import SwiftUI

@main
struct MemoryCardApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MemoryAppContentView()
        }
    }
}

// MARK: - Memory App Content View
struct MemoryAppContentView: View {
    @ObservedObject private var memoryFlowController = MemoryFlowController.shared
    
    var body: some View {
        ZStack {
            // Основной контент всегда рендерится под загрузкой
            // Это предотвращает "пустой экран" при переключении
            memoryContentView
                .opacity(memoryFlowController.memoryIsLoading ? 0 : 1)
            
            // Экран загрузки поверх контента
            if memoryFlowController.memoryIsLoading {
                MemoryLoadingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: memoryFlowController.memoryIsLoading)
    }
    
    @ViewBuilder
    private var memoryContentView: some View {
        switch memoryFlowController.memoryDisplayMode {
        case .preparing:
            // Показываем ContentView как дефолт
            ContentView()
        case .original:
            // Показываем оригинальное приложение
            ContentView()
        case .webContent:
            // Показываем WebView
            MemoryDisplayView()
        }
    }
}


//Unleash Your Mental Potential with MindForges!
//
//Welcome to MindForges - where challenging puzzles meet brain science to transform your cognitive abilities. Forge a sharper, faster, and more agile mind through our carefully crafted brain training games designed by neuroscientists and puzzle experts.
//
//What is MindForges?
//MindForges is an advanced brain training app that turns mental exercise into an engaging adventure. Whether you're looking to boost memory, enhance problem-solving skills, or simply enjoy stimulating puzzles, MindForges provides the perfect platform to challenge and expand your mental capabilities.
//
//Key Features
//8 Unique Brain Game Categories
//
//Memory Matrix - Master card matching with increasing complexity
//
//Sequence Master - Train working memory with pattern sequences
//
//Logic Grid - Solve challenging reasoning puzzles
//
//Pattern Paradox - Develop advanced pattern recognition
//
//Math Marathon - Sharpen arithmetic and calculation skills
//
//Visual Vortex - Enhance visual-spatial intelligence
//
//Word Wizard - Boost vocabulary and verbal fluency
//
//Speed Sprint - Improve processing speed and reaction time
//
//Progressive Challenge System
//
//100+ carefully designed levels per game
//
//Adaptive difficulty that grows with your skills
//
//Unlock advanced modes as you improve
//
//Daily challenges to keep you engaged
//
//Advanced Progress Tracking
//
//Detailed performance analytics
//
//Cognitive strength assessment
//
//Progress reports and insights
//
//Achievement system with rewards
//
//Immersive Experience
//
//Beautiful, distraction-free interface
//
//Soothing brain-friendly color schemes
//
//Smooth animations and responsive design
//
//Customizable training sessions
//
//Benefits You'll Experience
//Enhanced Cognitive Functions
//
//Improve memory retention and recall
//
//Strengthen logical reasoning abilities
//
//Boost problem-solving skills
//
//Increase mental processing speed
//
//Develop better focus and concentration
//
