//
//  LiquidTimePicker.swift
//  VibeCodedComponents
    

import SwiftUI


struct LiquidTimePickerReplicaDemo: View {
    @State private var minutes: Int = 20

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                Spacer()

                LiquidTimePickerReplica(
                    value: $minutes,
                    visibleRange: 4 * 60,   // Note: We leave this here for API compatibility, but internal math now maps dynamically!
                    totalRange: 1...2*60,
                    step: 1
                )
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}

struct LiquidTimePickerReplica: View {
    @Binding var value: Int

    let visibleRange: Int
    let totalRange: ClosedRange<Int>
    let step: Int

    @State private var isExpanded = false
    @State private var sliderDragStartValue: Int?
    @State private var dragValue: Int? // FIX: Added to keep precise live sync
    @GestureState private var sliderTranslation: CGFloat = 0
    @State private var lastHapticStep: Int?


    private let compactButtonSize = CGSize(width: 72, height: 72)
    private let valuePillCompactWidth: CGFloat = 200
    private let valuePillExpandedWidth: CGFloat = 120
    private let compactSpacing: CGFloat = 18
    private let expandedSpacing: CGFloat = 14

    private let sliderHeight: CGFloat = 72
    private let sliderCornerRadius: CGFloat = 30
    private let sliderHorizontalInset: CGFloat = 18
    private let overscrollRange: CGFloat = 26

    var body: some View {
        GeometryReader { proxy in
            let totalWidth = proxy.size.width

            HStack(spacing: isExpanded ? expandedSpacing : compactSpacing) {
                if !isExpanded {
                    sideButton(systemName: "minus", action: decrement)
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                }

                valuePill
                    .frame(
                        width: isExpanded ? valuePillExpandedWidth : valuePillCompactWidth,
                        height: compactButtonSize.height
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .onTapGesture {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                            isExpanded.toggle()
                        }
                    }

                if isExpanded {
                    expandedSlider(
                        availableWidth: totalWidth - valuePillExpandedWidth - expandedSpacing
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                            isExpanded.toggle()
                        }
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    sideButton(systemName: "plus", action: increment)
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                }
            }
            .frame(width: totalWidth, height: 82, alignment: .leading)
            .animation(.spring(response: 0.38, dampingFraction: 0.86), value: isExpanded)
        }
        .sensoryFeedback(.impact(intensity: 0.8), trigger: isExpanded)
        .sensoryFeedback(.selection, trigger: value)
        .frame(height: 82)
    }

    // MARK: - Value pill

    private var valuePill: some View {
        let displayed = interactiveSliderValue
        let xStretch = isExpanded ? min(abs(sliderTranslation) / 700, 0.03) : 0
        let yShrink = xStretch * 0.42

        return ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.white)

