import SwiftUI
import CoreHaptics

// MARK: - Models
struct FanMenuItem {
    let label: String
    let icon: String
}

// MARK: - Haptics
final class HapticManager {
    static let shared = HapticManager()

    private var engine: CHHapticEngine?

    private init() {
        prepareEngine()
    }

    private func prepareEngine() {
        let supports = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        if !supports { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            // If the engine can't be created, we silently ignore haptics
        }
    }

    func trigger(_ style: HapticStyle) {
        let supports = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        if !supports { return }

        let intensity: Float
        switch style {
        case .light: intensity = 0.25
        case .soft: intensity = 0.12
        case .medium: intensity = 0.5
        }
        let sharpness: Float = 0.3

        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0
        )
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try engine?.start()
            try player?.start(atTime: 0)
        } catch {
            // Ignore failures gracefully
        }
    }

    enum HapticStyle { case light, soft, medium }
}

// MARK: - Views
struct PillItemView: View {
    let item: FanMenuItem
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: item.icon)
                .font(.system(size: 18))
                .foregroundColor(Color.secondary)
            Text(item.label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 14)
        .frame(height: 40)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

struct RippleView: View {
    @Binding var active: Bool
    @State private var scale: CGFloat = 0.4
    @State private var opacity: Double = 0.4

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 60, height: 60)
            .scaleEffect(active ? 2.0 : 0.6)
            .opacity(active ? 0.0 : 0.25)
            .onChange(of: active) { opened in
                if opened {
                    withAnimation(Animation.easeOut(duration: 0.6)) {
                        scale = 2.0
                        opacity = 0.0
                    }
                } else {
                    scale = 0.4
                    opacity = 0.25
                }
            }
    }
}

struct FanMenuView: View {
    @State private var isExpanded = false

    private let items: [FanMenuItem] = [
        FanMenuItem(label: "Image", icon: "photo.on.rectangle.angled"),
        FanMenuItem(label: "Video", icon: "film.stack"),
        FanMenuItem(label: "Music", icon: "music.note"),
        FanMenuItem(label: "Document", icon: "doc.text"),
        FanMenuItem(label: "Learning", icon: "book.closed"),
    ]

    var body: some View {
        ZStack(alignment: .center) {
            // Subtle overlay when expanded
            if isExpanded {
                Color.black.opacity(0.02)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeMenu()
                    }
            }

            // Pill items (fan)
            ForEach(items.indices, id: \.self) { idx in
                PillItemView(item: items[idx])
                    .offset(x: itemOffsetX(for: idx), y: itemOffsetY(for: idx))
                    .opacity(isExpanded ? 1 : 0)
                    .scaleEffect(isExpanded ? 1.0 : 0.4)
                    .animation(openAnimation(for: idx), value: isExpanded)
                    .onTapGesture {
                        itemTapped(items[idx])
                    }
            }

            // Trigger button
            Button(action: {
                toggleMenu()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 56, height: 56)
                        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
                    // Morphing + -> ×
                    ZStack {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.primary)
                            .opacity(isExpanded ? 0.0 : 1.0)
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.primary)
                            .opacity(isExpanded ? 1.0 : 0.0)
                    }
                    .rotationEffect(.degrees(isExpanded ? 45 : 0))
                }
            }
            .buttonStyle(.plain)
            .padding(.leading, 20)
            .padding(.bottom, 20)

            // Ripple on open
            RippleView(active: $isExpanded)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            // Prepare haptics lazily
            _ = HapticManager.shared
        }
    }

    // MARK: - Helpers
    private func itemOffsetX(for idx: Int) -> CGFloat {
        isExpanded ? -14.0 * CGFloat(idx) : 0
    }
    private func itemOffsetY(for idx: Int) -> CGFloat {
        isExpanded ? -60.0 * CGFloat(idx) : 0
    }
    private func openAnimation(for idx: Int) -> Animation {
        let delay = Double(idx) * 0.04
        return Animation.spring(response: 0.42, dampingFraction: 0.68).delay(delay)
    }
    private func toggleMenu() {
        isExpanded.toggle()
        // Haptics on open/close
        if isExpanded {
            HapticManager.shared.trigger(.medium)
        } else {
            HapticManager.shared.trigger(.soft)
        }
    }
    private func closeMenu() {
        if isExpanded {
            // Closing animation with reverse order naturally via state
            withAnimation(Animation.spring(response: 0.32, dampingFraction: 0.8)) {
                isExpanded = false
            }
            HapticManager.shared.trigger(.soft)
        }
    }
    private func itemTapped(_ item: FanMenuItem) {
        print("Selected: \(item.label)")
        HapticManager.shared.trigger(.light)
        closeMenu()
    }
}

// MARK: - Preview
struct FanMenuView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            FanMenuView()
        }
    }
}
