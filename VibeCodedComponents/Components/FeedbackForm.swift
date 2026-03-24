//
//  FeedbackForm.swift
//  VibeCodedComponents
    

import SwiftUI

struct FeedbackFormView: View {
    @State private var feedbackText: String = ""
    @State private var isHelpful: Bool = true // true = Helpful, false = Not helpful, nil = none selected
    @Namespace private var animation
    @Environment(\.dismiss) private var dismiss
    private let feedbackPlaceholder: String = "Solid answer, but could use more\nimplementation steps"
    
    var body: some View {
        ZStack {
            // Overall background
            Color.primary.opacity(0.05).edgesIgnoringSafeArea(.all)
            
            
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text("Help us Improve")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button {
                        Sound.play(.buttonTap)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                            .frame(width: 22, height: 22)
                            .background(Color(red: 0.93, green: 0.935, blue: 0.93))
                            .clipShape(Circle())
                    }
                }
                
                
                HStack(spacing: 16) {
                    // Helpful Button
                    Button(action: toggleIsHelpful) {
                        HStack(spacing: 6) {
                            Image(systemName: "hand.thumbsup.fill")
                                .fontWeight(.semibold)
                            
                            Text("Helpful")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(isHelpful == true ? .blue : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            ZStack {
                                // 3. Conditionally render the background and link it via matchedGeometryEffect
                                if isHelpful == true {
                                    Capsule()
                                        .fill(Color(red: 0.89, green: 0.93, blue: 0.99))
                                        .matchedGeometryEffect(id: "activeBackground", in: animation)
                                    
                                    Capsule()
                                        .stroke(Color(red: 0.89, green: 0.93, blue: 0.99).opacity(0.2), lineWidth: 0.8)
                                }
                            }
                        )
                    }
                    
                    // Not Helpful Button
                    Button(action: toggleIsHelpful) {
                        HStack(spacing: 6) {
                            Image(systemName: "hand.thumbsdown.fill")
                                .fontWeight(.semibold)
                            
                            Text("Not helpful")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(isHelpful == false ? .blue : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            ZStack {
                                if isHelpful == false {
                                    Capsule()
                                        .fill(Color(red: 0.89, green: 0.93, blue: 0.99))
                                        .matchedGeometryEffect(id: "activeBackground", in: animation)
                                    Capsule()
                                        .stroke(Color(red: 0.89, green: 0.93, blue: 0.99).opacity(0.2), lineWidth: 0.8)
                                }
                            }
                        )
                    }
                }
                
                // Text Area
                TextField(feedbackPlaceholder, text: $feedbackText, axis: .vertical)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.black)
                    .padding(16)
                    .frame(minHeight: 80, alignment: .topLeading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                            // Subtle inner border matching the image
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            )
                    )
                
                // Bottom Action Buttons
                HStack(spacing: 12) {
                    Button {
                        Sound.play(.buttonTap)
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.95, green: 0.95, blue: 0.95), in: .capsule)
                    }
                    
                    Button {
                        Sound.play(.success)
                    } label: {
                        Text("Submit")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 1.0, green: 0.85, blue: 0.15), in: .capsule) // Bright Yellow
                    }
                }
            }
            .sensoryFeedback(.impact, trigger: isHelpful)
            .padding(24)
            .background(Color.white)
            .cornerRadius(24)
            .padding(20) // Outer margin
        }
        .navigationBarBackButtonHidden()
    }
    
    func toggleIsHelpful() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isHelpful.toggle()
        }
    }
}

#Preview {
    FeedbackFormView()
}