            Text(formattedMinutes(displayed))
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundStyle(.black)
                .contentTransition(.numericText(value: Double(displayed)))
                .animation(.snappy(duration: 0.10), value: displayed)
        }
        .scaleEffect(x: 1 + xStretch, y: 1 - yShrink)
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(.black.opacity(0.02), lineWidth: 1)
        }
    }

    // MARK: - Expanded slider

    private func expandedSlider(availableWidth: CGFloat) -> some View {
        let width = max(140, availableWidth)

        return ZStack(alignment: .leading) {
            glassBackground
            sliderTickField(width: width)
            sliderFillOverlay(width: width)
            sliderInteractionLayer(width: width)
        }
        .frame(width: width, height: sliderHeight)
        .clipShape(RoundedRectangle(cornerRadius: sliderCornerRadius, style: .continuous))
    }

    private var glassBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: sliderCornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.08), Color.white.opacity(0.05)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: sliderCornerRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)

            RoundedRectangle(cornerRadius: sliderCornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.015), .clear],
                        startPoint: .top, endPoint: .bottom
                    )
                )
        }
    }

    private func sliderFillOverlay(width: CGFloat) -> some View {
        let fill = sliderFillWidth(for: width)

        return HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: sliderCornerRadius, style: .continuous)
                .fill(
//                    LinearGradient(
//                        colors: [Color.white.opacity(0.22), Color.white.opacity(0.14)],
//                        startPoint: .leading, endPoint: .trailing
//                    )
                    .white
                )
                .frame(width: max(0, fill))

            Spacer(minLength: 0)
        }
        .padding(.horizontal, sliderHorizontalInset)
        .animation(.spring(response: 0.22, dampingFraction: 0.92), value: interactiveSliderValue)
    }

    private func sliderTickField(width: CGFloat) -> some View {
        let activeTrackWidth = trackWidth(for: width)
        let tickSpacing: CGFloat = 12
        let tickCount = max(1, Int(activeTrackWidth / tickSpacing))

        return HStack(spacing: 0) {
            HStack(spacing: tickSpacing) {
                ForEach(0..<tickCount, id: \.self) { index in
                    Capsule()
                        // FIX: Pass actual tickCount to accurately calculate visual progress
                        .fill(tickColor(for: index, tickCount: tickCount))
                        .frame(width: 3, height: tickHeight(for: index))
                }
            }
            .padding(.horizontal, sliderHorizontalInset)

            //Spacer(minLength: trailingButtonArea)
        }
    }

    private func sliderInteractionLayer(width: CGFloat) -> some View {
        let activeWidth = trackWidth(for: width)

        return Rectangle()
            .fill(.clear)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($sliderTranslation) { gesture, state, _ in
                        state = gesture.translation.width
                    }
                    .onChanged { gesture in
                        if sliderDragStartValue == nil {
                            sliderDragStartValue = value
                        }

                        let live = rawSliderValue(
                            start: sliderDragStartValue ?? value,
                            translation: gesture.translation.width,
                            activeWidth: activeWidth
                        )

                        let stepped = clampedSteppedValue(live)
                        dragValue = stepped // FIX: Store the live sync value here!

                        if stepped != lastHapticStep, stepped != value {
                            lastHapticStep = stepped
                        }
                    }
                    .onEnded { gesture in
                        let start = sliderDragStartValue ?? value

                        let projected = rawSliderValue(
                            start: start,
                            // FIX: Use translation instead of predictedEndTranslation to prevent jumps on release
                            translation: gesture.translation.width,
                            activeWidth: activeWidth
                        )

                        let target = clampedSteppedValue(projected)

                        withAnimation(.interpolatingSpring(stiffness: 260, damping: 28)) {
                            value = target
                        }

                        sliderDragStartValue = nil
                        dragValue = nil
                        lastHapticStep = nil
                    }
            )
    }

    // MARK: - Buttons

    private func sideButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle().fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.09), Color.white.opacity(0.05)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                Circle().strokeBorder(.white.opacity(0.08), lineWidth: 1)
                Image(systemName: systemName)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: compactButtonSize.width, height: compactButtonSize.height)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tick styling

    private func tickHeight(for index: Int) -> CGFloat {
        switch index % 4 {
        case 0: return 26
        case 1: return 12
        case 2: return 10
        default: return 12
        }
    }

    // FIX: tickCount is now passed in to calculate correct filling ratio
    private func tickColor(for index: Int, tickCount: Int) -> Color {
        let normalized = currentProgress
        let activeTickEstimate = Int(CGFloat(tickCount) * normalized)

        let tickGroupBias = index % 4 == 0 ? 0 : 1
        let isFilled = index <= activeTickEstimate + tickGroupBias

        if isFilled {
            return Color.white.opacity(index % 4 == 0 ? 0.95 : 0.72)
        } else {
            return Color.white.opacity(index % 4 == 0 ? 0.35 : 0.18)
        }
    }

    // MARK: - Value mapping

    private var interactiveSliderValue: Int {
        // FIX: Replaced complex, hardcoded-width re-computation with clean state sync
        return dragValue ?? value
    }

    private var currentProgress: CGFloat {
        let current = CGFloat(interactiveSliderValue - totalRange.lowerBound)
        let span = CGFloat(max(1, totalRange.upperBound - totalRange.lowerBound))
        return min(max(current / span, 0), 1)
    }

    private func rawSliderValue(start: Int, translation: CGFloat, activeWidth: CGFloat) -> Int {
        // FIX: Base capacity on totalRange rather than visibleRange so filling stays aligned with finger
        let span = totalRange.upperBound - totalRange.lowerBound
        let capacity = max(step, span)
        let pointsPerMinute = activeWidth / CGFloat(capacity)

        let delta = translation / max(pointsPerMinute, 0.001)
        let raw = CGFloat(start) + delta

        let minValue = CGFloat(totalRange.lowerBound)
        let maxValue = CGFloat(totalRange.upperBound)

        let adjusted: CGFloat
        if raw < minValue {
            let overflow = minValue - raw
            adjusted = minValue - rubberBand(overflow)
        } else if raw > maxValue {
            let overflow = raw - maxValue
            adjusted = maxValue + rubberBand(overflow)
        } else {
            adjusted = raw
        }

        return Int(adjusted.rounded())
    }

    private func rubberBand(_ overflow: CGFloat) -> CGFloat {
        let c: CGFloat = 0.16
        return (1.0 - (1.0 / ((overflow * c / overscrollRange) + 1.0))) * overscrollRange
    }

    private func sliderFillWidth(for width: CGFloat) -> CGFloat {
        let track = trackWidth(for: width)
        return track * currentProgress
    }

    private func trackWidth(for width: CGFloat) -> CGFloat {
        max(80, width - sliderHorizontalInset * 2)
    }

    private func clampedSteppedValue(_ raw: Int) -> Int {
        let stepped = snapped(raw, step: step)
        return min(max(stepped, totalRange.lowerBound), totalRange.upperBound)
    }

    private func snapped(_ value: Int, step: Int) -> Int {
        guard step > 1 else { return value }
        let lower = (value / step) * step
        let upper = lower + step
        return (value - lower) < (upper - value) ? lower : upper
    }

    // MARK: - Actions & Formatting

    private func increment() {
        withAnimation(.interpolatingSpring(stiffness: 320, damping: 24)) {
            value = min(value + step, totalRange.upperBound)
        }
    }

    private func decrement() {
        withAnimation(.interpolatingSpring(stiffness: 320, damping: 24)) {
            value = max(value - step, totalRange.lowerBound)
        }
    }

    private func formattedMinutes(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        }

        let h = minutes / 60
        let m = minutes % 60

        if m == 0 { return "\(h)h" }
        return "\(h)h \(m)m"
    }
}

#Preview {
    LiquidTimePickerReplicaDemo()

}
