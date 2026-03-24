//
//  UiverseLoader.swift
//  VibeCodedComponents
    

import SwiftUI

struct OrbLoaderView: View {
    // Separate states for continuous rotation and reversing colors/offsets
    @State private var rotation: Double = 90
    @State private var colorPhase = false
    
    let text = "Generating"
    
    // Original CSS Colors
    let color1_2 = Color(hex: "ad5fff")
    let color1_3 = Color(hex: "471eec")
    
    let color2_2 = Color(hex: "d60a47")
    let color2_3 = Color(hex: "311e80")

    var body: some View {
        ZStack {
            // Background / Shadow Ring
            Circle()
                .fill(.clear)
                .frame(width: 180, height: 180)
                // Deepest inset shadow
                .innerShadow(
                    color: colorPhase ? color2_3 : color1_3,
                    radius: 60,
                    offsetX: 0,
                    offsetY: colorPhase ? 40 : 60 // CSS Y-offset changes at 50%
                )
                // Middle inset shadow
                .innerShadow(
                    color: colorPhase ? color2_2 : color1_2,
                    radius: colorPhase ? 10 : 30, // CSS Blur changes at 50%
                    offsetX: 0,
                    offsetY: 20
                )
                // Bright white edge inset shadow
                .innerShadow(
                    color: .white,
                    radius: 20,
                    offsetX: 0,
                    offsetY: 10
                )
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    // 1. Rotation: continuous, 2 seconds, no reverse
                    withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                        rotation = 450
                    }
                    
                    // 2. Colors & Offsets: 1 second to reach 50%, then reverses (2s total loop)
                    withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: true)) {
                        colorPhase = true
                    }
                }

            // Text Loading Animation
            HStack(spacing: 0) {
                ForEach(Array(text.enumerated()), id: \.offset) { index, letter in
                    Text(String(letter))
                        .font(.system(size: 20, weight: .light, design: .default))
                        .foregroundColor(.white)
                        .modifier(LetterAnimationModifier(delay: Double(index) * 0.1))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black) // Just so you can see the white text easily
    }
}



struct SearchingOrbLoader: View {
    // Orb animations (1.5s cycle)
    @State private var orbRotation: Double = 90
    @State private var orbColorPhase = false
    
    let text = "Searching"
    
    // Extracted Colors
    let middlePink = Color(hex: "ff5f9f")
    let middleRed = Color(hex: "d60a47")
    
    let outerBlue = Color(hex: "0693ff")
    let outerYellow = Color(hex: "fbef19")
    
    let bgRed = Color(hex: "7c0911")

    var body: some View {
        HStack(spacing: 10) {
            
            // 1. The Tiny Orb
            Circle()
                .fill(orbColorPhase ? bgRed : .clear)
                .frame(width: 20, height: 20)
                // Outer inset shadow (Blue <-> Yellow)
                .innerShadow(
                    color: orbColorPhase ? outerYellow : outerBlue,
                    radius: 4,
                    offsetX: 0,
                    offsetY: 4
                )
                // Middle inset shadow (Pink <-> Deep Red)
                .innerShadow(
                    color: orbColorPhase ? middleRed : middlePink,
                    radius: 3, // Slightly smaller blur for this layer
                    offsetX: 0,
                    offsetY: 3
                )
                // Inner white edge
                .innerShadow(
                    color: .white,
                    radius: 1,
                    offsetX: 0,
                    offsetY: 1
                )
                .rotationEffect(.degrees(orbRotation))
                .onAppear {
                    // Continuous rotation (1.5s total loop)
                    withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                        orbRotation = 450
                    }
                    
                    // Color pulsing (0.75s to reach 50%, then reverses back)
                    withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: true)) {
                        orbColorPhase = true
                    }
                }

            // 2. The Text Wrapper
            HStack(spacing: 1) { // .letter-wrapper gap
                ForEach(Array(text.enumerated()), id: \.offset) { index, letter in
                    Text(String(letter))
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(.white)
                        .modifier(LetterAnimationModifier(delay: Double(index) * 0.1))
                }
            }
        }
        .padding()
        .background(Color(white: 0.09), in: .capsule) // For visibility in preview
    }
}


// Custom Modifier for the staggered letter animation
struct LetterAnimationModifier: ViewModifier {
    let delay: Double
    var duration: Double = 1.2
    @State private var internalAnim = false

    func body(content: Content) -> some View {
        content
            .opacity(internalAnim ? 1.0 : 0.4)
            .scaleEffect(internalAnim ? 1.15 : 1.0)
            .animation(
                .easeInOut(duration: duration)
                .repeatForever(autoreverses: true)
                .delay(delay),
                value: internalAnim
            )
            .onAppear {
                internalAnim = true
            }
    }
}


// View Extension to handle smooth animatable inner shadows
extension View {
    func innerShadow(color: Color, radius: CGFloat, offsetX: CGFloat, offsetY: CGFloat) -> some View {
        self.overlay(
            Circle()
                .stroke(color, lineWidth: radius)
                .blur(radius: radius / 1.5)
                .offset(x: offsetX, y: offsetY)
                .mask(Circle())
        )
    }
}


#Preview {
    SearchingOrbLoader()
}

#Preview {
    OrbLoaderView()
}
