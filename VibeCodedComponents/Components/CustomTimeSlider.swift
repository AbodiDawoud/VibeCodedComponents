//
//  CustomTimeSlider.swift
//  VibeCodedComponents
    

import SwiftUI

struct CustomTimeSlider: View {
    @State private var progress: CGFloat = 0.0
    let maxMinutes: CGFloat = 720
    
    var timeString: String {
        let totalMins = Int(progress * maxMinutes)
        let h = totalMins / 60
        let m = totalMins % 60
        
        if h == 0 { return "\(m)m" }
        if m == 0 { return "\(h)h" }
        return "\(h)h \(m)m"
    }
    
    var body: some View {
        ZStack {
            Color.primary.opacity(0.05).edgesIgnoringSafeArea(.all)
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                
                HStack(spacing: 12) {
                    // 1. Updated Leading Label
                    Text("4:35 PM")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        )
                    
                    GeometryReader { geo in
                        let trackWidth = geo.size.width
                        let thumbX = progress * trackWidth
                        
                        ZStack(alignment: .leading) {
                            
                            // 2. Updated Tick Marks (Highlighted when passed)
                            HStack(spacing: 0) {
                                let tickCount = 31
                                ForEach(0..<tickCount, id: \.self) { i in
                                    // Calculate how far along this specific tick is (0.0 to 1.0)
                                    let tickProgress = CGFloat(i) / CGFloat(tickCount - 1)
                                    
                                    Rectangle()
                                        // Apply semi-white if the thumb has passed this tick
                                        .fill(tickProgress <= progress ? Color.white.opacity(0.7) : Color.white.opacity(0.2))
                                        .frame(width: 1.5, height: 16)
                                        // Add a subtle animation when the color changes
                                        .animation(.easeInOut(duration: 0.15), value: progress)
                                    
                                    if i < tickCount - 1 {
                                        Spacer(minLength: 0)
                                    }
                                }
                            }
                            .frame(height: geo.size.height)
                            
                            Color.white.opacity(0.001)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            let x = min(max(value.location.x, 0), trackWidth)
                                            progress = x / trackWidth
                                        }
                                )
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color(red: 1.0, green: 0.35, blue: 0.25))
                                    .frame(width: 2, height: 28)
                                    .position(x: thumbX, y: geo.size.height / 2)
                                
                                Text(timeString)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(Color(red: 1.0, green: 0.35, blue: 0.25))
                                    )
                                    .position(x: thumbX, y: geo.size.height / 2 - 30)
                            }
                            .allowsHitTesting(false)
                        }
                    }
                    
                    // 3. Updated Trailing Label
                    Text("3:00 PM")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        )
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 72)
            .padding(.horizontal, 24)
            .sensoryFeedback(.increase, trigger: progress)
        }
    }
}

#Preview {
    CustomTimeSlider()
}
