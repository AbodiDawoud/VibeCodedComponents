//
//  IntensitySliderView.swift
//  VibeCodedComponents
    

import SwiftUI


struct IntensitySliderView: View {
    @State private var progress: CGFloat = 0.4
    
    var body: some View {
        ZStack {
            Color.primary.opacity(0.05).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                // Header
                Text("Intensity")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.black.secondary) // Dark gray/black
                
                // Slider Track
                GeometryReader { geo in
                    let trackWidth = geo.size.width
                    
                    ZStack(alignment: .leading) {
                        // 1. Background Track (Light Gray)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(white: 0.959))
                        
                        // 2. Progress Fill (Light Blue)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(red: 0.58, green: 0.83, blue: 0.98))
                            .frame(width: trackWidth * progress)
                        
                        // 3. Indicator Line (Darker Blue)
                        // Positioned at the exact edge of the progress fill
                        Rectangle()
                            .fill(Color(red: 0.15, green: 0.55, blue: 0.95))
                            .frame(width: 2.5)
                            .padding(.vertical, 2) // Gives it slight padding top and bottom
                            .position(x: trackWidth * progress - 1.25, y: geo.size.height / 2)
                    }
                    // Invisible drag overlay
                    .overlay(
                        Color.white.opacity(0.001)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let x = min(max(value.location.x, 0), trackWidth)
                                        progress = x / trackWidth
                                    }
                            )
                    )
                }
                .frame(height: 18)
                
                // Bottom Row: Text and Ticks
                HStack(alignment: .center, spacing: 12) {
                    Text("Low")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(white: 0.55))
                    
                    // Ticks spanning the middle
                    HStack(spacing: 0) {
                        let tickCount = 28 // Approximate number of ticks in your image
                        ForEach(0..<tickCount, id: \.self) { i in
                            Rectangle()
                                .fill(Color(white: 0.85)) // Light gray ticks
                                .frame(width: 1.8, height: Double.random(in: 6...9))
                            
                            // Add a spacer between all ticks except after the last one
                            if i < tickCount - 1 {
                                Spacer(minLength: 0)
                            }
                        }
                    }
                    .padding(.top, 1) // Tiny optical adjustment
                    
                    Text("High")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(white: 0.55))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(Color.white)
            .cornerRadius(16)
            // Soft drop shadow to match the floating card look
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
            .padding(24) // Outer margin
        }
        .sensoryFeedback(.decrease, trigger: progress)
    }
}

#Preview {
    IntensitySliderView()
}
