//
//  HorizontalPillPicker.swift
//  VibeCodedComponents
    

import SwiftUI

struct HorizontalPillPicker: View {
    @State private var selectedValue: Int? = 16
    
    var body: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(Color.orange)
                .frame(width: 3, height: 14)
                .cornerRadius(1.5)
                .zIndex(1)
            
            // The Main Picker Card
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(0...50, id: \.self) { value in
                        Text("\(value)")
                            .font(.system(size: 42, weight: .bold, design: .default))
                            // Fixed width ensures perfect snapping alignment
                            .foregroundColor(.white)
                            .frame(width: 65, height: 75)
                            .visualEffect { content, proxy in
                                // 1. Calculate geometry
                                let scrollViewWidth: CGFloat = 195.0
                                let scrollViewCenter = scrollViewWidth / 2.0
                                let itemMidX = proxy.frame(in: .scrollView).midX
                                
                                // 2. Calculate distance from the exact center
                                let distance = abs(scrollViewCenter - itemMidX)
                                let normalized = min(distance / 65.0, 1.0)
                                
                                return content
                                    // Center is full size, adjacent drops down significantly
                                    .scaleEffect(1.0 - (normalized * 0.45))
                                    .blur(radius: normalized * 0.75)
                            }
                            
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $selectedValue, anchor: .center)
            .scrollTargetBehavior(.viewAligned)
            // Constrain the visible area to mimic the pill shape in the image
            .frame(width: 195, height: 75)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(white: 0.12))
                    // Subtle drop shadow for depth
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            // Clips the numbers so they disappear perfectly at the edges of the pill
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .sensoryFeedback(.selection, trigger: selectedValue)
    }
}

#Preview {
    HorizontalPillPicker()
}
