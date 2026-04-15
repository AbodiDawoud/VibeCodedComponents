//
//  BankWidgetView.swift
//  VibeCodedComponents

import SwiftUI


struct BankWidgetView: View {
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top White Card
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Checking")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    
                    Spacer()
                    
                    Text("•••• 3762")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
                
                HStack(alignment: .bottom, spacing: 12) {
                    Text("$1 480.24")
                        .font(.system(size: 42, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                        .padding(.bottom, 6)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .padding(.bottom, 32)
            .background(Color(UIColor.systemBackground)) // Pure white in light mode
            .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
            // Optional: Adds a very faint shadow to separate the white card from the grey background
            .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
            
            // MARK: - Pagination Indicator
            HStack(spacing: 6) {
                Capsule()
                    .fill(Color(UIColor.tertiaryLabel))
                    .frame(width: 8, height: 4)
                
                Capsule()
                    .fill(Color(UIColor.secondaryLabel))
                    .frame(width: 20, height: 4)
                
                Capsule()
                    .fill(Color(UIColor.tertiaryLabel))
                    .frame(width: 8, height: 4)
            }
            .padding(.top, 16)
            
            // MARK: - Action Buttons
            HStack(spacing: 0) {
                ActionButton(icon: "dollarsign", title: "Pay")
                Spacer()
                ActionButton(icon: "plus", title: "Add money")
                Spacer()
                ActionButton(icon: "arrow.right", title: "Transfer")
            }
            .padding(.horizontal, 36)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        // Outer Container Background
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
        .padding(20) // Outer padding for the screen
    }
}


fileprivate struct ActionButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(UIColor.systemGray2)) // Dark grey background
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(UIColor.darkGray))
        }
    }
}


#Preview {
    ZStack {
        // Light grey screen background to make the widget pop
        Color(UIColor.systemGroupedBackground).ignoresSafeArea()
        BankWidgetView()
    }
}
