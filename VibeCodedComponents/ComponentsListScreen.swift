//
//  ComponentsListScreen.swift
//  VibeCodedComponents

import SwiftUI


struct ComponentsListScreen: View {
    private let entries: [ComponentEntry]
    private let edgeFadeHeight: CGFloat = 44

    init(@EntriesBuilder entries: () -> [ComponentEntry]) {
        self.entries = entries()
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                profileHeader
                
                VStack(spacing: 0) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        ComponentEntryRowView(entry: entry)
                        
                        if index < entries.count - 1 {
                            Divider()
                        }
                    }
                }
                .padding(.top, 32)
                
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
        }
        .overlay(alignment: .center) {
            VStack {
                edgeFade(from: .top).ignoresSafeArea()
                Spacer()
                edgeFade(from: .bottom).ignoresSafeArea()
            }
            .ignoresSafeArea()
        }
    }

    private var profileHeader: some View {
        HStack(alignment: .center, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Abodi Dawoud")
                    .font(.system(size: 23, weight: .bold, design: .default))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("Developer")
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 16)

            Image(.orb)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(Circle())
        }
    }

    private func edgeFade(from edge: Edge) -> some View {
        Rectangle()
            .fill(.regularMaterial)
            .frame(height: edgeFadeHeight)
            .mask(
                LinearGradient(
                    stops: edge == .top
                        ? [
                            .init(color: .black, location: 0),
                            .init(color: .black.opacity(0.92), location: 0.42),
                            .init(color: .black.opacity(0.28), location: 0.78),
                            .init(color: .clear, location: 1)
                        ]
                        : [
                            .init(color: .clear, location: 0),
                            .init(color: .black.opacity(0.28), location: 0.22),
                            .init(color: .black.opacity(0.92), location: 0.58),
                            .init(color: .black, location: 1)
                        ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .allowsHitTesting(false)
    }
}


private struct ComponentEntryRowView: View {
    let entry: ComponentEntry

    var body: some View {
        NavigationLink(destination: entry.destination) {
            HStack(alignment: .center, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 9) {
                    Text(entry.title)
                        .font(.callout.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    if !entry.date.isEmpty {
                        Text("•")
                            .bold()
                            .foregroundStyle(.secondary)
                        
                        Text(entry.date)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                }

                if let badge = entry.badge {
                    Text(badge)
                        .textCase(.uppercase)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.blue.gradient)
                        .padding(.horizontal, 12)
                        .frame(height: 27)
                        .background(.blue.quaternary, in: .capsule)
                        .padding(.leading, 14)
                }

                Spacer(minLength: 14)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
                    .frame(width: 20, height: 44, alignment: .trailing)
            }
            .frame(height: 64)
        }
        .buttonStyle(.plain)
    }
}


struct ComponentEntry: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let badge: String?
    let destination: AnyView

    init<Destination: View>(
        title: String,
        date: String,
        badge: String? = nil,
        @ViewBuilder destination: () -> Destination
    ) {
        self.title = title
        self.date = date
        self.badge = badge
        self.destination = AnyView(destination())
    }
}

@resultBuilder
enum EntriesBuilder {
    static func buildBlock(_ components: ComponentEntry...) -> [ComponentEntry] {
        components
    }

    static func buildArray(_ components: [[ComponentEntry]]) -> [ComponentEntry] {
        components.flatMap { $0 }
    }

    static func buildEither(first component: [ComponentEntry]) -> [ComponentEntry] {
        component
    }

    static func buildEither(second component: [ComponentEntry]) -> [ComponentEntry] {
        component
    }

    static func buildOptional(_ component: [ComponentEntry]?) -> [ComponentEntry] {
        component ?? []
    }
}
