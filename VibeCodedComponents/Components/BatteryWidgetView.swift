//
//  BatteryWidgetView.swift
//  VibeCodedComponents
    

import SwiftUI

struct BatteryWidgetView: View {
    // 1. Toggle for the wave animation
    @State private var isWaveAnimated: Bool = false
    
    @State private var phase: Double = 0
    // 2. State to hold the real device battery
    @State private var batteryLevel: Float = 0.50
    
    let neonYellow = Color(red: 1.0, green: 0.85, blue: 0.0)
    let widgetBackground = Color(red: 0.12, green: 0.12, blue: 0.12)
    let darkGlass = Color(red: 0.18, green: 0.18, blue: 0.18)
    
    var body: some View {
        ZStack {
            // The Widget Base
            RoundedRectangle(cornerRadius: 32)
                .fill(widgetBackground)
            
            // The Giant Lightning Bolt
            ZStack {
                ThunderShape()
                    .fill(darkGlass)
                
                // The Glossy Glint / Glass Reflection
                ThunderShape()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: .white.opacity(0.2), location: 0.0),
                                .init(color: .white.opacity(0.05), location: 0.35),
                                .init(color: .clear, location: 0.351),
                                .init(color: .clear, location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // The Wavy Liquid Fill
                WaveShape(progress: CGFloat(batteryLevel), phase: phase, amplitude: 12)
                    .fill(neonYellow)
                    .shadow(color: neonYellow.opacity(0.6), radius: 15, y: -5)
                    .mask(ThunderShape())
            }
            // Size the bolt and push it to the bottom right
            .frame(width: 200, height: 260)
            .scaleEffect(1.25)
            .offset(x: 75, y: 20)
            
            // The Typography Overlay
            VStack(alignment: .leading, spacing: 0) {
                Text("\(Int(batteryLevel * 100))%")
                    .font(.system(size: 54, weight: .bold, design: .rounded))
                    .foregroundColor(neonYellow)
                
                Text("Charged")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(white: 0.7))
                
                Spacer()
                
                // Note: iOS doesn't provide public APIs for exact charging time remaining,
                // so this remains a static UI element to match your design.
                VStack(alignment: .leading) {
                    Text("2,5 hours").bold().foregroundColor(Color(white: 1))
                    Text("for full charge").foregroundColor(Color(white: 0.7))
                }
                .font(.system(size: 16))
                .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .frame(width: 260, height: 260)
        // 4. Clip everything (including the bolt) to the widget's borders
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        .onAppear(perform: setupBatteryTracking)
        // Listen for battery changes in real-time
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.batteryLevelDidChangeNotification)) { _ in
            updateBatteryLevel()
        }
        .sensoryFeedback(.impact(weight: .light), trigger: isWaveAnimated)
        .onTapGesture {
            if isWaveAnimated { return }
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
    
    // MARK: - Battery Logic
    private func setupBatteryTracking() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        updateBatteryLevel()
    }
    
    private func updateBatteryLevel() {
        let level = UIDevice.current.batteryLevel
        // The Simulator often returns -1.0 for battery level.
        // We use a fallback of 0.52 so it still looks good if you aren't on a real device.
        batteryLevel = level >= 0 ? level : 0.52
    }
}


struct ThunderShape: Shape {
    // Easily adjust this value to make the corner sharper or softer!
    var leftCornerRadius: CGFloat = 12
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // 1. Define all our key vector points for clarity
        let topTip = CGPoint(x: width * 0.7, y: 0)
        let farLeft = CGPoint(x: width * 0.1, y: height * 0.55) // The corner we want to round
        let innerLeft = CGPoint(x: width * 0.6, y: height * 0.55)
        let bottomTip = CGPoint(x: width * 0.4, y: height)
        let farRight = CGPoint(x: width * 0.9, y: height * 0.4)
        let innerRight = CGPoint(x: width * 0.45, y: height * 0.4)
        
        // 2. Start at the top right
        path.move(to: topTip)
        
        // 3. THE MAGIC ARC
        // Instead of a harsh line to 'farLeft', we curve it cleanly towards 'innerLeft'
        path.addArc(tangent1End: farLeft, tangent2End: innerLeft, radius: leftCornerRadius)
        
        // 4. Connect the rest of the standard sharp lines
        path.addLine(to: innerLeft)
        path.addLine(to: bottomTip)
        path.addLine(to: farRight)
        path.addLine(to: innerRight)
        path.closeSubpath()
        
        return path
    }
}

struct WaveShape: Shape {
    var progress: CGFloat
    var phase: Double
    var amplitude: CGFloat
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        let fillHeight = height * (1 - progress)
        
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: fillHeight))
        
        for x in stride(from: 0, through: width, by: 2) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * 2 + phase)
            let y = fillHeight + (sine * amplitude)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    BatteryWidgetView()
}
