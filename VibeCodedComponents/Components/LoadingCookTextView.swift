//
//  LoadingCookTextView.swift
//  VibeCodedComponents
    
import SwiftUI


struct LoadingCookTextView: View {
    @State private var currentIndex = 0
    @State private var progress: CGFloat = 0.0
    
    let messages = [
        "Hold on, let me cook..",
        "Searching for the perfect recipe..",
        "Adding dynamic rectangle calculations for different methods"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // 1. Animated Text Container
            ZStack(alignment: .leading) {
                Text(messages[currentIndex])
                    .foregroundStyle(.secondary)
                    .font(.system(size: 16, weight: .medium))
                    // The .id modifier is the secret sauce. It tells SwiftUI this is a
                    // completely new view when the text changes, triggering the transition.
                    .id(messages[currentIndex])
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        )
                    )
            }
            .frame(height: 24, alignment: .bottomLeading)
            // .clipped() acts as a window, hiding the text as it slides up and out
            .clipped()
            
            
            // 3. Simple Animated Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.15))
                    
                    Capsule()
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 3)
        }
        .sensoryFeedback(.selection, trigger: currentIndex)
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.primary.opacity(0.01).ignoresSafeArea())
        .task {
            await startSequence()
        }
    }
    
    // Modern concurrency to handle the timing sequences
    private func startSequence() async {
        let loopDelay = UInt64(1600_000_000)
        
        // Start the progress bar moving slowly across the screen
        withAnimation(.linear(duration: 10.0)) {
            progress = 0.90
        }
        

        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: loopDelay)
            
            await MainActor.run {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                    currentIndex = (currentIndex + 1) % messages.count
                }
            }
        }
    }
}



#Preview {
    LoadingCookTextView()
}
