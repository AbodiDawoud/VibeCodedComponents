//
//  PreparationWidgetView.swift
//  VibeCodedComponents
    

import SwiftUI

struct PreparationWidgetView: View {
    // Controls the position of the slider (0.0 to 1.0)
    // ~0.85 by default
    @State private var progress: CGFloat = 0.85
    @State private var isDragging: Bool = false
    @Environment(\.dismiss) private var dismiss

    let widgetBackground = Color(red: 0.11, green: 0.11, blue: 0.12)
    let accentBlue = Color(red: 0.12, green: 0.53, blue: 0.98)
    let textGray = Color(red: 0.55, green: 0.55, blue: 0.58)
    let trackBgDark = Color(red: 0.11, green: 0.21, blue: 0.38)
    let trackStroke = Color(red: 0.18, green: 0.35, blue: 0.58)
    let checkCircleBg = Color(red: 0.12, green: 0.23, blue: 0.38)

    
    var body: some View {
        ZStack {
            Color.primary.opacity(0.01).edgesIgnoringSafeArea(.all)
            
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    Text("25:04")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Checkmark Button
                    Button {
                        Sound.play(.buttonTap)
                        dismiss()
                    } label: {
                        Circle()
                            .fill(checkCircleBg)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(accentBlue)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                
                Text("Left for preparation")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(textGray)
                    .padding(.horizontal, 24)
                    .padding(.top, 2)
                
                Spacer()
                
                
                InteractiveProgressBar(
                    progress: $progress,
                    isDragging: $isDragging,
                    accentBlue: accentBlue,
                    trackBgDark: trackBgDark,
                    trackStroke: trackStroke
                )
                .zIndex(3)
                .frame(height: 90)
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .frame(width: 320, height: 280)
            .background(widgetBackground, in: .rect(cornerRadius: 36))
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            .sensoryFeedback(.selection, trigger: progress)
        }
        .navigationBarBackButtonHidden()
    }
}


fileprivate struct InteractiveProgressBar: View {
    @Binding var progress: CGFloat
    @Binding var isDragging: Bool
    
    let accentBlue: Color
    let trackBgDark: Color
    let trackStroke: Color
    
    let segments = 4
    
    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let thumbX = progress * totalWidth
            let currentSegment = min(Int(progress * CGFloat(segments)), segments - 1)
            let segmentWidth = totalWidth / CGFloat(segments)
            
            ZStack(alignment: .bottomLeading) {
                
                // 1. Base Track Container
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(trackBgDark)
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(trackStroke, lineWidth: 1.5)
                    )
                
                // 2. Track Dividers & Active Segment Highlight
                HStack(spacing: 0) {
                    ForEach(0..<segments, id: \.self) { index in
                        ZStack {
                            // Active Segment (Striped Blue)
                            if index == currentSegment {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(accentBlue)
                                    .overlay(
                                        DiagonalStripes()
                                            .stroke(Color.white.opacity(0.15), lineWidth: 3)
                                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    )
                                    .padding(2) // Inner padding to stay inside the stroke
                                    .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.7), value: currentSegment)
                            }
                            
                            // Dividers
                            if index < segments - 1 {
                                HStack {
                                    Spacer()
                                    Rectangle()
                                        .fill(trackStroke.opacity(0.5))
                                        .frame(width: 1.5, height: 44)
                                }
                            }
                        }
                        .frame(width: segmentWidth, height: 44)
                    }
                }
                
                // 3. Tooltip and Draggable Line Indicator
                ZStack(alignment: .bottom) {
                    // Vertical White Line Indicator
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 1.5, height: 50) // Extends slightly below
                        .offset(y: 4) // Push it down past the bottom edge
                    
                    // Tooltip Popup
                    VStack(spacing: 0) {
                        HStack(spacing: 4) {
                            Image(systemName: segmentIcon(currentSegment))
                                .font(.system(size: 12))
                            Text(segmentState(currentSegment))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(accentBlue, in: .capsule)
                        
                        // Tooltip Tail (Triangle)
                        Triangle()
                            .fill(accentBlue)
                            .frame(width: 10, height: 6)
                    }
                    .offset(y: -54) // Position above the track
                    
                    // Subtle hover animation when dragging
                    .scaleEffect(isDragging ? 1.05 : 1.0)
                    .shadow(color: accentBlue.opacity(isDragging ? 0.4 : 0.2), radius: 8, x: 0, y: 4)
                }
                .position(x: thumbX, y: geometry.size.height - 22) // 22 is half of the track height
            }
            // Drag Gesture to make it interactive and joyful
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.8)) {
                            isDragging = true
                            // Clamp progress between 0 and 1
                            let newProgress = value.location.x / totalWidth
                            progress = max(0, min(1, newProgress))
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            isDragging = false
                            // Optional: Add snap-to-segment logic here if desired
                        }
                    }
            )
        }
    }
    
    func segmentIcon(_ segment: Int) -> String {
        switch segment {
        case 3: "0.circle.fill"
        case 2: "1.circle.fill"
        case 1: "2.circle.fill"
        case 0: "3.circle.fill"
        default: "3.circle.fill"
        }
    }
    
    func segmentState(_ segment: Int) -> String {
        switch segment {
        case 3: "Preparation"
        case 2: "Cooking"
        case 1: "Finishing Touches"
        case 0: "Done!"
        default: "Done!"
        }
    }
}

// MARK: - Custom Shapes

// Draws the subtle diagonal stripes for the active segment
fileprivate struct DiagonalStripes: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stripeWidth: CGFloat = 8
        let maxDimension = max(rect.width, rect.height) * 2
        
        // Draw diagonal lines from bottom-left to top-right
        for i in stride(from: -maxDimension, to: maxDimension, by: stripeWidth) {
            path.move(to: CGPoint(x: i, y: rect.height))
            path.addLine(to: CGPoint(x: i + rect.height, y: 0))
        }
        return path
    }
}


// Draws the little pointer tail for the tooltip
fileprivate struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width / 2, y: rect.height))
        path.closeSubpath()
        return path
    }
}


#Preview {
    PreparationWidgetView()
}
