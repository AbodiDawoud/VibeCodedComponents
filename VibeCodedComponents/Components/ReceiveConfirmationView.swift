//
//  ReceiveConfirmationView.swift
//  VibeCodedComponents
    

import SwiftUI


struct ReceiveConfirmationView: View {
    @State private var isExpanded = false
    @Namespace private var animation
    
    var body: some View {
        VStack {
            Spacer()
            
            if isExpanded {
                expandedModal
            } else {
                collapsedButton
            }
        }
        .padding(24)
        .sensoryFeedback(.impact(weight: .light), trigger: isExpanded)
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: isExpanded)
    }
    

    var collapsedButton: some View {
        Button {
            isExpanded.toggle()
        } label: {
            Text("Receive")
                // Unified font size prevents rendering hitches
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)
                // 1. Force the text to never wrap or truncate during the morph
                .fixedSize()
                // 2. Only match the position, not the size, to prevent layout panics
                .matchedGeometryEffect(id: "receiveText", in: animation, properties: .position)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Capsule()
                        .fill(Color(white: 0.95))
                        .matchedGeometryEffect(id: "receiveBackground", in: animation)
                )
        }
        .buttonStyle(.plain)
        // Clean exit so the collapsed frame doesn't linger
        .transition(.opacity)
    }
    

    var expandedModal: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: "touchid")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.orange.gradient)
                
                Text("Confirm")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button {
                    isExpanded.toggle()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            // 3. Directional transition: Slides up when appearing, down when disappearing
            .transition(.move(edge: .bottom).combined(with: .opacity))
            
            // Body Text
            Text("Are you sure you want to receive\nhell load of money?")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(white: 0.7))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 8)
            // 3. Directional transition
            .transition(.move(edge: .bottom).combined(with: .opacity))
            
            // Footer
            HStack(spacing: 16) {
                Button {
                    isExpanded.toggle()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(white: 0.7))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                // 3. Directional transition
                .transition(.move(edge: .bottom).combined(with: .opacity))
                
                Button {
                    isExpanded.toggle()
                } label: {
                    Text("Receive")
                        // Unified font size
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .fixedSize()
                        // 2. Only match the position
                        .matchedGeometryEffect(id: "receiveText", in: animation, properties: .position)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .matchedGeometryEffect(id: "receiveBackground", in: animation)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(white: 0.09))
                // 3. The entire modal background now slides up dynamically
                .transition(.move(edge: .bottom).combined(with: .opacity))
        )
    }
}

#Preview {
    ReceiveConfirmationView()
}
