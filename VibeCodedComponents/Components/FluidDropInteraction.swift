//
//  DragToFolderView.swift
//  VibeCodedComponents
    

import SwiftUI


struct FluidDropInteractionView: View {
    // State machine
    @State private var isDropped = false
    @State private var dragOffset: CGSize = .zero
    @State private var isHovering = false
    
    // The magic namespace that links the cards across different layouts
    @Namespace private var cardAnimation
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    
    
    let purpleGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "A32BFF"), Color(hex: "6A00D9")]),
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    let pinkGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "FF6B9E"), Color(hex: "E636C5")]),
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    
    var body: some View {
        VStack {
            ZStack {
                if !isDropped {
                    // "Drop to pin" Pill
                    HStack(spacing: 6) {
                        Image(systemName: "pin.fill").font(.system(size: 10))
                        Text("Drop to pin").font(.system(size: 14, weight: .semibold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(white: scheme == .light ? 1 : 0.09))
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                } else {
                    // New Toolbar sliding down from top
                    HStack {
                        Text("[untitled]")
                            .font(.system(size: 24, weight: .bold))
                            .onTapGesture(perform: dismiss.callAsFunction) // navigate back
                            
                        Spacer()
                        HStack(spacing: 16) {
                            Image(systemName: "bell.fill").foregroundStyle(.secondary)
                            
                            Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        isDropped = false
                                    }
                                }
                                
                            
                            Image(systemName: "lasso")
                                .foregroundStyle(.secondary)
                        }
                        .font(.system(size: 20))
                    }
                    .padding(.horizontal, 24)
                    // This moves it from above the screen down to its resting spot
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .frame(height: 60)
            .padding(.top, 10)
            
            Spacer()
            
            // MARK: - Dynamic Content Area
            if !isDropped {
                initialCardsLayout
            } else {
                folderLayout
            }
            
            Spacer()
        }
        // Smooth global animation for the layout switch
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isDropped)
        .navigationBarBackButtonHidden()
    }
    
    // MARK: - Layout 1: Uncombined Cards
    private var initialCardsLayout: some View {
        HStack(spacing: 20) {
            // Purple Target Card
            VStack(alignment: .leading, spacing: 12) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(purpleGradient)
                    // The MGE tag for the purple card
                    .matchedGeometryEffect(id: "purpleCard", in: cardAnimation)
                    .frame(width: 140, height: 140)
                    .scaleEffect(isHovering ? 0.92 : 1.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.black.opacity(isHovering ? 0.1 : 0.0), lineWidth: 4)
                    )
                
                // Labels that fade out upon drop
                VStack(alignment: .leading, spacing: 2) {
                    Text("Second").font(.system(size: 15, weight: .bold))
                    HStack(spacing: 4) {
                        Circle().fill(Color.gray.opacity(0.5)).frame(width: 10, height: 10)
                            .overlay(Image(systemName: "play.fill").font(.system(size: 5)))
                        Text("60fps").font(.system(size: 13, weight: .medium)).foregroundColor(.gray)
                    }
                }
                .padding(.leading, 4)
                .opacity(isDropped ? 0 : 1)
            }
            .zIndex(1)
            
            // Pink Draggable Card
            VStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(pinkGradient)
                    // The MGE tag for the pink card
                    .matchedGeometryEffect(id: "pinkCard", in: cardAnimation)
                    .frame(width: 140, height: 140)
                    .offset(dragOffset)
                    .scaleEffect(dragOffset != .zero && !isDropped ? 1.05 : 1.0)
                    .rotationEffect(.degrees(dragOffset != .zero && !isDropped ? (dragOffset.width / 30) : 0))
                    .shadow(color: .black.opacity(dragOffset != .zero ? 0.15 : 0.0), radius: 20, x: 0, y: 15)
                    .zIndex(2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.9)) {
                                    dragOffset = value.translation
                                    let wasHovering = isHovering
                                    // Trigger drop zone if dragged leftwards over the purple card
                                    isHovering = value.translation.width < -70 && abs(value.translation.height) < 100
                                    
                                    if isHovering && !wasHovering {
                                        hapticFeedback(style: .medium)
                                    }
                                }
                            }
                            .onEnded { value in
                                if isHovering {
                                    Sound.play(.drop)
                                    // Seamlessly drop: Zero the offset AND change state in the same animation
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        dragOffset = .zero
                                        isHovering = false
                                        isDropped = true // Triggers the MGE transition
                                    }
                                    hapticFeedback(style: .rigid)
                                } else {
                                    // Snap back
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )
                
                Text("Placeholder").opacity(0).padding(.bottom, 20)
            }
        }
        .padding(.bottom, 60)
    }
    
    // MARK: - Layout 2: Combined Folder
    private var folderLayout: some View {
        VStack(spacing: 20) {
            ZStack {
                // The gray background scales up from behind them as they move
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(white: 0.96))
                    .frame(width: 170, height: 170)
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
                
                HStack(spacing: 12) {
                    // Purple card morphed to small size
                    RoundedRectangle(cornerRadius: 12)
                        .fill(purpleGradient)
                        .matchedGeometryEffect(id: "purpleCard", in: cardAnimation)
                        .frame(width: 50, height: 50)
                    
                    // Pink card morphed to small size
                    RoundedRectangle(cornerRadius: 12)
                        .fill(pinkGradient)
                        .matchedGeometryEffect(id: "pinkCard", in: cardAnimation)
                        .frame(width: 50, height: 50)
                }
            }
            
            // Text fades in and floats up slightly
            VStack(spacing: 4) {
                Text("untitled folder").font(.system(size: 16, weight: .semibold))
                HStack(spacing: 4) {
                    Text("2 items").font(.system(size: 14)).foregroundColor(.gray)
                    Text("...").font(.system(size: 14, weight: .bold)).foregroundColor(.gray).padding(.leading, 8)
                }
            }
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
        .padding(.bottom, 100)
    }
}

#Preview {
    FluidDropInteractionView()
}

// Helper extension to make exact color matching easier
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}
