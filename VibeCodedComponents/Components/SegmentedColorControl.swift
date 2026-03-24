//
//  SegmentedColorControl.swift
//  VibeCodedComponents
    

import SwiftUI

// Define our tabs
enum SegmentTab: String, CaseIterable {
    case basic = "Basic"
    case detail = "Detail"
    case color = "Color"
}

struct SegmentedColorControl: View {
    @State private var selectedTab: SegmentTab = .basic
    @Namespace private var animation
    @Environment(\.colorScheme) private var scheme
    
    // The base colors shown in the video
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    
    var body: some View {
        ZStack {
            // Background to match the clean aesthetic
            Color.primary.opacity(0.01).ignoresSafeArea()
            
            HStack(spacing: 0) {
                
                // 1. Segmented Tabs
                HStack(spacing: 0) {
                    ForEach(SegmentTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            // Dark text for active, gray for inactive
                            .foregroundColor(selectedTab == tab ? .black : .gray)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 24)
                            .background {
                                // The sliding active indicator
                                if selectedTab == tab {
                                    Capsule()
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                                        .matchedGeometryEffect(id: "activeTabBackground", in: animation)
                                }
                            }
                            // Makes the entire padding area tappable
                            .contentShape(Capsule())
                            .onTapGesture {
                                Sound.play(.tick)
                                // A snappy spring for the tab selection
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    selectedTab = tab
                                }
                            }
                    }
                }
                
                // 2. Expanding Color Picker
                if selectedTab == .color {
                    HStack(spacing: 12) {
                        // Standard colors
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 24, height: 24)
                        }
                        
                        // The rainbow picker icon from the video
                        Circle()
                            .fill(
                                AngularGradient(
                                    colors: [.red, .yellow, .green, .blue, .purple, .red],
                                    center: .center
                                )
                            )
                            .frame(width: 24, height: 24)
                    }
                    .padding(.leading, 12)
                    .padding(.trailing, 8)
                    // This transition mimics how the colors shrink and fade into the "Color" tab
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.5, anchor: .leading).combined(with: .opacity),
                            removal: .scale(scale: 0.5, anchor: .leading).combined(with: .opacity)
                        )
                    )
                }
            }
            .padding(6)
            .background(
                ZStack {
                    Capsule().fill(Color(white: scheme == .light ? 0.95 : 0.09))
                    Capsule().stroke(.quinary, style: StrokeStyle(lineWidth: 1.2, lineCap: .round))
                }
            )
            // This parent animation dictates how smoothly the gray background expands/collapses
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: selectedTab)
        }
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}

#Preview {
    SegmentedColorControl()
}


