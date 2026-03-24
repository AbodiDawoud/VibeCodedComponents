//
//  PremiumTimerWidget.swift
//  VibeCodedComponents
    

import SwiftUI

struct PremiumTimerWidget: View {
    @State private var selectedMinutes: Int = 20
    @State private var timeRemaining: TimeInterval = 20 * 60
    @State private var isRunning: Bool = false
    @State private var timer: Timer?

    @State private var pulseRing: Bool = false
    @State private var bumpTimerText: Bool = false

    let controlTint = Color(#colorLiteral(red: 0.04242423922, green: 0.8637657762, blue: 0.9757402539, alpha: 1))

    private let playfulSpring = Animation.spring(response: 0.38, dampingFraction: 0.72)
    private let softSpring = Animation.spring(response: 0.45, dampingFraction: 0.82)

    var progress: CGFloat {
        let total = TimeInterval(selectedMinutes * 60)
        guard total > 0 else { return 0 }
        return CGFloat(timeRemaining / total)
    }

    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                PresetButton(minutes: 1, selected: $selectedMinutes) {
                    setTimer(to: 1)
                }
                PresetButton(minutes: 10, selected: $selectedMinutes) {
                    setTimer(to: 10)
                }
                PresetButton(minutes: 20, selected: $selectedMinutes) {
                    setTimer(to: 20)
                }
            }

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Timer")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(white: 0.7))

                    Spacer()

                    Text(formattedTime)
                        .font(.system(size: 54, weight: .medium).monospacedDigit())
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                        .scaleEffect(bumpTimerText ? 1.04 : 1.0)
                        .animation(softSpring, value: bumpTimerText)

                    Spacer()

                    Button {
                        if !isRunning { return }
                        stopTimer(reset: true)
                        Sound.play(.buttonTap)
                    } label: {
                        Text("Stop")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 36)
                            .background(Color(white: 0.15), in: .rect(cornerRadius: 15))
                    }
                    .buttonStyle(.plain)
                    .padding(.top)
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 28)
                .frame(maxWidth: .infinity, alignment: .leading)

                ZStack {
                    RoundedRectangle(cornerRadius: 36)
                        .fill(controlTint.quinary)
                        .scaleEffect(pulseRing ? 1.03 : 1.0)
                        .animation(playfulSpring, value: pulseRing)

                    ZStack {
                        Circle()
                            .fill(controlTint.quaternary)

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(controlTint, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .scaleEffect(pulseRing ? 1.015 : 1.0)
                            .animation(.linear(duration: 1.0), value: progress)
                            .animation(playfulSpring, value: pulseRing)

                        Button {
                            toggleRunning()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(white: 0.1))
                                    .frame(width: 68, height: 68)
                                    .padding(14)
                                    .scaleEffect(isRunning ? 1.0 : 0.94)

                                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .contentTransition(.symbolEffect(.replace.downUp))
                                    .symbolEffect(.bounce, value: isRunning)
                            }
                        }
                        .buttonStyle(.plain)
                        .animation(playfulSpring, value: isRunning)
                    }
                    .padding(28)
                }
                .aspectRatio(1, contentMode: .fit)
                .padding(8)
            }
            .frame(height: 190)
            .background(Color(white: 0.09), in: .rect(cornerRadius: 44))
            .scaleEffect(isRunning ? 1.0 : 0.985)
            .animation(softSpring, value: isRunning)
            .padding(.horizontal, 21)
        }
        .sensoryFeedback(.impact(flexibility: .solid), trigger: isRunning)
        .sensoryFeedback(.impact(flexibility: .rigid), trigger: selectedMinutes)
        .onDisappear {
            invalidateTimer()
        }
    }

    private func toggleRunning() {
        withAnimation(playfulSpring) {
            isRunning.toggle()
            pulseRing.toggle()
            bumpTimerText.toggle()
        }

        if isRunning {
            startTimer()
        } else {
            invalidateTimer()
        }
    }

    private func setTimer(to minutes: Int) {
        withAnimation(playfulSpring) {
            selectedMinutes = minutes
            timeRemaining = TimeInterval(minutes * 60)
            isRunning = true
            pulseRing.toggle()
            bumpTimerText.toggle()
        }

        startTimer()
    }

    private func startTimer() {
        invalidateTimer()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard isRunning else { return }

            if timeRemaining > 1 {
                timeRemaining -= 1
            } else {
                timeRemaining = 0
                isRunning = false
                invalidateTimer()
                Sound.play(.success)

                withAnimation(playfulSpring) {
                    pulseRing.toggle()
                    bumpTimerText.toggle()
                }
            }
        }
    }

    private func stopTimer(reset: Bool) {
        withAnimation(playfulSpring) {
            isRunning = false
            if reset {
                timeRemaining = TimeInterval(selectedMinutes * 60)
            }
            pulseRing.toggle()
            bumpTimerText.toggle()
        }

        invalidateTimer()
    }

    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}

fileprivate struct PresetButton: View {
    let minutes: Int
    @Binding var selected: Int
    let action: () -> Void

    @Environment(\.colorScheme) private var scheme
    @State private var isPressed = false

    var isSelected: Bool { selected == minutes }

    let cyanColor = Color(#colorLiteral(red: 0.04242423922, green: 0.8637657762, blue: 0.9757402539, alpha: 1))

    var body: some View {
        Button(action: action) {
            Text("\(minutes) mins")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .teal : .primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    isSelected
                    ? cyanColor.opacity(0.2)
                    : Color(white: scheme == .light ? 0.95 : 0.09),
                    in: .capsule
                )
                .scaleEffect(isPressed ? 0.96 : (isSelected ? 1.04 : 1.0))
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed { isPressed = true }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .animation(.spring(response: 0.28, dampingFraction: 0.68), value: isSelected)
        .animation(.spring(response: 0.2, dampingFraction: 0.75), value: isPressed)
    }
}
