//
//  InteractiveNodeView.swift
//  VibeCodedComponents
    

import SwiftUI

struct InteractiveNodeView: View {
    @State private var isExpanded = false
    @Namespace private var animationNamespace
    
    var body: some View {
        ZStack {
            // Background dotted pattern
            Color.primary.opacity(0.05).edgesIgnoringSafeArea(.all)
            
            // Connecting Lines (Vertical and Horizontal)
            CrossLines()
            
            if isExpanded {
                // Expanded Card State
                ExpandedCardView(isExpanded: $isExpanded)
                    // The background is what actually morphs geometry
                    .background(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(Color.white)
                            .matchedGeometryEffect(id: "cardBackground", in: animationNamespace)
                            .shadow(color: Color.black.opacity(0.1), radius: 25, x: 0, y: 15)
                    )
                    .transition(.blurReplace)
                    .zIndex(1)
            } else {
                // Collapsed Node State
                ZStack {
                    // Invisible morphing anchor point
                    Color.white.opacity(0.0001)
                        .matchedGeometryEffect(id: "cardBackground", in: animationNamespace)
                        .frame(width: 10, height: 10)
                        .cornerRadius(5)
                    
                    // The actual black dot
                    centerDotsGroup
                }
                .frame(width: 60, height: 60) // Larger hit area
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0)) {
                        isExpanded = true
                    }
                }
                .zIndex(0)
            }
        }
        .sensoryFeedback(.impact(flexibility: .rigid), trigger: isExpanded)
    }
    
    private var centerDotsGroup: some View {
        // The 5-dot cross arrangement
        ZStack {
            // Center dot
            Circle().fill(Color.primary).frame(width: 5)
            // Top dot
            Circle().fill(Color.primary).frame(width: 5).offset(y: -10)
            // Bottom dot
            Circle().fill(Color.primary).frame(width: 5).offset(y: 10)
            // Left dot
            Circle().fill(Color.primary).frame(width: 5).offset(x: -10)
            // Right dot
            Circle().fill(Color.primary).frame(width: 5).offset(x: 10)
        }
    }
}


fileprivate struct ExpandedCardView: View {
    @Binding var isExpanded: Bool
    
    // Grid configuration
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("Add job")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Text("More >")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 2)
            
            // Grid of Icons
            LazyVGrid(columns: columns, spacing: 12) {
                JobCell(title: "fetch", icon: AnyView(FetchIcon()))
                JobCell(title: "listen", icon: AnyView(ListenIcon()))
                JobCell(title: "validate", icon: AnyView(ValidateIcon()))
                
                JobCell(title: "flag", icon: AnyView(FlagIcon()))
                JobCell(title: "enrich", icon: AnyView(EnrichIcon()))
                JobCell(title: "notify", icon: AnyView(NotifyIcon()))
            }
            
            // Bottom Search / Input Bar
            HStack {
                Text("Or just describe it")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.gray.opacity(0.7))
                Spacer()
                Image(systemName: "mic.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(width: 38, height: 28)
                    .background(Color(UIColor.systemGray6), in: .capsule)
            }
            .padding(.leading, 16)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .padding(.top, 14)
        }
        .padding(20)
        .frame(width: 320)
        // Dismiss when tapping outside the grid (optional behavior)
        // To strictly follow the video, we'll allow tapping the card itself to dismiss for testing purposes
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0)) {
                isExpanded = false
            }
        }
    }
}


fileprivate struct JobCell: View {
    var title: String
    var icon: AnyView
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            icon
                .frame(width: 40, height: 30)
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .background(Color(white: 0.97))
        .cornerRadius(16)
    }
}


// MARK: - Custom Icons

fileprivate struct FetchIcon: View {
    let color = Color(red: 0.35, green: 0.75, blue: 0.25) // Bright Green
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let pad: CGFloat = 3
            
            ZStack {
                // Top curve (dips down)
                Path { path in
                    path.move(to: CGPoint(x: pad, y: pad))
                    path.addQuadCurve(to: CGPoint(x: w - pad, y: pad), control: CGPoint(x: w/2, y: h/2 - 2))
                }
                .stroke(color.opacity(0.3), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                
                // Bottom curve (bows up)
                Path { path in
                    path.move(to: CGPoint(x: pad, y: h - pad))
                    path.addQuadCurve(to: CGPoint(x: w - pad, y: h - pad), control: CGPoint(x: w/2, y: h/2 + 2))
                }
                .stroke(color.opacity(0.3), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                
                // 4 Corner Dots
                Circle().fill(color).frame(width: 4.5, height: 4.5).position(x: pad, y: pad)
                Circle().fill(color).frame(width: 4.5, height: 4.5).position(x: w - pad, y: pad)
                Circle().fill(color).frame(width: 4.5, height: 4.5).position(x: pad, y: h - pad)
                Circle().fill(color).frame(width: 4.5, height: 4.5).position(x: w - pad, y: h - pad)
            }
        }
        .frame(width: 26, height: 20)
    }
}


fileprivate struct ListenIcon: View {
    let color = Color(red: 0.35, green: 0.5, blue: 0.95) // Indigo/Blue
    
    var body: some View {
        ZStack {
            // Faded background circle perfectly aligned behind the first and middle dots
            Circle()
                .stroke(color.opacity(0.13), lineWidth: 3)
                .frame(width: 20, height: 20)
            
            // 3 Horizontal dots
            HStack(spacing: 6) {
                Circle().fill(color).frame(width: 5, height: 5)
                Circle().fill(color).frame(width: 5, height: 5)
                Circle().fill(color).frame(width: 5, height: 5)
            }
        }
        .frame(width: 28, height: 20)
    }
}


