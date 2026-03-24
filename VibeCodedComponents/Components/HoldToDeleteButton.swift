//
//  HoldToDeleteButton.swift
//  VibeCodedComponents
    

import SwiftUI

struct HoldToDeleteButton: View {
    // State machine for the interaction
    @State private var isPressing = false
    @State private var progress: CGFloat = 0.0
    @State private var isSuccess = false
    @Environment(\.colorScheme) private var scheme
    
    // We use a Task to track how long the button has been held
    @State private var pressTask: Task<Void, Never>?
    let holdDuration: TimeInterval = 1.5 // Seconds required to complete the action
    
    var body: some View {
        ZStack {
            Color.primary.opacity(0).edgesIgnoringSafeArea(.all)
            
            GeometryReader { geo in
                let width = geo.size.width
                
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(white: scheme == .light ? 0.95 : 0.09))
                    
                    // The Animated Pink Fill
                    // It grows from the leading edge based on the 'progress' variable
                    Rectangle()
                        .fill(.pink.quinary.opacity(0.4))
                        .frame(width: width * progress)
                    
                    
                    HStack(spacing: 12) {
                        Image(uiImage: UIImage.trashIcon.withRenderingMode(.alwaysTemplate))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22)
                            .foregroundStyle(isPressing || isSuccess ? Color.pink.gradient : Color.blue.gradient)
                        
                        Text(isSuccess ? "Deletion Done!!" : "Hold to Delete")
                            .font(.system(size: 17, weight: .semibold))
                            .contentTransition(.numericText()) // Smooth text swap
                            .foregroundColor(isPressing || isSuccess ? .pink : .primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center) // Keep text centered
                }
                // Crucial: This clips the growing pink fill to the capsule's rounded corners
                .clipShape(Capsule())
                // Joyful physics: Button scales down slightly when pressed, pops up on success
                .scaleEffect(isSuccess ? 1.05 : (isPressing ? 0.96 : 1.0))
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSuccess)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressing)
                // The Gesture Tracking
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isPressing && !isSuccess {
                                startPress()
                            }
                        }
                        .onEnded { _ in
                            if isPressing {
                                cancelPress()
                            }
                        }
                )
            }
            .frame(width: 190, height: 52)
        }
        // Apple's built-in Haptic Feedback engine (iOS 17+)
        .sensoryFeedback(.success, trigger: isSuccess)
        .sensoryFeedback(.impact(weight: .light), trigger: isPressing)
    }
    
    // MARK: - Interaction Logic
    
    private func startPress() {
        isPressing = true
        
        // 1. Start the smooth visual fill animation
        withAnimation(.linear(duration: holdDuration)) {
            progress = 1.0
        }
        
        // 2. Start the invisible timer. If it reaches the duration, trigger success.
        pressTask?.cancel()
        pressTask = Task {
            // Convert seconds to nanoseconds
            try? await Task.sleep(nanoseconds: UInt64(holdDuration * 1_000_000_000))
            
            // If the user hasn't let go by the time the sleep finishes...
            if !Task.isCancelled && isPressing {
                await MainActor.run {
                    completeAction()
                }
            }
        }
    }
    
    private func cancelPress() {
        isPressing = false
        pressTask?.cancel() // Stop the timer
        
        // If they didn't hold it long enough, snap the visual progress back to 0
        if !isSuccess {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                progress = 0.0
            }
        }
    }
    
    private func completeAction() {
        Sound.play(.success)
        isSuccess = true
        isPressing = false
        
        // Optional: Auto-reset the button back to its default state after 2 seconds
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isSuccess = false
                    progress = 0.0
                }
            }
        }
    }
}

#Preview {
    HoldToDeleteButton()
}
