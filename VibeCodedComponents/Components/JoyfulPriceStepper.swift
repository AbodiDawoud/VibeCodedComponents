//
//  JoyfulPriceStepper.swift
//  VibeCodedComponents
    

import SwiftUI


struct JoyfulPriceStepper: View {
    @State private var price: Int = 56
    let maxPrice: Int = 100
    
    // State to track interaction for the "squish" effect
    @State private var isInteracting: Bool = false
    
    var body: some View {
        ZStack {
            // The canvas background
            Color.primary.opacity(0.05).ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                Text("Select the price")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(white: 0.1))
                
                VStack(spacing: 12) {
                    
                    // MARK: - The Interactive Pill
                    GeometryReader { geo in
                        let trackWidth = geo.size.width
                        let fillPercentage = CGFloat(price) / CGFloat(maxPrice)
                        let fillWidth = trackWidth * fillPercentage
                        
                        ZStack(alignment: .leading) {
                            // 1. The Track Base
                            Color(white: 0.92)
                            
                            // 2. The Dynamic White Fill
                            Color.white.opacity(0.6)
                                .frame(width: max(0, fillWidth))
                                // The soft inner shadow giving it depth over the gray
                                .shadow(color: .black.opacity(0.08), radius: 8, x: 4, y: 0)
                        }
                        // This perfectly clips the fill and its shadow to the pill shape!
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        
                        // 3. The Interactive Overlay
                        .overlay {
                            HStack {
                                // Minus Button
                                Button {
                                    triggerTap(increment: -1)
                                } label: {
                                    Image(systemName: "minus")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(Color(white: 0.55))
                                        .frame(width: 50, height: 50)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                
                                Spacer()
                                
                                // The Rolling Value Text
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text("$")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(white: 0.6))
                                    Text("\(price).00")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(white: 0.1))
                                        // The slot-machine rolling animation
                                        .contentTransition(.numericText(value: Double(price)))
                                }
                                // Prevents the text from stealing the drag gesture
                                .allowsHitTesting(false)
                                
                                Spacer()
                                
                                // Plus Button
                                Button {
                                    triggerTap(increment: 1)
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(Color(white: 0.55))
                                        .frame(width: 50, height: 50)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 8)
                        }
                        // 4. The Fluid Drag Gesture
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    isInteracting = true
                                    
                                    // Calculate the math based on finger position
                                    let percentage = value.location.x / trackWidth
                                    let rawValue = Int(round(percentage * CGFloat(maxPrice)))
                                    let newValue = min(max(0, rawValue), maxPrice)
                                    
                                    // Smoothly snap the slider to the finger
                                    withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.8)) {
                                        price = newValue
                                    }
                                }
                                .onEnded { _ in
                                    // Bounce back to full size when let go
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        isInteracting = false
                                    }
                                }
                        )
                    }
                    .frame(height: 72)
                    // The playful "squish" when interacting
                    .scaleEffect(isInteracting ? 0.98 : 1.0)
                    
                    // MARK: - Min/Max Footer Labels
                    HStack {
                        Text("$0")
                        Spacer()
                        Text("$100")
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(white: 0.7))
                    .padding(.horizontal, 4)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.white)
                    // Soft, premium shadow for the main card
                    .shadow(color: .black.opacity(0.04), radius: 30, y: 15)
            )
            .padding(24)
        }
        // iOS 17 Magic: Fires a perfect haptic click every time the number changes!
        .sensoryFeedback(.selection, trigger: price)
    }
    
    // Helper function for the tap buttons
    private func triggerTap(increment: Int) {
        // Quick visual squish feedback on tap
        withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.6)) {
            isInteracting = true
        }
        
        // Change the value with a bouncy spring
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
            price = min(max(0, price + increment), maxPrice)
        }
        
        // Release the squish immediately after
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isInteracting = false
            }
        }
    }
}

#Preview {
    JoyfulPriceStepper()
}
