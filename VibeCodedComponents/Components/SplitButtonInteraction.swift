//
//  SplitButtonInteraction.swift
//  VibeCodedComponents
    

import SwiftUI

struct SplitButtonInteraction: View {
    @State private var isExpanded = false
    @Environment(\.colorScheme) private var scheme
    let platforms = ["iOS", "macOS", "tvOS"]
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                // A playful, bouncy spring animation
                withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                    isExpanded.toggle()
                }
            } label: {
                ZStack {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .opacity(isExpanded ? 1 : 0)
                        .scaleEffect(isExpanded ? 1 : 0.5)
                    
                    Text("New Project")
                        .font(.system(size: 16, weight: .medium))
                        // fixedSize() is the secret trick here! It prevents the text
                        // from showing "New Pro..." truncation dots while the capsule shrinks.
                        .fixedSize()
                        .opacity(isExpanded ? 0 : 1)
                        .scaleEffect(isExpanded ? 0.5 : 1)
                }
                .frame(height: 50)
                // Morph between a pill (140 width) and a circle (50 width)
                .frame(width: isExpanded ? 50 : 140)
                .background(Color(white: scheme == .light ? 0.95 : 0.09), in: .capsule)
            }
            .buttonStyle(.plain)
            
            // MARK: - 2. The Expanding Platform Pills
            if isExpanded {
                ForEach(platforms, id: \.self) { platform in
                    Button {
                        // Action for the specific platform
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                            isExpanded = false
                        }
                    } label: {
                        Text(platform)
                            .font(.system(size: 16, weight: .medium))
                            .frame(height: 50)
                            .padding(.horizontal, 24)
                            .background(Color(white: scheme == .light ? 0.95 : 0.09), in: .capsule)
                    }
                    .buttonStyle(.plain)
                    // 3. The Custom "Slide & Pop" Transition
                    .transition(
                        .asymmetric(
                            // Inserting: Scale up from 50%, fade in, and slide right from an offset
                            insertion: .scale(scale: 0.5, anchor: .leading)
                                .combined(with: .opacity)
                                .combined(with: .offset(x: -30)),
                            // Removing: Shrink back down, fade out, and slide left
                            removal: .scale(scale: 0.5, anchor: .leading)
                                .combined(with: .opacity)
                                .combined(with: .offset(x: -30))
                        )
                    )
                }
            }
        }
        .sensoryFeedback(.impact(flexibility: .rigid), trigger: isExpanded)
    }
}

#Preview {
    SplitButtonInteraction()
}