fileprivate struct ValidateIcon: View {
    let color = Color(red: 0.15, green: 0.65, blue: 0.9) // Cyan
    
    var body: some View {
        // Explicitly align leading to ensure the left dots form a perfect vertical line
        VStack(alignment: .leading, spacing: 6) {
            GradientRow(color: color, length: 18)
            HStack(spacing: 0) {
                Circle()
                    .fill(color)
                    .frame(width: 4.5, height: 4.5)
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(color.opacity(0.8))
                    .frame(width: 20, height: 3)
                    .offset(x: -2.5)
                    .zIndex(-1)
                Circle()
                    .fill(color)
                    .frame(width: 4.5, height: 4.5)
                    .offset(x: -5)
            }
            GradientRow(color: color, length: 18)
        }
        .frame(width: 28, height: 20, alignment: .leading)
    }
    
    struct GradientRow: View {
        var color: Color
        var length: CGFloat
        
        var body: some View {
            HStack(spacing: 0) {
                Circle()
                    .fill(color)
                    .frame(width: 4.5, height: 4.5)
                
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.8), color.opacity(0.1)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: length, height: 3)
                    .offset(x: -2.5)
            }
        }
    }
}


fileprivate struct FlagIcon: View {
    let color = Color(red: 0.95, green: 0.45, blue: 0.4) // Coral/Red
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let pad: CGFloat = 3
            
            ZStack {
                // Crossing lines
                Path { path in
                    path.move(to: CGPoint(x: pad, y: pad))
                    path.addLine(to: CGPoint(x: w - pad, y: h - pad))
                    path.move(to: CGPoint(x: w - pad, y: pad))
                    path.addLine(to: CGPoint(x: pad, y: h - pad))
                }
                .stroke(color.opacity(0.25), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                
                // 4 Corner Dots
                Circle().fill(color).frame(width: 4.5, height: 4.5).position(x: pad, y: pad)
                Circle().fill(color).frame(width: 4.5, height: 4.5).position(x: w - pad, y: pad)
                Circle().fill(color).frame(width: 4.5, height: 4.5).position(x: pad, y: h - pad)
                Circle().fill(color).frame(width: 4.5, height: 4.5).position(x: w - pad, y: h - pad)
                
                // Center Dot
                Circle().fill(color).frame(width: 5, height: 5).position(x: w/2, y: h/2)
            }
        }
        .frame(width: 24, height: 24)
    }
}


fileprivate struct EnrichIcon: View {
    let color = Color(red: 0.6, green: 0.4, blue: 0.9) // Purple
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let pad: CGFloat = 3
            
            ZStack {
                // Funnel / Cone Background
                Path { path in
                    path.move(to: CGPoint(x: pad, y: h/2))
                    path.addLine(to: CGPoint(x: w - pad, y: pad))
                    path.addLine(to: CGPoint(x: w - pad, y: h - pad))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(gradient: Gradient(colors: [color.opacity(0.05), color.opacity(0.25)]), startPoint: .leading, endPoint: .trailing)
                )
                
                // Left Dot
                Circle().fill(color).frame(width: 4.5, height: 4.5).position(x: pad, y: h/2)
                
                // Right 3 Dots
                Circle().fill(color).frame(width: 4.5, height: 4.5).position(x: w - pad, y: pad)
                Circle().fill(color).frame(width: 4.5, height: 4.5).position(x: w - pad, y: h/2)
                Circle().fill(color).frame(width: 4.5, height: 4.5).position(x: w - pad, y: h - pad)
            }
        }
        .frame(width: 24, height: 24)
    }
}


fileprivate struct NotifyIcon: View {
    let color = Color(red: 0.95, green: 0.55, blue: 0.3) // Orange
    
    var body: some View {
        ZStack {
            // Faint Inner Background Circle
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 14, height: 14)
            
            // Center Dot
            Circle()
                .fill(color)
                .frame(width: 5, height: 5)
            
            // 4 Outer Compass Dots
            Group {
                Circle().fill(color.opacity(0.8)).frame(width: 4, height: 4).offset(y: -11)
                Circle().fill(color.opacity(0.8)).frame(width: 4, height: 4).offset(y: 11)
                Circle().fill(color.opacity(0.8)).frame(width: 4, height: 4).offset(x: -11)
                Circle().fill(color.opacity(0.8)).frame(width: 4, height: 4).offset(x: 11)
            }
        }
        .frame(width: 26, height: 26)
    }
}


fileprivate struct CrossLines: View {
    var body: some View {
        GeometryReader { geometry in
            let cx = geometry.size.width / 2
            let cy = geometry.size.height / 2
            
            ZStack {
                // Horizontal Line
                Path { path in
                    path.move(to: CGPoint(x: 20, y: cy))
                    path.addLine(to: CGPoint(x: geometry.size.width - 20, y: cy))
                }
                .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                
                // Dots on horizontal line
                Circle().fill(.primary).frame(width: 4, height: 4).position(x: cx - 180, y: cy)
                Circle().fill(.primary).frame(width: 4, height: 4).position(x: cx + 180, y: cy)
            }
        }
        .allowsHitTesting(false)
    }
}


#Preview {
    InteractiveNodeView()
    //ExpandedCardView(isExpanded: .constant(true))
}
