//
//  WaveTextRendererView.swift
//  VibeCodedComponents
    
import SwiftUI


struct WaveTextRendererView: View {
    let prompts = [
        "Create Ghibli style",
        "Blend these images",
        "Make this a meme"
    ]
    
    @State private var currentIndex = 0
    // We drive the TextRenderer with a global 0-1 progress value
    @State private var animationProgress: CGFloat = 1.0
    @State private var inputText: String = ""
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.primary.opacity(0.05).ignoresSafeArea()

            // 1. The Input Field Container
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 15, y: 5)
                    .shadow(color: .black.opacity(0.02), radius: 4, y: 2)
                    .frame(height: 56)
                
                HStack {
                    ZStack(alignment: .leading) {
                        // Exiting Text
                        Text(prompts[previousIndex])
                            .textRenderer(WaveTextRenderer(progress: animationProgress, isEntering: false))
                            // Hide completely once the animation finishes to save resources
                            .opacity(animationProgress < 1.0 ? 1 : 0)
                        
                        // Entering Text
                        Text(prompts[currentIndex])
                            .textRenderer(WaveTextRenderer(progress: animationProgress, isEntering: true))
                    }
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    // Soft light gray color matching the video
                    .foregroundStyle(Color(white: 0.85))
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // 3. The Pink Action Button
                    Image(systemName: "arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.pink.gradient)
                        .frame(width: 36, height: 36)
                        .padding(.trailing, 10)
                }
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            startLoop()
        }
    }
    
    // Helper to know what text we are animating away from
    var previousIndex: Int {
        (currentIndex - 1 + prompts.count) % prompts.count
    }
    
    // Automatically cycle through prompts
    func startLoop() {
        let delay: TimeInterval = 2.6
        Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { _ in
            // Reset state instantly
            animationProgress = 0
            currentIndex = (currentIndex + 1) % prompts.count
            
            // Fire the spring animation to drive the TextRenderer
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                animationProgress = 1.0
            }
        }
    }
}


@available(iOS 18.0, *)
fileprivate struct WaveTextRenderer: TextRenderer, Animatable {
    var progress: CGFloat
    var isEntering: Bool
    
    // This tells SwiftUI to interpolate this value during an animation
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for line in layout {
            for run in line {
                // Iterate through every single character (glyph) in the run
                for index in run.indices {
                    let slice = run[index..<run.index(after: index)]
                    let rect = slice.typographicBounds.rect
                    
                    // 1. Spatial Delay: Multiply the X position to create a left-to-right cascade
                    let delay = rect.minX * 0.002
                    
                    // 2. Local Progress: Adjust the global progress by the character's delay
                    // Multiplying by 1.5 ensures the local animation finishes before the global one hits 1.0
                    var localProgress = (progress - delay) * 1.5
                    localProgress = max(0, min(1, localProgress)) // Clamp between 0 and 1
                    
                    var copy = context
                    
                    if isEntering {
                        // Spring up from below and fade in
                        let yOffset = 20 * (1 - localProgress)
                        copy.translateBy(x: 0, y: yOffset)
                        copy.opacity = localProgress
                    } else {
                        // Spring up and out, fading away
                        let yOffset = -20 * localProgress
                        copy.translateBy(x: 0, y: yOffset)
                        copy.opacity = 1 - localProgress
                    }
                    
                    // Draw the individual character
                    copy.draw(slice)
                }
            }
        }
    }
}


#Preview {
    WaveTextRendererView()
}
