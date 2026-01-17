import SwiftUI

// MARK: - Game Models and Enums
struct MemoryCard: Identifiable {
    let id = UUID()
    let content: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}

enum GameState {
    case playing, won, lost
}

enum GameType: String, CaseIterable {
    case memory = "Memory Matrix"
    case sequence = "Sequence Master"
    case logic = "Logic Grid"
    case pattern = "Pattern Paradox"
    case math = "Math Marathon"
    case visual = "Visual Vortex"
    case word = "Word Wizard"
    case speed = "Speed Sprint"
}

struct LogicPuzzle {
    let question: String
    let options: [String]
    let correctAnswer: String
    let explanation: String
}

struct WordPuzzle {
    let scrambled: String
    let correct: String
    let hint: String
}

struct SpeedItem: Identifiable {
    let id = UUID()
    let symbol: String
    let isTarget: Bool
}





// MARK: - Main App Structure
struct ContentView: View {
    @StateObject private var gameManager = BrainGameManager()
    
    var body: some View {
        NavigationView {
            HomeView(gameManager: gameManager)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


import SwiftUI
// Pattern Game View
struct PatternGameView: View {
    @ObservedObject var gameManager: BrainGameManager
    @StateObject private var game: PatternGame
    @Environment(\.presentationMode) var presentationMode
    
    init(gameManager: BrainGameManager) {
        self.gameManager = gameManager
        _game = StateObject(wrappedValue: PatternGame(level: gameManager.unlockedLevels[.pattern] ?? 1))
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
                gameType: .pattern,
                gameState: game.gameState,
                score: game.score,
                level: game.level,
                timeRemaining: game.timeRemaining,
                onBack: { presentationMode.wrappedValue.dismiss() },
                onRestart: { game.startNewGame() }
            ) {
                VStack(spacing: 30) {
                    HStack {
                        Text("Lives: \(game.lives)")
                            .foregroundColor(.white)
                        Spacer()
                        Text("Find the different pattern!")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                        ForEach(0..<4, id: \.self) { index in
                            PatternGridView(
                                pattern: game.patterns[index],
                                onTap: { game.checkAnswer(index) }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
}


// MARK: - Reusable Components

struct GameContainerView<Content: View>: View {
    let gameManager: BrainGameManager
    let gameType: GameType
    let gameState: GameState
    let score: Int
    let level: Int
    let timeRemaining: Int
    let onBack: () -> Void
    let onRestart: () -> Void
    let content: Content
    
    init(
        gameManager: BrainGameManager,
        gameType: GameType,
        gameState: GameState,
        score: Int,
        level: Int,
        timeRemaining: Int,
        onBack: @escaping () -> Void,
        onRestart: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.gameManager = gameManager
        self.gameType = gameType
        self.gameState = gameState
        self.score = score
        self.level = level
        self.timeRemaining = timeRemaining
        self.onBack = onBack
        self.onRestart = onRestart
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            VStack {
                GameHeaderView(
                    gameType: gameType,
                    level: level,
                    score: score,
                    timeRemaining: timeRemaining,
                    onBack: onBack
                )
                
                content
                
                Spacer()
            }
            
            if gameState != .playing {
                GameOverlayView(
                    gameState: gameState,
                    score: score,
                    onRestart: onRestart,
                    onBack: onBack
                )
            }
        }
        .navigationBarHidden(true)
        .onChange(of: gameState) { state in
            if state == .won {
                gameManager.completeLevel(gameType, level: level, score: score)
            }
        }
    }
}

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("ChickenForges")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(radius: 10)
            
            Text("Challenge Your Mind • Boost Your IQ")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

struct GameIconView: View {
    let gameType: GameType
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 50, height: 50)
            
            Text(icon)
                .font(.title2)
        }
    }
    
    private var icon: String {
        switch gameType {
        case .memory: return "🧠"
        case .sequence: return "🔢"
        case .logic: return "🎯"
        case .pattern: return "🌀"
        case .math: return "📊"
        case .visual: return "👁️"
        case .word: return "📝"
        case .speed: return "⚡"
        }
    }
}

struct GameHeaderView: View {
    let gameType: GameType
    let level: Int
    let score: Int
    let timeRemaining: Int
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(.white)
                .padding(8)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
            }
            
            Spacer()
            
            VStack {
                Text(gameType.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Level \(level)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Score: \(score)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Time: \(timeRemaining)s")
                    .font(.caption)
                    .foregroundColor(timeRemaining < 10 ? .red : .white.opacity(0.8))
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
    }
}

struct GameOverlayView: View {
    let gameState: GameState
    let score: Int
    let onRestart: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        Color.black.opacity(0.8)
            .ignoresSafeArea()
        
        VStack(spacing: 25) {
            Text(gameState == .won ? "🎉 Level Complete! 🎉" : "Game Over")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Final Score: \(score)")
                .font(.title2)
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                Button("Play Again") {
                    onRestart()
                }
                .buttonStyle(PrimaryButtonStyle(color: .green))
                
                Button("Back to Games") {
                    onBack()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(30)
        .background(Color.purple.opacity(0.9))
        .cornerRadius(25)
        .padding(40)
    }
}



struct HintButtonView: View {
    let hintsRemaining: Int
    let onHint: () -> Void
    
    var body: some View {
        Button("💡 Hint (\(hintsRemaining))") {
            onHint()
        }
        .disabled(hintsRemaining == 0)
        .padding()
        .background(hintsRemaining > 0 ? Color.orange : Color.gray)
        .foregroundColor(.white)
        .cornerRadius(10)
        .padding()
    }
}

struct LogicOptionButton: View {
    let option: String
    let isSelected: Bool
    let isCorrect: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(option)
                .font(.body)
                .foregroundColor(textColor)
                .padding()
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(borderColor, lineWidth: 2)
                )
        }
        .disabled(isCorrect)
    }
    
    private var backgroundColor: Color {
        if isCorrect { return .green }
        return isSelected ? Color.blue : Color.white.opacity(0.2)
    }
    
    private var textColor: Color {
        if isCorrect { return .white }
        return isSelected ? .white : .white
    }
    
    private var borderColor: Color {
        if isCorrect { return .green }
        return isSelected ? .blue : .white
    }
}

struct PatternGridView: View {
    let pattern: [String]
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { col in
                            Text(pattern[row * 3 + col])
                                .font(.system(size: 18))
                        }
                    }
                }
            }
            .padding()
            .frame(height: 120)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: 2)
            )
        }
    }
}

struct VisualPatternView: View {
    let pattern: [String]
    let rotation: Double
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { col in
                            Text(pattern[row * 3 + col])
                                .font(.system(size: 18))
                        }
                    }
                }
            }
            .padding()
            .frame(height: 120)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: 2)
            )
            .rotationEffect(.degrees(rotation))
        }
    }
}

struct SpeedItemView: View {
    let item: SpeedItem
    let onTap: () -> Void
    
    @State private var position: CGPoint = .zero
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Button(action: onTap) {
            Text(item.symbol)
                .font(.system(size: 30))
                .padding(10)
                .background(item.isTarget ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                .cornerRadius(15)
                .shadow(radius: 5)
        }
        .position(position)
        .opacity(opacity)
        .onAppear {
            // Random position
            position = CGPoint(
                x: CGFloat.random(in: 50...300),
                y: CGFloat.random(in: 150...600)
            )
            
            // Fade out after 3 seconds
            withAnimation(.easeIn(duration: 3.0)) {
                opacity = 0.0
            }
            
            // Remove after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // Item will be removed by parent
            }
        }
    }
}

// MARK: - Button Styles
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

 
