//
//  NestedDynamicToggle.swift
//  VibeCodedComponents
    

import SwiftUI


struct NestedDynamicSegment: View {
    @State private var selection: PricingPlan = .free
    @Namespace private var animation
    
    // We use a fixed total width to guarantee smooth 1/3 and 2/3 layout transitions
    let totalWidth: CGFloat = 360
    
    // Calculate the dynamic widths based on state
    var freeWidth: CGFloat { selection == .free ? totalWidth / 2 : totalWidth / 3 }
    var premiumWidth: CGFloat { selection == .free ? totalWidth / 2 : (totalWidth / 3) * 2 }
    
    var body: some View {
        ZStack {
            Color.primary.opacity(0.05).ignoresSafeArea()
            
            HStack(spacing: 0) {
                
                // MARK: - Free Button
                Button {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                        selection = .free
                    }
                } label: {
                    Text("Free")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(selection == .free ? .white : .gray.opacity(0.6))
                        .frame(width: freeWidth, height: 52)
                        .background {
                            // 1. The main black pill when "Free" is selected
                            if selection == .free {
                                Capsule()
                                    .fill(Color.black)
                                    .matchedGeometryEffect(id: "mainBlackPill", in: animation)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                
                // MARK: - Premium Container
                ZStack {
                    // Collapsed State
                    if selection == .free {
                        Button {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                selection = .monthly // Default to monthly
                            }
                        } label: {
                            VStack(spacing: 2) {
                                Text("Premium")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Monthly • Annual")
                                    .font(.system(size: 11, weight: .regular))
                            }
                            .foregroundColor(.gray.opacity(0.6))
                            .frame(width: premiumWidth, height: 52)
                            .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .transition(.opacity)
                        
                    } else {
                        // Expanded State (Monthly / Annual)
                        HStack(spacing: 0) {
                            
                            // Monthly Button
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    selection = .monthly
                                }
                            } label: {
                                Text("Monthly")
                                    .font(.system(size: 15, weight: .medium))
                                    // Black text if active (on white pill), white text if inactive (on black pill)
                                    .foregroundColor(selection == .monthly ? .black : .white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background {
                                        // 2. The inner white pill
                                        if selection == .monthly {
                                            Capsule()
                                                .fill(Color.white)
                                                // Padding creates the black border effect you mentioned!
                                                .padding(4)
                                                .matchedGeometryEffect(id: "innerWhitePill", in: animation)
                                        }
                                    }
                                    .contentShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            
                            // Annual Button
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    selection = .annual
                                }
                            } label: {
                                Text("Annual")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(selection == .annual ? .black : .white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background {
                                        // 2. The inner white pill
                                        if selection == .annual {
                                            Capsule()
                                                .fill(Color.white)
                                                .padding(4)
                                                .matchedGeometryEffect(id: "innerWhitePill", in: animation)
                                        }
                                    }
                                    .contentShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(width: premiumWidth, height: 52)
                        .background {
                            // 1. The main black pill stretched across the premium container
                            Capsule()
                                .fill(Color.black)
                                .matchedGeometryEffect(id: "mainBlackPill", in: animation)
                        }
                        .transition(.opacity)
                    }
                }
            }
            .padding(6)
            .background(
                Capsule()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 15, y: 8)
            )
            .frame(width: totalWidth + 12) // +12 accounts for the padding
            .sensoryFeedback(.selection, trigger: selection)
        }
    }
}

fileprivate enum PricingPlan {
    case free
    case monthly
    case annual
}

#Preview {
    NestedDynamicSegment()
}
