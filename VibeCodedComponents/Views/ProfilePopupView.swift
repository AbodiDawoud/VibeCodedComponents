//
//  ProfilePopupView.swift
//  VibeCodedComponents
    

import SwiftUI



struct ProfilePopupView: View {
    let componentCount: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 13) {
                Image(.avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(.circle)
                

                VStack(alignment: .leading, spacing: 4) {
                    Text("Abodi Dawoud")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text("Developer")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            HStack(spacing: 6) {
                Text("\(componentCount) components")
                Text("•")
                Text("Fully SwiftUI")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            Button(action: showProfileOnGitHub) {
                HStack(spacing: 8) {
                    Text("View GitHub")
                        .font(.subheadline.weight(.semibold))

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(Color(.tertiarySystemFill), in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(width: 260)
        .presentationCompactAdaptation(.popover)
    }
    
    
    func showProfileOnGitHub() {
        dismiss()
        hapticFeedback(style: .rigid)
        let url = URL(string: "https://github.com/abodidawoud")!
        openURL(url)
    }
}
