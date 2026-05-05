//
//  ComponentsListScreen.swift
//  VibeCodedComponents

import SwiftUI


struct ComponentsListScreen: View {
    private let entries: [ComponentEntry]
    private let edgeFadeHeight: CGFloat = 44
    private let carouselBackgrounds = [
        "UnicornVectorGradient_1",
        "UnicornVectorGradient_2",
        "UnicornVectorGradient_3",
        "UnicornVectorGradient_4",
        "UnicornVectorGradient_5",
        "UnicornVectorGradient_6",
    ]
   
    @Namespace private var namespace
    @Environment(\.colorScheme) private var scheme
    @Environment(\.openURL) private var openURL
    @State private var isProfilePopupPresented = false
    
    init(@EntriesBuilder entries: () -> [ComponentEntry]) {
        self.entries = entries()
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0) {
                profileHeader
                featuredCarousel
                
                VStack(spacing: 0) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        NavigationLink {
                            entry.destination
                                .navigationBarBackButtonHidden()
                                .navigationTransition(.zoom(sourceID: entry.id, in: namespace))
                        } label: {
                            ComponentEntryRowView(entry: entry)
                                .matchedTransitionSource(id: entry.id, in: namespace)
                        }
                        .buttonStyle(.plain)
                        
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
                topEdgeFade
                Spacer()
                bottomEdgeFade
            }
            .ignoresSafeArea()
        }
    }
    
    private var topEdgeFade: some View {
        LinearGradient(
            stops: [.init(color: .reversedPrimary, location: 0.2), .init(color: .clear, location: 1.0)],
            startPoint: .top, endPoint: .bottom
        )
        .frame(height: 40)
        .allowsHitTesting(false)
    }
    
    private var bottomEdgeFade: some View {
        LinearGradient(
            stops: [.init(color: .reversedPrimary, location: 0.2), .init(color: .clear, location: 1.0)],
            startPoint: .bottom, endPoint: .top
        )
        .frame(height: 130)
        .allowsHitTesting(false)
        .offset(y: 40)
    }

    private var profileHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Abodi Dawoud")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text("Developer")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }

            Spacer(minLength: 16)

            Button {
                hapticFeedback(style: .light)
                isProfilePopupPresented.toggle()
            } label: {
                Image(.avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(.circle)
                    .overlay {
                        Circle()
                            .stroke(.primary.opacity(0.08), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .popover(isPresented: $isProfilePopupPresented, arrowEdge: .top) {
                ProfilePopupView(componentCount: entries.count)
            }
        }
    }

    private var featuredCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(entries.prefix(6).enumerated()), id: \.element.id) { index, entry in
                    NavigationLink {
                        entry.destination
                            .navigationBarBackButtonHidden()
                            .navigationTransition(.zoom(sourceID: CarouselSourceID(id: entry.id), in: namespace))
                    } label: {
                        FeaturedComponentCard(
                            entry: entry,
                            backgroundName: carouselBackgrounds[index % carouselBackgrounds.count]
                        )
                        .matchedTransitionSource(id: CarouselSourceID(id: entry.id), in: namespace)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 0, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .padding(.horizontal, -24)
        .padding(.top, 26)
    }
}


private struct ComponentEntryRowView: View {
    let entry: ComponentEntry

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(entry.title)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                if !entry.date.isEmpty {
                    Text("•")
                        .fontWeight(.thin)
                        .foregroundStyle(.secondary)
                    
                    Text(entry.date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }

            if let badge = entry.badge {
                Text(badge)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.purple.gradient)
                    .padding(.horizontal, 10)
                    .frame(height: 24)
                    .background(.purple.quaternary, in: .capsule)
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
