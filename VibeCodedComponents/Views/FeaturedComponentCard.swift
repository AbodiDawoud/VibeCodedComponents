//
//  FeaturedComponentCard.swift
//  VibeCodedComponents
    

import SwiftUI

struct FeaturedComponentCard: View {
    let entry: ComponentEntry
    let backgroundName: String
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(backgroundName)
                .resizable()
                .scaledToFill()
                .frame(width: 190, height: 110)
                .clipShape(.rect(cornerRadius: 12))
                
            
            Text(entry.title)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
                .padding(.leading, 5)
        }
        .padding(.top, 12)
        .padding(.horizontal, 12)
        .padding(.bottom, 10)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(.separator).opacity(0.16), lineWidth: 0.5)
                .fill(scheme == .light ? Color(white: 0.9) : Color(white: 0.12))
        }
    }
}


struct CarouselSourceID: Hashable {
    let id: UUID
}
