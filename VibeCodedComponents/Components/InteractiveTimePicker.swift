//
//  InteractiveTimePicker.swift
//  VibeCodedComponents
    

import SwiftUI


struct InteractiveTimePicker: View {
    @State private var selectedTimeId: UUID?
    
    // Computed property to safely get the active time for the clock
    private var activeTime: TimeOption {
        times.first(where: { $0.id == selectedTimeId }) ?? times[34] // 34 is 17:00 / 5:00 PM
    }
    
    var body: some View {
        ZStack {
            // Dark app background
            Color.primary.opacity(0.05).ignoresSafeArea()
            
            // MARK: - Picker Container
            HStack(spacing: 30) {
                
                // 1. The Analog Clock Preview
                AnalogClockView(hour: activeTime.hour, minute: activeTime.minute)
                
                // 2. The Custom Snapping Scroll Wheel
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(times) { time in
                            let isSelected = time.id == selectedTimeId
                            
                            Text(time.display)
                                .font(.system(size: isSelected ? 18 : 16, weight: isSelected ? .semibold : .medium))
                                .foregroundColor(isSelected ? .white : Color(white: 0.35))
                                .frame(height: 24)
                                // The spring animation ensures the scale/color pops smoothly when snapping
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                        }
                    }
                    // Tells the ScrollView that these items are the snap targets
                    .scrollTargetLayout()
                }
                // Snaps nicely to each text element
                .scrollTargetBehavior(.viewAligned)
                // Binds the centered item to our state
                .scrollPosition(id: $selectedTimeId)
                // Adds padding so the first and last items can reach the center
                .safeAreaPadding(.vertical, 60)
                .frame(width: 100, height: 140)
                // The Fading Edges Mask
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .white, location: 0.3),
                            .init(color: .white, location: 0.7),
                            .init(color: .clear, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(white: 0.1))
                    // Subtle border matching the video's premium feel
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(white: 0.15), lineWidth: 1)
                    )
            )
        }
        .onAppear {
            // Set initial state on load
            if selectedTimeId == nil {
                selectedTimeId = times[34].id // 5:00 PM
            }
        }
        .sensoryFeedback(.selection, trigger: selectedTimeId)
    }
    
    private let times: [TimeOption] = {
        var options: [TimeOption] = []
        for h in 0..<24 {
            for m in [0, 30] {
                let displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h)
                let amPm = h < 12 ? "am" : "pm"
                let minStr = m == 0 ? "00" : "30"
                options.append(TimeOption(display: "\(displayHour):\(minStr) \(amPm)", hour: h, minute: m))
            }
        }
        return options
    }()
}


struct AnalogClockView: View {
    var hour: Int
    var minute: Int
    
    // Calculate the total continuous minutes to ensure forward rotation
    private var totalMinutes: Int {
        (hour * 60) + minute
    }
    
    var body: some View {
        ZStack {
            // Clock Face Background
            Circle()
                .fill(Color(white: 0.15))
                .frame(width: 80, height: 80)
            
            // 12-Hour Tick Marks
            ForEach(0..<12) { i in
                Rectangle()
                    .fill(Color(white: 0.35))
                    .frame(width: 2, height: 6)
                    .offset(y: -34)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
            
            // Hour Hand (White, shorter, thicker)
            Capsule()
                .fill(Color.white)
                .frame(width: 4, height: 22)
                .offset(y: -9)
                // 360° / 720 mins (12 hours) = 0.5° per minute
                .rotationEffect(.degrees(Double(totalMinutes) * 0.5))
            
            // Minute Hand (Gray, longer, thinner)
            Capsule()
                .fill(Color(white: 0.6))
                .frame(width: 2.5, height: 32)
                .offset(y: -14)
                // 360° / 60 mins = 6° per minute
                .rotationEffect(.degrees(Double(totalMinutes) * 6.0))
            
            // Center Dot
            Circle()
                .fill(Color.white)
                .frame(width: 6, height: 6)
        }
        // Animate based on the continuous totalMinutes value instead of individual hour/minute changes
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: totalMinutes)
    }
}


#Preview {
    InteractiveTimePicker()
}


fileprivate struct TimeOption: Identifiable, Hashable {
    let id = UUID()
    let display: String
    let hour: Int
    let minute: Int
    
    var timeId: String {
        "\(hour)_\(minute)"
    }
}
