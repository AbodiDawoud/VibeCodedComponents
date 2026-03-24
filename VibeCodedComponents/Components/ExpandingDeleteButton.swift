//
//  ExpandingDeleteButton.swift
//  VibeCodedComponents
    
import SwiftUI

struct ExpandingDeleteButton: View {
    @Namespace private var animation
    @State private var isExpanded = false
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.clear.ignoresSafeArea()
                .onTapGesture {
                    if isExpanded {
                        isExpanded = false
                    }
                }
            
            if !isExpanded {
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(.quinary.opacity(0.8), lineWidth: 1.2)
                        .fill((Color(white: scheme == .light ? 0.96 : 0.1)))
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .matchedGeometryEffect(id: "container", in: animation)

                    Text("")
                        .font(.system(size: 16, weight: .semibold))
                        .fixedSize()
                        .matchedGeometryEffect(id: "text", in: animation, properties: .position)
                    
                    Image(uiImage: UIImage(resource: .trashIcon).withRenderingMode(.alwaysTemplate))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.pink.gradient)
                        .matchedGeometryEffect(id: "icon", in: animation)
                }
                .padding(32) // Keep it comfortably away from screen edges
                .onTapGesture {
                    isExpanded = true
                }
                .zIndex(1)
            } else {
                // Expanded Dialog State
                VStack(spacing: 0) {
                    // Dialog Text Content
                    VStack(spacing: 12) {
                        Text("Are you sure you want to\ndelete this item?")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        Text("This action cannot be undone.")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 24)
                     // The text smoothly fades in when the dialog expands
                    .transition(.opacity.animation(.linear(duration: 0.01)))
                    
                    Spacer(minLength: 32)
                    
                    // The "Delete Item" Button
                    HStack {
                        Text("Delete Item")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.pink)
                            .fixedSize()
                            .transition(.opacity.animation(.linear(duration: 0.14))) // Fade the text while expanding
                            .matchedGeometryEffect(id: "text", in: animation, properties: .position)
                            
                        
                        Spacer()
                            .transition(.opacity.animation(.linear(duration: 0.14)))
                        
                        // The icon smoothly travels to its new position
                        Image(uiImage: UIImage(resource: .trashIcon).withRenderingMode(.alwaysTemplate))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.pink.gradient)
                            .matchedGeometryEffect(id: "icon", in: animation)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.pink.quinary)
                            .transition(.opacity.animation(.linear(duration: 0.14))) // Fade the button background
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .onTapGesture {
                        isExpanded = false
                    }
                }
                .frame(width: 300)
                .frame(height: 250)
                // The main background smoothly scales up to encompass the new content
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.white)
                        .matchedGeometryEffect(id: "container", in: animation)
                        .shadow(color: .black.opacity(0.1), radius: 25, x: 0, y: 12)
                )
                .padding(32) // Maintain the same edge padding as the collapsed state
                .zIndex(2) // Ensure the expanded dialog sits on top during the animation
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: isExpanded)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isExpanded)
    }
}

#Preview {
    ExpandingDeleteButton()
}
