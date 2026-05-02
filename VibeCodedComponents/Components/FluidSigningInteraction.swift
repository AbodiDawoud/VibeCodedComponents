//
//  FluidSigningInteraction.swift
//  VibeCodedComponents


import SwiftUI


struct FluidSigningInteraction: View {
    @State private var state: SignState = .idle
    @State private var lines: [DrawingLine] = []
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()

            if state == .idle {
                idleButton
                    .transition(.opacity.combined(with: .scale).animation(.linear(duration: 0.1)))
            } else if state == .signing {
                signingContent
                    .transition(.opacity.animation(.linear(duration: 0.05)))
            } else if state == .done {
                doneContent
                    .transition(.opacity.animation(.linear(duration: 0.05)))
            }
        }
        .animation(.spring(response: 0.8, dampingFraction: 0.6).speed(2), value: state)
        .sensoryFeedback(.impact(flexibility: .rigid), trigger: state)
        
    }
    
    
    var idleButton: some View {
        Button {
            state = .signing
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "signature")
                Text("Start Signing")

            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.black)
            .frame(width: 180, height: 50)
            .fixedSize()
            .background(Color(white: 0.95), in: .rect(cornerRadius: 25))
            .matchedGeometryEffect(id: "button", in: animation)
        }
        .buttonStyle(.plain)
    }
    
    
    var signingContent: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        lines.removeAll()
                    }
                    hapticFeedback(style: .light)
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(white: 0.6))
                }
                
                Spacer()
                
                Text("Sign")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(white: 0.6))
                
                Spacer()
                
                Button {
                    state = .idle
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                        .symbolRenderingMode(.hierarchical)
                }
            }
            .padding(24)
            
            
            DrawingCanvas(lines: $lines)
                .frame(height: 180)
                .padding(.horizontal, 24)
            
            // Footer
            Button {
                if lines.isEmpty {
                    state = .idle
                } else {
                    state = .done
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "signature")
                    Text("Finish Signing")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 180, height: 50)
                .background(Color(white: 0.95), in: .rect(cornerRadius: 25))
                .matchedGeometryEffect(id: "button", in: animation)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 24)
        }
        .frame(width: 320, height: 340)
        .background {
            RoundedRectangle(cornerRadius: 32)
                .stroke(
                    Color(white: 0.85),
                    style: StrokeStyle(lineWidth: 2, dash: [8, 8])
                )
                .fill(Color.white)
        }
    }
    
    
    var doneContent: some View {
        HStack(spacing: 12) {
            Button {
                state = .idle
                Sound.play(.success)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Signing Done")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 154, height: 50)
                .background(.black, in: .rect(cornerRadius: 25))
                .matchedGeometryEffect(id: "button", in: animation)
            }
            
            Button {
                state = .signing
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 50, height: 50)
                    .background(Color(white: 0.95), in: .circle)
            }
        }
        .buttonStyle(.plain)
    }
}


enum SignState {
    case idle
    case signing
    case done
}


#Preview {
    FluidSigningInteraction()
}
