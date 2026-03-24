//
//  TabBarAnimation.swift
//  VibeCodedComponents
  
import SwiftUI


struct SmoothGooeyMenu: View {
    @State private var isOn = false
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        ZStack {
            Color.primary.opacity(0.01).ignoresSafeArea()
            
            VStack(spacing: 40) {
                
                // 1. Single Unified Layout Container
                // By using negative spacing, the circle slides perfectly behind the pill
                HStack(spacing: isOn ? 14 : -60) {
                    HStack(spacing: 24) {
                        Image(systemName: "helm")
                        Image(systemName: "clock.fill")
                        Image(systemName: "chevron.up.chevron.down")
                    }
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                    )
                    .zIndex(1)
                    
                    // The Detached Circle
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                        
                        // Inner logo that scales up as it appears
                        HStack(spacing: -8) {
                            Circle().fill(Color.red).frame(width: 14, height: 14)
                            Circle().fill(Color.orange).frame(width: 14, height: 14)
                        }
                        .scaleEffect(isOn ? 1 : 0.1)
                        .opacity(isOn ? 1 : 0)
                    }
                    .frame(width: 56, height: 56)
//                     Scale and fade the circle slightly as it tucks away for extra smoothness
                    .scaleEffect(isOn ? 1 : 0.2)
                    .zIndex(0)
                }
                .frame(height: 80)
                .animation(.spring(response: 0.5, dampingFraction: 0.55), value: isOn)
                
                
                Button(action: toggleMenuVisibility) {
                    Text(isOn ? "On" : "Off")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isOn ? .white : .gray)
                        .frame(width: 80, height: 40)
                        .background(
                            ZStack {
                                Capsule()
                                    .fill(isOn ? Color.black : Color(white: scheme == .light ? 0.98 : 0.09))
                                    
                                Capsule()
                                    .stroke(.quinary, style: StrokeStyle(lineWidth: 1.2, lineCap: .round))
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isOn)
    }
    
    func toggleMenuVisibility() {
        if !isOn {
            Sound.play(.startup)
        }
        
        isOn.toggle()
    }
}

#Preview {
    SmoothGooeyMenu()
}
