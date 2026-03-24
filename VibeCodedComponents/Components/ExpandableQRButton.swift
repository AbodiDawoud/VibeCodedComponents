//
//  ExpandableQRButton.swift
//  VibeCodedComponents


import SwiftUI
import CoreImage.CIFilterBuiltins


struct ExpandableQRButton: View {
    @State private var isExpanded = false
    @State private var qrCodeImage: UIImage?
    
    @Namespace private var animation
    @Environment(\.colorScheme) private var scheme
    
    
    var body: some View {
        ZStack {
            Color.primary.opacity(0.05).ignoresSafeArea()
            
            VStack {
                if isExpanded {
                    expandedCard
                } else {
                    collapsedButton
                }
            }
            // 2. A snappy spring animation makes it feel responsive
            .animation(.spring(response: 0.5, dampingFraction: 0.75).speed(2), value: isExpanded)
        }
        .onAppear(perform: createQRCodeImage)
    }
    
    
    // MARK: - Collapsed State
    var collapsedButton: some View {
        Button {
            isExpanded.toggle()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "qrcode")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 21, height: 21)
                    .matchedGeometryEffect(id: "qrIcon", in: animation)
                
                Divider().frame(height: 22)
                
                Text("Scan to pay")
                    .font(.system(size: 16, weight: .medium))
                    // Match ID for the text
                    .fixedSize()
                    .matchedGeometryEffect(id: "titleText", in: animation, properties: .position)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color(white: scheme == .light ? 1 : 0.09))
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                    .matchedGeometryEffect(id: "cardBackground", in: animation)
            )
        }
        .buttonStyle(.plain)
    }
    
    
    // MARK: - Expanded State
    var expandedCard: some View {
        VStack(spacing: 0) {
            
            // The Main Card
            VStack(spacing: 22) {
                if let qrCodeImage {
                    Image(uiImage: qrCodeImage)
                        .resizable()
                        .scaledToFit()
//                        .clipShape(.rect(cornerRadius: 25))
                        .matchedGeometryEffect(id: "qrIcon", in: animation)
                        .frame(width: 250, height: 250)
                }
                
                VStack(spacing: 9) {
                    Text("Scan to download")
                        .fixedSize()
                        .matchedGeometryEffect(id: "titleText", in: animation, properties: .position)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "apple.logo")
                            .transition(.opacity.animation(.linear(duration: 0.01)))

                        Image(systemName: "play.fill")
                            .transition(.opacity.animation(.linear(duration: 0.01)))

                    }
                }
                .font(.subheadline.weight(.medium))
                .fontDesign(.rounded)
                .foregroundStyle(.gray.secondary)
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 48)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(white: scheme == .light ? 1 : 0.09))
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 25)
                    .matchedGeometryEffect(id: "cardBackground", in: animation)
            )
            
            // The Close Button
            Button {
                isExpanded.toggle()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .padding(12)
                    .background(Color(white: scheme == .light ? 1 : 0.11), in: .circle)
                    .transition(.opacity.animation(.linear(duration: 0.01)))
            }
            .buttonStyle(.plain)
            .padding(.top, 24)
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
    ExpandableQRButton()
}
