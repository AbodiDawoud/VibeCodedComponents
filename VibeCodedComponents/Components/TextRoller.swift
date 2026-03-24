//
//  TextRoller.swift
//  VibeCodedComponents
    

import SwiftUI

struct TextRollerView: View {
    // Shared state between the text roller and the dial
    @State private var selectedValue: Int? = 0
    
    var body: some View {
        VStack(spacing: 40) {
            // 1. The Vertical Text Roller
            ScrollableTextView(selectedValue: $selectedValue)
            
            // 2. The Horizontal Arched Dial
            ArchedDial(selectedValue: selectedValue ?? 0)
        }
    }
}


fileprivate struct ScrollableTextView: View {
    @Binding var selectedValue: Int?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(0...100, id: \.self) { value in
                    Text("\(value)")
                        .font(.system(size: 75, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, Color(white: 0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 100)
                        // Using visualEffect to calculate exact distance from the center
                        .visualEffect { content, proxy in
                            // 1. Get the geometry of the scroll view and the item
                            let scrollViewHeight: CGFloat = 280.0
                            let scrollViewCenter = scrollViewHeight / 2.0
                            let itemMidY = proxy.frame(in: .scrollView).midY
                            
                            // 2. Calculate distance from center (0 is perfectly centered)
                            let distance = abs(scrollViewCenter - itemMidY)
                            
                            // 3. Normalize the distance (Caps at 1.0 when it is exactly 1 item away)
                            let normalized = min(distance / 100.0, 1.0)
                            
                            // 4. Direction for 3D rotation (tilts one way going up, the other way going down)
                            let direction: Double = itemMidY < scrollViewCenter ? 1.0 : -1.0
                            
                            return content
                                // Center is 1.2 scale, immediately drops to 0.7 for adjacent numbers
                                .scaleEffect(1.2 - (normalized * 0.5))
                                
                                // Center is 1.0 opacity, immediately drops to 0.15 for adjacent numbers
                                .opacity(1.0 - (normalized * 0.85))
                                
                                // Adds blur the further away it gets
                                .blur(radius: normalized * 7)
                                
                                // Sharp 3D rolling effect
                                .rotation3DEffect(
                                    .degrees(normalized * 45 * direction),
                                    axis: (x: 1, y: 0, z: 0)
                                )
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $selectedValue, anchor: .center)
        .scrollTargetBehavior(.viewAligned)
        .frame(height: 280)
        .safeAreaPadding(.vertical, 90)
        .mask {
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.0),
                    .init(color: .white, location: 0.3),
                    .init(color: .white, location: 0.7),
                    .init(color: .clear, location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .sensoryFeedback(.selection, trigger: selectedValue)
    }
}

fileprivate struct ArchedDial: View {
    var selectedValue: Int
    
    // Dial Customization
    let dialRadius: CGFloat = 220
    let degreesPerUnit: Double = 4.0 // Spacing between each tick mark
    
    var body: some View {
        // Outer container to clip and frame only the top of the circle
        ZStack(alignment: .top) {
            
            // The Full Circle Layer
            ZStack {
                // 1. The Rotating Tick Marks
                ZStack {
                    ForEach(0...100, id: \.self) { i in
                        let isMajor = i % 10 == 0
                        let isMedium = i % 5 == 0
                        
                        Rectangle()
                            .fill(Color.primary.opacity(isMajor ? 0.9 : 0.4))
                            .frame(width: isMajor ? 2 : 1.5, height: isMajor ? 16 : (isMedium ? 12 : 8))
                            // Push to the edge of the large circle
                            .offset(y: -dialRadius)
                            // Rotate each mark into position
                            .rotationEffect(.degrees(Double(i) * degreesPerUnit))
                    }
                }
                .rotationEffect(.degrees(-Double(selectedValue) * degreesPerUnit))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedValue)
                
                // 2. The Fixed Orange Center Indicator
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 2.5, height: 24)
                    .offset(y: -dialRadius)
                    .zIndex(1)
            }
            // FIX: Give the circular dial its true full size so the layout system doesn't clip it prematurely
            .frame(width: dialRadius * 2, height: dialRadius * 2)
        }
        // Frame the outer container to just the visible height we want (the top of the arch)
        .frame(height: 100, alignment: .top)
        .clipped() // Cuts off the rest of the invisible bottom of the circle
        // Fade the left and right edges smoothly
        .mask {
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.0),
                    .init(color: .white, location: 0.3),
                    .init(color: .white, location: 0.7),
                    .init(color: .clear, location: 1.0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

#Preview {
    TextRollerView()
}
