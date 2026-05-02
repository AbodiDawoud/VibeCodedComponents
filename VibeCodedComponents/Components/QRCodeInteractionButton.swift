//
//  QRCodeInteractionButton.swift
//  VibeCodedComponents
    

import SwiftUI
import CoreImage.CIFilterBuiltins


struct QRCodeInteractionButton: View {
    @State private var isExpanded: Bool = false
    @State private var isCopied: Bool = false
    @Namespace private var animation
    @State private var qrCodeImage: UIImage?
    
    // MARK: - Colors matching the video
    let containerBackground = Color(white: 0.95) // Light gray-purple
    let elementsBackground = Color.white
    let primaryText = Color.black
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            
            if !isExpanded {
                // MARK: - Collapsed State
                Button {
                    toggleExpansion()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 18, weight: .bold))
                            
                            
                        Text("Show QR Code")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(primaryText)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    // The matched geometry background
                    .background(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(containerBackground)
                            .matchedGeometryEffect(id: "container", in: animation)
                            .transition(.opacity.animation(.linear(duration: 0.07)))
                    )
                }
                .transition(.opacity.animation(.linear(duration: 0.14)))
                
            } else {
                // MARK: - Expanded State
                VStack(spacing: 16) {
                    if let qrCodeImage {
                        Image(uiImage: qrCodeImage)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding()
                            .background(elementsBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            
                    }
                    
                    // Bottom Controls
                    HStack(spacing: 12) {
                        // Copy Link Button
                        Button(action: handleCopyLink) {
                            HStack(spacing: 6) {
                                Image(systemName: "link")
                                    .font(.system(size: 14, weight: .bold))
                                Text(isCopied ? "Copied Link" : "Copy Link")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .animation(.default, value: isCopied)
                            }
                            .foregroundColor(primaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background {
                                Capsule()
                                    .stroke(.black.quinary, lineWidth: 0.8)
                                    .fill(elementsBackground)
                            }
                        }
                        
                        // Close Button
                        Button(action: toggleExpansion) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(primaryText)
                                .frame(width: 50, height: 50)
                                .background {
                                    Circle()
                                        .stroke(.black.quinary, lineWidth: 0.8)
                                        .fill(elementsBackground)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(width: 280)
                .padding(.vertical, 16)
                // The matched geometry background
                .background(
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(containerBackground)
                        .matchedGeometryEffect(id: "container", in: animation)
                        .transition(.opacity.animation(.linear(duration: 0.07)))
                )
                .transition(.opacity.animation(.linear(duration: 0.14)))
            }
        }
        // Applying the spring animation globally to the layout changes
        .animation(.spring(duration: 0.2, bounce: 0.45), value: isExpanded)
        .onAppear(perform: createQRCodeImage)
    }
    
    // MARK: - Interaction Methods
    
    private func toggleExpansion() {
        isExpanded.toggle()
        
        // Reset copy state when closing
        if !isExpanded {
            isCopied = false
        }
        
        // Crisp haptic feedback for the morphing shape
        hapticFeedback(style: .rigid)
    }
    
    private func handleCopyLink() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isCopied = true
        }
        
        hapticFeedback(style: .light)
        
        // Optional: Reset back to "Copy Link" after a few seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isCopied = false
            }
        }
    }
    
    func createQRCodeImage() {
        if qrCodeImage != nil { return }
        let scale: CGFloat = 10.0
        let text = "Hello, World!"
        
        
        let filter = CIFilter.qrCodeGenerator()
        filter.message = text.data(using: .utf8)!
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        
        guard let outputImage = filter.outputImage?.transformed(by: transform),
              let contextImage = CIContext().createCGImage(outputImage, from: outputImage.extent)
        else { return }
        
        qrCodeImage = UIImage(cgImage: contextImage)
    }
}

#Preview {
    QRCodeInteractionButton()
}
