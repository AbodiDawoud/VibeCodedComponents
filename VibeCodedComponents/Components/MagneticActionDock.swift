import SwiftUI

private struct MagneticDockAction {
    let title: String
    let icon: String
    let color: Color
}

struct MagneticActionDockView: View {
    @State private var isOpen = false
    @State private var selectedAction = "Save"
    @State private var activeIndex: Int?
    @State private var dragLocation: CGPoint?
    @State private var gestureStartedOpen = false
    @Environment(\.colorScheme) private var scheme

    private let actions: [MagneticDockAction] = [
        MagneticDockAction(title: "Share", icon: "square.and.arrow.up", color: .blue),
        MagneticDockAction(title: "Pin", icon: "pin.fill", color: .orange),
        MagneticDockAction(title: "Save", icon: "bookmark.fill", color: .green),
        MagneticDockAction(title: "Archive", icon: "archivebox.fill", color: .purple)
    ]

    var body: some View {
        GeometryReader { proxy in
            let anchor = CGPoint(x: proxy.size.width / 2, y: proxy.size.height - 150)
            let centers = actions.indices.map { actionCenter(for: $0, anchor: anchor) }

            ZStack {
                background

                VStack(spacing: 8) {
                    Text(selectedAction)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())

                    Text("Magnetic dock")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 112)

                if isOpen {
                    Color.primary.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture(perform: closeDock)
                }

                ForEach(actions.indices, id: \.self) { index in
                    let action = actions[index]
                    let isActive = activeIndex == index
                    let magneticOffset = magneticOffset(for: centers[index])

                    MagneticActionBubble(action: action, isActive: isActive)
                        .position(isOpen ? centers[index] : anchor)
                        .offset(magneticOffset)
                        .opacity(isOpen ? 1 : 0)
                        .scaleEffect(isOpen ? (isActive ? 1.18 : 1) : 0.45)
                        .animation(.spring(response: 0.42, dampingFraction: 0.68).delay(Double(index) * 0.035), value: isOpen)
                        .animation(.interactiveSpring(response: 0.18, dampingFraction: 0.76), value: activeIndex)
                        .onTapGesture {
                            choose(index)
                        }
                }

                if isOpen, let dragLocation {
                    Path { path in
                        path.move(to: anchor)
                        path.addLine(to: dragLocation)
                    }
                    .stroke(.primary.opacity(0.1), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 7]))
                    .allowsHitTesting(false)
                }

                MagneticDockHandle(isOpen: isOpen, selectedIcon: selectedIcon)
                    .position(anchor)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged { value in
                                if dragLocation == nil {
                                    gestureStartedOpen = isOpen
                                }

                                if !isOpen {
                                    openDock()
                                }

                                dragLocation = value.location
                                activeIndex = nearestAction(to: value.location, centers: centers)
                            }
                            .onEnded { value in
                                let didTap = hypot(value.translation.width, value.translation.height) < 8

                                if didTap {
                                    if gestureStartedOpen {
                                        closeDock()
                                    }
                                } else if let activeIndex {
                                    choose(activeIndex)
                                } else {
                                    closeDock()
                                }

                                dragLocation = nil
                                gestureStartedOpen = false
                            }
                    )
                    .zIndex(3)
            }
        }
    }

    private var selectedIcon: String {
        actions.first(where: { $0.title == selectedAction })?.icon ?? "sparkles"
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(white: scheme == .light ? 0.99 : 0.05),
                Color(white: scheme == .light ? 0.91 : 0.01)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private func actionCenter(for index: Int, anchor: CGPoint) -> CGPoint {
        let offsets = [
            CGSize(width: -126, height: -120),
            CGSize(width: -44, height: -172),
            CGSize(width: 44, height: -172),
            CGSize(width: 126, height: -120)
        ]
        let offset = offsets[index]
        return CGPoint(x: anchor.x + offset.width, y: anchor.y + offset.height)
    }

    private func magneticOffset(for center: CGPoint) -> CGSize {
        guard let dragLocation else { return .zero }

        let dx = dragLocation.x - center.x
        let dy = dragLocation.y - center.y
        let distance = max(1, hypot(dx, dy))
        let attraction = max(0, 1 - distance / 120)
        let pull = attraction * 18

        return CGSize(width: dx / distance * pull, height: dy / distance * pull)
    }

    private func nearestAction(to location: CGPoint, centers: [CGPoint]) -> Int? {
        let distances = centers.enumerated().map { index, center in
            (index: index, distance: hypot(location.x - center.x, location.y - center.y))
        }

        guard let nearest = distances.min(by: { $0.distance < $1.distance }), nearest.distance < 78 else {
            return nil
        }

        return nearest.index
    }

    private func openDock() {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.7)) {
            isOpen = true
        }
        Sound.play(.startup)
        hapticFeedback(style: .medium)
    }

    private func closeDock() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
            isOpen = false
            activeIndex = nil
            dragLocation = nil
        }
        hapticFeedback(style: .soft)
    }

    private func choose(_ index: Int) {
        selectedAction = actions[index].title
        Sound.play(.success)
        hapticFeedback(style: .rigid)
        closeDock()
    }
}

private struct MagneticActionBubble: View {
    let action: MagneticDockAction
    let isActive: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: action.icon)
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(isActive ? .white : action.color)
                .frame(width: 58, height: 58)
                .background(Color(UIColor.secondarySystemGroupedBackground), in: .capsule)

            Text(action.title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .opacity(isActive ? 1 : 0.78)
        }
    }
}

private struct MagneticDockHandle: View {
    let isOpen: Bool
    let selectedIcon: String

    var body: some View {
        ZStack {
            Capsule()
                .fill(.regularMaterial)
                .frame(width: isOpen ? 74 : 156, height: 64)
                .shadow(color: .black.opacity(0.16), radius: 20, x: 0, y: 12)

            HStack(spacing: 10) {
                Image(systemName: isOpen ? "xmark" : selectedIcon)
                    .font(.system(size: 20, weight: .bold))
                    .frame(width: 24)
                    .rotationEffect(.degrees(isOpen ? 90 : 0))

                if !isOpen {
                    Text("Actions")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .transition(.opacity.combined(with: .scale(scale: 0.92)))
                }
            }
            .foregroundStyle(.primary)
        }
        .contentShape(Capsule())
    }
}

#Preview {
    MagneticActionDockView()
}
