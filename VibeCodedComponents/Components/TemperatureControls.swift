//
//  TemperatureControls.swift
//  VibeCodedComponents
    

import SwiftUI

struct TemperatureControlsView: View {
    // Made optional to work perfectly with iOS 17+ ScrollView position binding
    @State private var selectedTemperaturePicker: Int? = 20
    
    // Right: The current temperature for the stepper control.
    @State private var currentTemperatureStepper: Int = 21
    
    let temperatureRangePicker = Array(16...30)
    let rangeStepper: ClosedRange<Int> = 16...22
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        ZStack {
            // Overall background
            Color.primary.opacity(0.08).edgesIgnoringSafeArea(.all)
            
            HStack(spacing: 40) {
                leftPicker
                rightStepper
            }
            .preferredColorScheme(.dark)
        }
        // Haptic Feedback
        .sensoryFeedback(.selection, trigger: selectedTemperaturePicker)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: currentTemperatureStepper)
    }
    
    private var leftPicker: some View {
        VStack(alignment: .center) {
            GeometryReader { geo in
                let itemHeight: CGFloat = 52
                let visibleHeight = geo.size.height
                // Calculate exactly how much padding we need so the first/last item can reach the center
                let verticalPadding = (visibleHeight - itemHeight) / 2
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(temperatureRangePicker, id: \.self) { temp in
                            Text("\(temp)°")
                                .font(.system(
                                    size: temp == selectedTemperaturePicker ? 28 : 22,
                                    weight: temp == selectedTemperaturePicker ? .bold : .medium
                                ))
                                .frame(maxWidth: .infinity)
                                .frame(height: itemHeight)
                                .foregroundColor(temp == selectedTemperaturePicker ? .white : .gray.opacity(0.6))
                                .scaleEffect(temp == selectedTemperaturePicker ? 1.05 : 0.9)
                                // Snappy spring animation for the text scaling and color change
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedTemperaturePicker)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        selectedTemperaturePicker = temp
                                    }
                                }
                        }
                    }
                    // 1. Tell the ScrollView that these items are the targets to snap to
                    .scrollTargetLayout()
                }
                // 2. Add padding so the list can scroll fully to the ends
                .safeAreaPadding(.vertical, verticalPadding)
                // 3. Bind the scroll position directly to our State variable
                .scrollPosition(id: $selectedTemperaturePicker, anchor: .center)
                // 4. Force the scrollview to snap cleanly to the views inside the layout
                .scrollTargetBehavior(.viewAligned)
                .mask(
                    LinearGradient(gradient: Gradient(stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.3),
                        .init(color: .black, location: 0.7),
                        .init(color: .clear, location: 1)
                    ]), startPoint: .top, endPoint: .bottom)
                )
            }
            .frame(width: 80, height: 260)
            .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.13))
        )
    }
    
    private var rightStepper: some View {
        VStack(spacing: 58) {
            Spacer()
            
            // Decrement Button (Up Arrow)
            Button {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    currentTemperatureStepper = min(rangeStepper.upperBound, currentTemperatureStepper - 1)
                }
            } label: {
                Image(systemName: "chevron.up")
                    .font(.system(size: 22, weight: .semibold))
                    // Visually dim the button when we reach the maximum temp
                    .foregroundColor(currentTemperatureStepper == rangeStepper.lowerBound ? .gray.opacity(0.25) : .gray)
            }
            .disabled(currentTemperatureStepper == rangeStepper.lowerBound)
            
            
            // Current Temperature Display
            Text("\(currentTemperatureStepper)°")
                .font(.system(size: 25, weight: .semibold, design: .rounded))
                .contentTransition(.numericText())
                .foregroundColor(.white)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentTemperatureStepper)
            
            
            // Increment Button (Down Arrow)
            Button {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    currentTemperatureStepper = max(rangeStepper.lowerBound, currentTemperatureStepper + 1)
                }
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 22, weight: .semibold))
                     // Visually dim the button when we reach the minimum temp
                    .foregroundColor(currentTemperatureStepper == rangeStepper.upperBound ? .gray.opacity(0.25) : .gray)
            }
            .disabled(currentTemperatureStepper == rangeStepper.upperBound)
            
            Spacer()
        }
        .frame(width: 80, height: 270)
        .background(Color(red: 0.12, green: 0.12, blue: 0.13), in: .rect(cornerRadius: 28))
    }
}

#Preview {
    TemperatureControlsView()
}
