import SwiftUI

// MARK: - Memory Loading View
struct MemoryLoadingView: View {
    @State private var memoryRotationAngle: Double = 0
    @State private var memoryScale: CGFloat = 1.0
    @State private var memoryOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // ChickenLoadBG image as background
            Image("ChickenLoadBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Необычный загрузочный элемент - вращающаяся карточка с эмодзи курицы
            VStack {
                Spacer()
                
                ZStack {
                    // Вращающаяся карточка
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.orange.opacity(0.8),
                                    Color.yellow.opacity(0.6),
                                    Color.orange.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 80)
                        .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 5)
                        .rotation3DEffect(
                            .degrees(memoryRotationAngle),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.5
                        )
                        .scaleEffect(memoryScale)
                        .opacity(memoryOpacity)
                    
                    // Эмодзи курицы на карточке
                    Image("ChickenEmoji")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .rotation3DEffect(
                            .degrees(-memoryRotationAngle),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.5
                        )
                    
                    // Пульсирующие точки вокруг карточки
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 4, height: 4)
                            .offset(
                                x: cos(Double(index) * .pi / 4) * 40,
                                y: sin(Double(index) * .pi / 4) * 40
                            )
                            .opacity(memoryOpacity)
                            .scaleEffect(memoryScale * 0.5 + 0.5)
                    }
                }
                
                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.3)
            }
        }
        .onAppear {
            // Анимация вращения карточки
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                memoryRotationAngle = 360
            }
            
            // Анимация пульсации
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                memoryScale = 1.1
                memoryOpacity = 0.7
            }
        }
    }
}
