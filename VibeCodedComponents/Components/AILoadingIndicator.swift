//
//  AILoadingIndicator.swift
//  VibeCodedComponents
    

import SwiftUI

struct AILoadingIndicator: View {
    let messages = [
        "Preparing your request",
        "Processing your request",
        "Finding your file...",
        "Just a moment",
    ]
    
    @State private var currentIndex = 0
    @State private var isRotating = false
    
    // The signature Apple Intelligence vibrant colors
    let aiColors: [Color] = [.cyan, .blue, .purple, .pink, .orange]
    
    var body: some View {
        HStack(spacing: 15) {
            
            // 1. The Rotating AI Icon
            Image(systemName: "apple.intelligence")
                .font(.system(size: 26.6, weight: .semibold))
                // Apply the vibrant gradient to the icon
                .foregroundStyle(
                    LinearGradient(
                        colors: aiColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                // Continuously rotate
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .onAppear {
                    // A linear animation ensures it spins at a constant speed without easing
                    withAnimation(.linear(duration: 15.0).repeatForever(autoreverses: false)) {
                        isRotating = true
                    }
                }
            
            // 2. The Shimmering, Morphing Text
            ZStack(alignment: .leading) {
                Text(messages[currentIndex])
                    .font(.system(size: 23, weight: .medium, design: .rounded).smallCaps())
                    .id(messages[currentIndex])
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        )
                    )
            }
            .frame(height: 30, alignment: .bottomLeading)
            .clipped()
            // Apply our custom colorful shimmer modifier
            .modifier(ColorfulGradientShimmer(colors: aiColors))
            
        }
        .padding()
        .task {
            await startTextSequence()
        }
    }
    
    // Cycle the text
    private func startTextSequence() async {
        let sleepDuration: UInt64 = 4_500_000_000
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: sleepDuration) // 3 seconds
            
            await MainActor.run {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                    currentIndex = (currentIndex + 1) % messages.count
                }
            }
        }
    }
}

// MARK: - Colorful Gradient Shimmer Modifier
struct ColorfulGradientShimmer: ViewModifier {
    let colors: [Color]
    private let delay: Double = 2.5
    private let animationDuration: Double = 1.0
    private let autoReverses: Bool = false
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            // The base, inactive state of the text (light gray)
            .foregroundStyle(Color.gray.opacity(0.4))
            .overlay {
                content
                    // The vibrant overlay state
                    .foregroundStyle(
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    // We mask the colorful text with a moving sweep of visibility
                    .mask {
                        LinearGradient(
                            // The clear/white/clear creates the "window" of visibility
                            colors: [.clear, .white, .clear],
                            // We animate the physical coordinates of the gradient
                            startPoint: isAnimating ? .init(x: 1.0, y: 0.5) : .init(x: -1.0, y: 0.5),
                            endPoint: isAnimating ? .init(x: 2.0, y: 0.5) : .init(x: 0.0, y: 0.5)
                        )
                    }
            }
            .onAppear {
                // Sweep the mask across continuously
                withAnimation(.linear(duration: animationDuration).delay(delay).repeatForever(autoreverses: autoReverses)) {
                    isAnimating = true
                }
            }
    }
}

#Preview {
    AILoadingIndicator()
}
