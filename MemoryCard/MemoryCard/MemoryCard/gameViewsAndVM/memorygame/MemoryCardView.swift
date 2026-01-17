//
//  MemoryCardView.swift
//  MemoryCard
//
//  Created by Ahsen Khan on 04/11/2025.
//

import SwiftUI
struct MemoryCardView: View {
    let card: MemoryCard
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(card.isFaceUp || card.isMatched ? Color.white : Color.clear)
                .aspectRatio(2/3, contentMode: .fit)
                .shadow(radius: 5)
            
            if card.isFaceUp || card.isMatched {
                // Показываем контент карточки
                ZStack {
                    if card.content == "ChickenEmoji" {
                        // Если это ChickenEmoji, показываем изображение
                        Image("ChickenEmoji")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 60, maxHeight: 60)
                    } else {
                        // Иначе показываем текст/эмодзи
                        Text(card.content)
                            .font(.system(size: 30))
                            .scaleEffect(1.2)
                    }
                }
            } else {
                // Задняя часть карточки - ChickenCardBack
                Image("ChickenCardBack")
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(2/3, contentMode: .fit)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
            }
        }
        .rotation3DEffect(
            .degrees(card.isFaceUp || card.isMatched ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: card.isFaceUp || card.isMatched)
    }
}
