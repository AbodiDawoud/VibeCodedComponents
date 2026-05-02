import SwiftUI

private struct FanMenuItem {
    let label: String
    let icon: String
    let tint: Color
}

struct FanMenuView: View {
    @State private var isExpanded = false
    @State private var selectedItem = "Image"
    @State private var highlightedIndex: Int?
    @State private var dragLocation: CGPoint?
    @State private var gestureStartedExpanded = false
    @State private var pulse = false
    @Environment(\.colorScheme) private var scheme

    private let items: [FanMenuItem] = [
        FanMenuItem(label: "Image", icon: "photo.on.rectangle.angled", tint: .blue),
        FanMenuItem(label: "Video", icon: "film.stack", tint: .purple),
        FanMenuItem(label: "Music", icon: "music.note", tint: .pink),
        FanMenuItem(label: "Document", icon: "doc.text", tint: .orange),
        FanMenuItem(label: "Learning", icon: "book.closed", tint: .green)
    ]

    var body: some View {
        GeometryReader { proxy in
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2 + 64)
            let actionCenters = items.indices.map { itemCenter(for: $0, origin: center) }

            ZStack {
                background

                if isExpanded {
                    Color.primary.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture(perform: closeMenu)
                }

                VStack(spacing: 10) {
                    Text(selectedItem)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())

                    Text("Selected action")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .offset(y: -210)

                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    let isHighlighted = highlightedIndex == index

                    FanMenuPill(item: item, isHighlighted: isHighlighted)
                        .position(isExpanded ? actionCenters[index] : center)
                        .opacity(isExpanded ? 1 : 0)
                        .scaleEffect(isExpanded ? (isHighlighted ? 1.12 : 1) : 0.35)
                        .rotationEffect(.degrees(isExpanded ? 0 : -12))
                        .zIndex(isHighlighted ? 2 : 1)
                        .animation(.spring(response: 0.42, dampingFraction: 0.72).delay(Double(index) * 0.025), value: isExpanded)
                        .animation(.spring(response: 0.22, dampingFraction: 0.7), value: highlightedIndex)
                        .onTapGesture {
                            selectItem(at: index)
                        }
                }

                if isExpanded {
                    ForEach(items.indices, id: \.self) { index in
                        FanMenuConnector(
                            start: center,
                            end: actionCenters[index],
                            tint: items[index].tint.opacity(highlightedIndex == index ? 0.5 : 0.16)
                        )
                    }
                    .transition(.opacity)
                }

                FanMenuTrigger(isExpanded: isExpanded, pulse: pulse)
                    .position(center)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged { value in
                                if dragLocation == nil {
                                    gestureStartedExpanded = isExpanded
                                }

                                if !isExpanded {
                                    openMenu()
                                }

                                dragLocation = value.location
                                highlightedIndex = nearestItem(to: value.location, centers: actionCenters)
                            }
                            .onEnded { value in
                                let didTap = hypot(value.translation.width, value.translation.height) < 8

                                if didTap {
                                    if gestureStartedExpanded {
                                        closeMenu()
                                    } else {
                                        dragLocation = nil
                                        gestureStartedExpanded = false
                                    }
                                    return
                                }

                                if let highlightedIndex {
                                    selectItem(at: highlightedIndex)
                                } else {
                                    closeMenu()
                                }
                            }
                    )
                    .zIndex(3)
            }
            .animation(.spring(response: 0.42, dampingFraction: 0.78), value: isExpanded)
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(white: scheme == .light ? 0.98 : 0.06),
                Color(white: scheme == .light ? 0.93 : 0.02)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private func itemCenter(for index: Int, origin: CGPoint) -> CGPoint {
        let angles: [CGFloat] = [-154, -122, -90, -58, -26]
        let radius: CGFloat = 148
        let angle = angles[index] * .pi / 180
        return CGPoint(
            x: origin.x + cos(angle) * radius,
            y: origin.y + sin(angle) * radius
        )
    }

    private func nearestItem(to location: CGPoint, centers: [CGPoint]) -> Int? {
        let distances = centers.enumerated().map { index, center in
            (index: index, distance: hypot(location.x - center.x, location.y - center.y))
        }

        guard let nearest = distances.min(by: { $0.distance < $1.distance }), nearest.distance < 76 else {
            return nil
        }

        return nearest.index
    }

    private func openMenu() {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
            isExpanded = true
            pulse.toggle()
        }
        Sound.play(.startup)
        hapticFeedback(style: .medium)
    }

    private func closeMenu() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            isExpanded = false
            highlightedIndex = nil
            dragLocation = nil
            gestureStartedExpanded = false
        }
        hapticFeedback(style: .soft)
    }

    private func selectItem(at index: Int) {
        selectedItem = items[index].label
        Sound.play(.buttonTap)
        hapticFeedback(style: .rigid)
        closeMenu()
    }
}

private struct FanMenuPill: View {
    let item: FanMenuItem
    let isHighlighted: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: item.icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(isHighlighted ? .white : item.tint)
                .frame(width: 22)

            Text(item.label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(isHighlighted ? .white : .primary)
                .lineLimit(1)
        }
        .padding(.horizontal, 15)
        .frame(height: 42)
        .background(Color(UIColor.secondarySystemGroupedBackground), in: .capsule)
    }
}

private struct FanMenuTrigger: View {
    let isExpanded: Bool
    let pulse: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(.primary.opacity(0.08), lineWidth: 1)
                .frame(width: 92, height: 92)
                .scaleEffect(pulse ? 1.35 : 0.72)
                .opacity(isExpanded ? 0 : 0.45)
                .animation(.easeOut(duration: 0.48), value: pulse)


            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
                .rotationEffect(.degrees(isExpanded ? 45 : 0))
        }
        .contentShape(Circle())
    }
}

private struct FanMenuConnector: View {
    let start: CGPoint
    let end: CGPoint
    let tint: Color

    var body: some View {
        Path { path in
            path.move(to: start)
            path.addQuadCurve(
                to: end,
                control: CGPoint(x: (start.x + end.x) / 2, y: min(start.y, end.y) - 18)
            )
        }
        .stroke(tint, style: StrokeStyle(lineWidth: 2, lineCap: .round))
        .allowsHitTesting(false)
    }
}

#Preview {
    FanMenuView()
}
