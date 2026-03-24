//
//  DiscreteTabsView.swift
//  VibeCodedComponents
    

import SwiftUI


struct DiscreteTabsView: View {
    @State private var selectedTab: AppTab = .brain
    
    var body: some View {
        ZStack {
            // Soft background to make the white buttons pop
            Color.primary.opacity(0.05).ignoresSafeArea()
            
            HStack(spacing: 14) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    let isSelected = selectedTab == tab
                    
                    Button {
                        // The spring that drives the morphing animation
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.45)) {
                            selectedTab = tab
                        }
                        Sound.play(.tick)
                    } label: {
                        HStack(spacing: 8) {
                            Image(uiImage: UIImage(named: tab.icon)!.withRenderingMode(.alwaysTemplate))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                //.font(.system(size: 20, weight: .semibold))
                            
                            if isSelected {
                                Text(tab.rawValue)
                                    .font(.system(size: 16, weight: .bold))
                                    // fixedSize prevents the text from wrapping/truncating while the capsule expands
                                    .fixedSize()
                                    // Trigger our custom shimmer
                                    .modifier(OneShotShimmer(isActive: isSelected))
                            }
                        }
                        // Padding expands the pill, zero padding keeps the circle tight
                        .padding(.horizontal, isSelected ? 20 : 0)
                        // Nil width allows the text to dictate the size, 56 forces a perfect circle
                        .frame(width: isSelected ? nil : 56, height: 56)
                        .foregroundStyle(isSelected ? AnyShapeStyle(tab.themeColor.gradient) : AnyShapeStyle(.black))
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .sensoryFeedback(.impact(flexibility: .soft), trigger: selectedTab)
        }
    }
}


fileprivate extension DiscreteTabsView {
    enum AppTab: String, CaseIterable {
        case calendar = "Planner"
        case brain = "Brain"
        case thunder = "Thunder"
        
        var icon: String {
            switch self {
            case .calendar: return "CalendarIcon"
            case .brain: return "BrainIcon"
            case .thunder: return "ThunderIcon"
            }
        }
        
        var themeColor: Color {
            switch self {
            case .calendar: return .pink
            case .brain: return .indigo
            case .thunder: return .orange
            }
        }
    }
}


struct OneShotShimmer: ViewModifier {
    let isActive: Bool
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .overlay {
                content
                    // The bright highlight color that passes over the text
                    .foregroundStyle(.white.opacity(0.9))
                    .mask {
                        LinearGradient(
                            colors: [.clear, .white, .clear],
                            // Using the UnitPoint trick to guarantee a smooth render
                            startPoint: isAnimating ? .init(x: 1.5, y: 0.5) : .init(x: -0.5, y: 0.5),
                            endPoint: isAnimating ? .init(x: 2.5, y: 0.5) : .init(x: 0.5, y: 0.5)
                        )
                    }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    // Reset instantly, then trigger the sweep with a slight delay
                    isAnimating = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        // The delay ensures the capsule has mostly expanded before the text shimmers
                        withAnimation(.linear(duration: 0.5).delay(0.2)) {
                            isAnimating = true
                        }
                    }
                } else {
                    // Reset when deselected so it's ready for the next time
                    isAnimating = false
                }
            }
            .onAppear {
                if isActive {
                    // Handle the initial state when the view first loads
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation(.linear(duration: 0.5).delay(0.2)) {
                            isAnimating = true
                        }
                    }
                }
            }
    }
}


#Preview {
    DiscreteTabsView()
}
