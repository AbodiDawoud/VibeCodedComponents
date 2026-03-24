//
//  DrawingPromptBox
//  VibeCodedComponents
    

import SwiftUI


struct DrawingPromptBox: View {
    // MARK: - State
    @State private var isSketchExpanded: Bool = true
    @State private var lines: [DrawingLine] = []
    
    // Bottom Toolbar Background Color (Matches the pale green/yellow tint in the video)
    let bottomBarColor = Color(red: 0.94, green: 0.97, blue: 0.93)
    
    var body: some View {
        ZStack {
            // A beautiful blurred background to make the white card pop
            Color(white: 0.9).ignoresSafeArea()
            Image(systemName: "leaf.fill")
                .resizable()
                .scaledToFill()
                .blur(radius: 60)
                .opacity(0.1)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 12) {
                
                // MARK: - 1. Top Floating Tabs
                HStack(spacing: 8) {
                    TopTabButton(icon: "doc.on.clipboard", text: "Paste SVG")
                    TopTabButton(icon: "play.circle", text: "Try a sample")
                    TopTabButton(icon: "pencil.line", text: "Sketch")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                // MARK: - 2. The Main Interactive Card
                VStack(spacing: 0) {
                    
                    // The Drawing Canvas Area
                    ZStack(alignment: .topTrailing) {
                        Color.white
                        
                        DrawingCanvas(lines: $lines)
                        
                        // Trash Button
                        Button {
                            // Clear the canvas with a satisfying snap
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                lines.removeAll()
                            }
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(white: 0.6))
                                .padding(16)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(height: 220)
                    
                    // MARK: - 3. The Morphing Bottom Toolbar
                    HStack(spacing: 16) {
                        
                        if isSketchExpanded {
                            // Expanded State Tools
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    lines.removeAll()
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(white: 0.3))
                            }
                            .transition(.scale(scale: 0.5).combined(with: .opacity))
                            
                            Button {
                                toggleSketch()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "pencil.slash")
                                    Text("Hide Sketch")
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.8)) // Dark blue
                            }
                            .transition(.move(edge: .leading).combined(with: .opacity))
                            
                            Button {} label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "doc.on.clipboard")
                                    Text("Paste SVG")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(Color(white: 0.3))
                            }
                            .transition(.move(edge: .leading).combined(with: .opacity))
                            
                        } else {
                            // Collapsed State Tools
                            Button {
                                toggleSketch()
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(white: 0.3))
                            }
                            .transition(.scale(scale: 0.5).combined(with: .opacity))
                        }
                        
                        // "Pro" Dropdown (Always visible, slides dynamically)
                        Button {} label: {
                            HStack(spacing: 4) {
                                Text("Pro")
                                    .font(.system(size: 14, weight: .semibold))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(Color(white: 0.3))
                        }
                        
                        Spacer()
                        
                        // Send/Up Arrow
                        Button {} label: {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.blue)
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(.blue.quaternary))
                                .shadow(color: Color.blue.opacity(0.2), radius: 5, y: 2)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(bottomBarColor)
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.06), radius: 20, y: 10)
                // Adds a very subtle inner border
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                )
            }
            .padding(24)
            .frame(maxWidth: 600) // Keep it constrained like a prompt box
        }
        // Native haptic feedback
        .sensoryFeedback(.impact(flexibility: .rigid), trigger: isSketchExpanded)
    }
    
    private func toggleSketch() {
        // A joyful, springy transition for the layout shift
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            isSketchExpanded.toggle()
        }
    }
}


/// The top floating pill buttons
fileprivate struct TopTabButton: View {
    let icon: String
    let text: String
    
    var body: some View {
        Button {} label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(text)
                    .font(.system(size: 13, weight: .bold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
            )
            .foregroundColor(Color(white: 0.3))
        }
        .buttonStyle(.plain)
    }
}



struct DrawingLine: Identifiable {
    let id = UUID()
    var points: [CGPoint]
}


struct DrawingCanvas: View {
    @Binding var lines: [DrawingLine]
    @State private var currentLine = DrawingLine(points: [])
    
    var body: some View {
        Canvas { context, size in
            // Draw all completed lines
            for line in lines {
                var path = Path()
                path.addLines(line.points)
                context.stroke(path, with: .color(.black), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            }
            
            // Draw the line currently being actively sketched
            var activePath = Path()
            activePath.addLines(currentLine.points)
            context.stroke(activePath, with: .color(.black), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    currentLine.points.append(value.location)
                }
                .onEnded { _ in
                    lines.append(currentLine)
                    currentLine = DrawingLine(points: []) // Reset for the next stroke
                }
        )
    }
}

#Preview {
    DrawingPromptBox()
}
