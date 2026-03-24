//
//  CoffeeMilkSlider.swift
//  VibeCodedComponents

import SwiftUI

struct CoffeeMilkSlider: View {
    @State private var percentage: CGFloat = 0.37
    @State private var dragY: CGFloat = 0
    
    let coffeeBg = Color(red: 0.25, green: 0.12, blue: 0.05)
    let coffeeText = Color(red: 0.9, green: 0.4, blue: 0.1)
    let milkBg = Color(white: 0.25)
    let milkText = Color(white: 0.8)
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            GeometryReader { geo in
                let totalWidth = geo.size.width
                let gap: CGFloat = 8
                let handleWidth: CGFloat = 4
                
                let availableWidth = totalWidth - (gap * 2) - handleWidth
                let coffeeWidth = max(0, availableWidth * percentage)
                let milkWidth = max(0, availableWidth * (1 - percentage))
                
                // 1. The Squish Math
                let squishProgress = min(abs(dragY) / 100, 1.0)
                let trackHeight = 60 - (44 * squishProgress)
                let handleHeight = trackHeight + 8
                
                // MARK: - 2. The Hard Constraints & Collision Math
                // The global upward pop from dragging down (Capped at -20, never goes positive)
                let dragPop = max(-20, min(0, -dragY * 0.4))
                
                // Collision Math: If the handle enters the 0-28% or 72-100% danger zones
                let coffeeCollision = max(0, 0.28 - percentage) / 0.18 // Scales 0 to 1
                let milkCollision = max(0, percentage - 0.72) / 0.18 // Scales 0 to 1
                
                let coffeeProximityPop = coffeeCollision * -24
                let milkProximityPop = milkCollision * -24
                
                // Combine them and enforce the ultimate ceiling of -24 points!
                let coffeeY = max(-24, min(0, dragPop + coffeeProximityPop))
                let milkY = max(-24, min(0, dragPop + milkProximityPop))
                
                ZStack {
                    // The Physical Separated Tracks
                    HStack(spacing: gap) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(coffeeBg)
                            .frame(width: coffeeWidth, height: trackHeight)
                        
                        Capsule()
                            .fill(Color.white)
                            .frame(width: handleWidth, height: handleHeight)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(milkBg)
                            .frame(width: milkWidth, height: trackHeight)
                    }
                    .frame(height: 70)
                    
                    // The Independent Floating Labels
                    HStack(spacing: 0) {
                        Text("COFFEE \(Int(percentage * 100))%")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(coffeeText)
                            .padding(.leading, 16)
                            .frame(width: coffeeWidth, alignment: .leading)
                            // Dodges the handle independently!
                            .offset(y: coffeeY)
                            .scaleEffect(1.0 - (abs(coffeeY) / 24) * 0.15)
                        
                        Spacer()
                        
                        Text("\(Int((1 - percentage) * 100))% MILK")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(milkText)
                            .padding(.trailing, 16)
                            .frame(width: milkWidth, alignment: .trailing)
                            // Dodges the handle independently!
                            .offset(y: milkY)
                            .scaleEffect(1.0 - (abs(milkY) / 24) * 0.15)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let newPercentage = value.location.x / totalWidth
                            percentage = min(max(newPercentage, 0.1), 0.9)
                            
                            // Only register vertical drag if pulling downward (positive Y)
                            dragY = max(0, value.translation.height)
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                                dragY = 0
                            }
                        }
                )
            }
            .frame(height: 140)
            .padding(.horizontal, 24)
        }
        .sensoryFeedback(.selection, trigger: Int(percentage * 100))
    }
}

#Preview {
    CoffeeMilkSlider()
}
