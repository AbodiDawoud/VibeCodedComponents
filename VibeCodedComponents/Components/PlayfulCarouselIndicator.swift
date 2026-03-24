//
//  PlayfulCarouselIndicator.swift
//  VibeCodedComponents
    

import SwiftUI

struct PlayfulCarouselIndicator: View {
    @State private var selectedItem = "Dean"
    @Environment(\.colorScheme) private var scheme
    
    let items = ["Dean", "Lazer", "Simz", "Bladee", "Lil B"]
    private var currentIndex: Int {
        items.firstIndex(of: selectedItem) ?? 0
    }
    
    var body: some View {
        ZStack {
            Color.primary.opacity(0.01).ignoresSafeArea()

            // 2. The Indicator Row
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    let isSelected = selectedItem == item
                    
                    Button {
                        setSelection(item)
                    } label: {
                        Text(item)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                            .fixedSize()
                            .scaleEffect(isSelected ? 1.0 : 0.001)
                            .opacity(isSelected ? 1 : 0)
                            .padding(.horizontal, isSelected ? 14 : 0)
                            .frame(width: isSelected ? nil : 10, height: isSelected ? 30 : 10)
                            .background(
                                Capsule()
                                    .fill(Color(white: scheme == .light ? 0.92 : 0.09))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        // A threshold of 30 ensures accidental tiny movements aren't registered
                        let swipeThreshold: CGFloat = 30
                        
                        if value.translation.width < -swipeThreshold {
                            // Swiped Left -> Move to Next
                            if currentIndex < items.count - 1 {
                                setSelection(items[currentIndex + 1])
                            }
                        } else if value.translation.width > swipeThreshold {
                            // Swiped Right -> Move to Previous
                            if currentIndex > 0 {
                                setSelection(items[currentIndex - 1])
                            }
                        }
                    }
            )
        }
    }
    
    func setSelection(_ item: String) {
        Sound.play(.tick)
        
        withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) {
            selectedItem = item
        }
    }
}

#Preview {
    PlayfulCarouselIndicator()
}
