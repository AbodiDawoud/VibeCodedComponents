//
//  NotifyMeButton.swift
//  VibeCodedComponents
    
import SwiftUI

struct NotifyMeButton: View {
    @State private var isExpanded = false
    @State private var email: String = ""
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if isExpanded {
                expandedView
            } else {
                collapsedView
            }
        }
        .sensoryFeedback(.impact(flexibility: .rigid), trigger: isExpanded)
        .animation(.spring(response: 0.45, dampingFraction: 0.7, blendDuration: 0), value: isExpanded)
    }
    
    private var collapsedView: some View {
        Button(action: toggleExpansion) {
            HStack(spacing: 8) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .matchedGeometryEffect(id: "icon", in: namespace, properties: .position)
                
                Text("Notify Me")
                    .font(.system(size: 16, weight: .semibold))
                    .matchedGeometryEffect(id: "text", in: namespace)
                    .background(
                        Capsule()
                            .fill(Color.clear)
                            .matchedGeometryEffect(id: "innerButton", in: namespace)
                    )
            }
            .foregroundColor(.black)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(Color(white: 0.95))
                    .matchedGeometryEffect(id: "background", in: namespace)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var expandedView: some View {
        HStack(spacing: 8) {
            TextField("Email", text: $email)
                .font(.system(size: 16, weight: .medium))
                .padding(.leading, 24)
                .accentColor(.black)
                .foregroundStyle(.black)
            
            Button(action: toggleExpansion) {
                HStack(spacing: 0) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .matchedGeometryEffect(id: "icon", in: namespace)
                        .frame(width: 0, height: 0)
                        .opacity(0)
                        
                    Text("Notify Me")
                        .font(.system(size: 16, weight: .semibold))
                        .matchedGeometryEffect(id: "text", in: namespace)
                }
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                        .matchedGeometryEffect(id: "innerButton", in: namespace)
                )
            }
            .buttonStyle(.plain)
            .padding(.trailing, 4)
            .padding(.vertical, 4)
        }
        .frame(width: 320)
        .background(
            Capsule()
                .fill(Color(white: 0.95))
                .matchedGeometryEffect(id: "background", in: namespace)
        )
    }
    
    func toggleExpansion() {
        isExpanded.toggle()
    }
}

#Preview {
    NotifyMeButton()
}
