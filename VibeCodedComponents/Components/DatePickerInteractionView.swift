//
//  DatePickerInteractionView.swift
//  VibeCodedComponents
    


import SwiftUI

struct DatePickerInteractionView: View {
    enum PickerItem: Hashable {
        case add
        case date(Date)
    }

    let startDate: Date
    let endDate: Date
    let todayDate: Date
    let selectableItems: [PickerItem]

    @State private var selectedItem: PickerItem?
    @Namespace private var animation

    private let tickWidth: CGFloat = 3
    private let tickSpacing: CGFloat = 8
    private let maxTickHeight: CGFloat = 32
    private let calendar: Calendar

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE • MMM d"
        formatter.locale = .current
        formatter.calendar = .current
        formatter.timeZone = .current
        return formatter
    }()

    init(startDate: Date? = nil, endDate: Date? = nil, calendar: Calendar = .current) {
        self.calendar = calendar

        let today = calendar.startOfDay(for: Date())
        self.todayDate = today

        let normalizedStart = calendar.startOfDay(
            for: startDate ?? calendar.date(byAdding: .day, value: -30, to: today)!
        )
        let normalizedEnd = calendar.startOfDay(
            for: endDate ?? calendar.date(byAdding: .day, value: 30, to: today)!
        )

        self.startDate = normalizedStart
        self.endDate = normalizedEnd

        var items: [PickerItem] = [.add]
        var currentDate = normalizedStart

        while currentDate <= normalizedEnd {
            items.append(.date(currentDate))
            guard let next = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = calendar.startOfDay(for: next)
        }

        self.selectableItems = items

        if today >= normalizedStart && today <= normalizedEnd {
            _selectedItem = State(initialValue: .date(today))
        } else {
            _selectedItem = State(initialValue: .add)
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear.ignoresSafeArea()

            GeometryReader { proxy in
                let bottomInset = proxy.safeAreaInsets.bottom

                VStack(spacing: 0) {
                    Spacer()

                    headerRow
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)

                    pickerSection(
                        containerWidth: proxy.size.width,
                        bottomInset: bottomInset
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .persistentSystemOverlays(.hidden)
        .sensoryFeedback(.selection, trigger: selectedItem)
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            if todayButtonSide == .leading {
                todayButton
                Spacer(minLength: 12)
                indicatorCapsule
            } else if todayButtonSide == .trailing {
                indicatorCapsule
                Spacer(minLength: 12)
                todayButton
            } else {
                Spacer()
                indicatorCapsule
                Spacer()
            }
        }
        .frame(height: 40)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: todayButtonSide)
    }

    private func pickerSection(containerWidth: CGFloat, bottomInset: CGFloat) -> some View {
        GeometryReader { mainProxy in
            let globalCenter = mainProxy.frame(in: .global).midX

            ScrollViewReader { scrollProxy in
                ZStack(alignment: .bottom) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: tickSpacing) {
                            ForEach(selectableItems, id: \.self) { item in
                                Capsule()
                                    .fill(Color.gray.opacity(0.4))
                                    .frame(width: tickWidth, height: maxTickHeight)
                                    .visualEffect { content, geometryProxy in
                                        let midX = geometryProxy.frame(in: .global).midX
                                        let distance = abs(midX - globalCenter)

                                        let maxSpread: CGFloat = 80
                                        let normalizedDistance = min(distance / maxSpread, 1.0)
                                        let scale = 1.0 - (normalizedDistance * 0.85)

                                        return content
                                            .scaleEffect(y: scale, anchor: .bottom)
                                            .opacity(1.0 - (normalizedDistance * 0.4))
                                    }
                                    .id(item)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $selectedItem)
                    .safeAreaPadding(.horizontal, containerWidth / 2 - (tickWidth / 2))
                    .frame(height: 44)
                    .onAppear {
                        guard let selectedItem else { return }
                        DispatchQueue.main.async {
                            scrollProxy.scrollTo(selectedItem, anchor: .center)
                        }
                    }

                    Capsule()
                        .fill(Color.red)
                        .frame(width: tickWidth + 1, height: maxTickHeight + 4)
                        .offset(y: -1)
                }
                .padding(.bottom, max(12, bottomInset > 0 ? bottomInset - 2 : 12))
            }
        }
        .frame(height: 56)
    }

    private var indicatorCapsule: some View {
        ZStack {
            switch selectedItem {
            case .add, .none:
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(width: 50, height: 40)
                    .background(
                        Capsule()
                            .fill(Color(UIColor.systemGray6))
                            .matchedGeometryEffect(id: "capsuleBG", in: animation)
                    )
                    .transition(.scale.combined(with: .opacity))

            case .date(let date):
                Text(Self.dateFormatter.string(from: date))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .frame(height: 40)
                    .background(
                        Capsule()
                            .fill(Color(UIColor.systemGray6))
                            .matchedGeometryEffect(id: "capsuleBG", in: animation)
                    )
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedItem)
    }

    private var todayButton: some View {
        Button {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                selectedItem = .date(todayDate)
            }
        } label: {
            HStack {
                if todayButtonSide == .leading {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.red)
                }
                Text("Today")
                    .foregroundColor(.primary)
                if todayButtonSide == .trailing {
                    Image(systemName: "arrow.right")
                        .foregroundColor(.red)
                }
            }
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(height: 40)
            .background(Capsule().fill(Color(UIColor.systemGray6)))
        }
        
        .opacity(todayButtonSide == nil ? 0 : 1)
        .scaleEffect(todayButtonSide == nil ? 0.85 : 1)
    }

    private var todayButtonSide: HorizontalAlignment? {
        guard let relation = selectedDateRelationToToday else { return .trailing }

        switch relation {
        case .orderedAscending:
            return .trailing   // past -> right
        case .orderedDescending:
            return .leading    // future -> left
        case .orderedSame:
            return nil
        }
    }

    private var selectedDateRelationToToday: ComparisonResult? {
        guard case .date(let selectedDate) = selectedItem else { return nil }

        let selected = calendar.startOfDay(for: selectedDate)
        let today = calendar.startOfDay(for: todayDate)

        if selected < today { return .orderedAscending }
        if selected > today { return .orderedDescending }
        return .orderedSame
    }
}

#Preview {
    DatePickerInteractionView()
}
