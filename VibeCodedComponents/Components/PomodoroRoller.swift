//
//  PomodoroRollerView.swift
//  VibeCodedComponents
    

import SwiftUI


struct PomodoroRollerView: View {
    @State private var selectedValue: Int? = 50
    
    // MARK: - Velocity Tracking State
    @State private var scrollOffset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    @State private var blurAmount: CGFloat = 0
    
    // A timer to sample the scroll position and calculate velocity
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Dark mode aesthetic
            Color.primary.opacity(0.01).ignoresSafeArea()
            
            VStack(spacing: 50) {
                
                // MARK: - 1. The Dynamic Rolling Text
                Text("\(selectedValue ?? 0)")
                    .font(.system(size: 110, weight: .semibold, design: .rounded))
                    .contentTransition(.numericText())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primary, Color(white: 0.5)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    // The slot-machine rolling animation
                    //.contentTransition(.numericText(value: Double(selectedValue ?? 0)))
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedValue)
                    // Apply motion blur based on scroll speed
                    .blur(radius: blurAmount)
                    // Stretch the text vertically when moving fast for an optical motion streak!
                    .scaleEffect(y: 1 + (blurAmount * 0.06))
                    // The Fading Edges Mask (Numbers disappear into the shadows)
                    .mask {
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .primary, location: 0.25),
                                .init(color: .primary, location: 0.75),
                                .init(color: .clear, location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .frame(height: 140)

                
                // MARK: - 2. The Interactive 3D Dial
                GeometryReader { geo in
                    let screenWidth = geo.size.width
                    
                    ZStack(alignment: .top) {
                        
                        // The scrolling ruler
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 8) {
                                ForEach(0...120, id: \.self) { i in
                                    TickMark(value: i, screenWidth: screenWidth)
                                        .id(i)
                                }
                            }
                            .scrollTargetLayout()
                            // This background trick constantly reports the scroll offset
                            .background(
                                GeometryReader { scrollGeo -> Color in
                                    let offset = scrollGeo.frame(in: .global).minX
                                    DispatchQueue.main.async {
                                        self.scrollOffset = offset
                                    }
                                    return Color.clear
                                }
                            )
                        }
                        // Snaps to individual ticks
                        .scrollTargetBehavior(.viewAligned)
                        // Binds the centered tick to our selectedValue state
                        .scrollPosition(id: $selectedValue)
                        // Paddings ensure you can scroll all the way to 0 and the max value
                        .safeAreaPadding(.horizontal, screenWidth / 2)
                        
                        // MARK: - 3. The Center Orange Indicator
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 2, height: 35)
                            .offset(y: -5) // Stick up slightly higher than the ticks
                            .shadow(color: .orange.opacity(0.6), radius: 6, y: 2)
                    }
                }
                .frame(height: 120)
            }
        }
        // MARK: - Velocity Math Engine
        .onReceive(timer) { _ in
            // Calculate how far the user scrolled in the last 0.05 seconds
            let velocity = abs(scrollOffset - lastOffset)
            
            // Convert velocity into a controlled blur radius (Max blur: 12)
            let targetBlur = min(max(velocity * 0.15, 0), 12)
            
            // Smoothly animate the blur changes
            withAnimation(.linear(duration: 0.1)) {
                blurAmount = targetBlur
            }
            
            lastOffset = scrollOffset
        }
        // Satisfying physical click for every tick
        .sensoryFeedback(.selection, trigger: selectedValue)
    }
}

// MARK: - The Individual Tick Component
struct TickMark: View {
    var value: Int
    var screenWidth: CGFloat
    
    var body: some View {
        GeometryReader { proxy in
            // Calculate where this specific tick is on the screen right now
            let midX = proxy.frame(in: .global).midX
            let screenCenter = screenWidth / 2
            let distance = midX - screenCenter
            
            // Normalize the distance from -1 to 1
            let normalizedDist = distance / screenCenter
            
            // 1. The Parabolic Drop (Pushes edge ticks downwards to create an arch)
            let yDrop = pow(normalizedDist, 2) * 60
            
            // 2. The 3D Tilt (Tilts edge ticks outward slightly)
            let angle = normalizedDist * 25
            
            // Sizing logic: 10s are tall, 5s are medium, the rest are short
            let isMajor = value % 10 == 0
            let isMedium = value % 5 == 0 && !isMajor
            let tickHeight: CGFloat = isMajor ? 24 : (isMedium ? 16 : 10)
            
            Rectangle()
                .fill(Color.primary.opacity(isMajor ? 1.0 : 0.4))
                .frame(width: 2, height: tickHeight)
                .offset(y: yDrop)
                .rotationEffect(.degrees(angle), anchor: .bottom)
        }
        // Fixed frame required for LazyHStack performance
        .frame(width: 2, height: 80)
    }
}

#Preview {
    PomodoroRollerView()
}
