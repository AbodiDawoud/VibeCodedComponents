//
//  ChatGPTModelMenu.swift
//  VibeCodedComponents
    
import SwiftUI


struct ChatGPTModelMenu: View {
    @State private var isExpanded = false
    @State private var showMoreModels = false
    @Namespace private var menuAnimation
    @Environment(\.dismiss) private var dismiss
    
    
    private let topModels = [
        ModelOption(name: "GPT-4o", description: "Great for most tasks", isSelected: true),
        ModelOption(name: "o3", description: "Uses advanced reasoning"),
        ModelOption(name: "o4-mini", description: "Fastest at advanced reasoning")
    ]
    
    private let moreModels = [
        ModelOption(name: "o4-mini-high", description: "Great for coding and visual reasoning"),
        ModelOption(name: "GPT 4.5", description: "Good for writing and exploring ideas"),
//        ModelOption(name: "GPT 4.1", description: "Great for quick coding and analysis"),
//        ModelOption(name: "GPT 4.1-mini", description: "Faster for everyday tasks")
    ]
    

    var body: some View {
        ZStack(alignment: .top) {
            // Background / Main Content Area
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            
            // 1. Static Toolbar Items
            HStack {
                Button(action: dismiss.callAsFunction) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "square.and.pencil")
                }
            }
            .font(.title2)
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .zIndex(1)
            
            if isExpanded {
                // 2. Dimming Overlay
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isExpanded = false
                            showMoreModels = false
                        }
                    }
            }
            
            // 3. Morphing Menu Container
            VStack {
                if isExpanded {
                    expandedMenuView
                } else {
                    compactTitleView
                }
            }
            .zIndex(3)
            .padding(.top, isExpanded ? 0 : 6)
        }
        .navigationBarBackButtonHidden()
    }
    
    
    var compactTitleView: some View {
        Button {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                isExpanded = true
            }
        } label: {
            HStack(spacing: 6) {
                Text("No Em Dashes")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("4o >")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.clear)
                    .matchedGeometryEffect(id: "menuBackground", in: menuAnimation)
            )
        }
        .matchedGeometryEffect(id: "menuContainer", in: menuAnimation, properties: .size, isSource: !isExpanded)
    }
    
    // MARK: - Expanded Menu View
    var expandedMenuView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header Area
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("No Em Dashes")
                        
                    
                    Text("talking about not using Em Dashes in responses.Kumail would like to stick to correct punctuation.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
//                .matchedGeometryEffect(id: "menuHeader", in: menuAnimation)
                
                Spacer(minLength: 16)
                
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isExpanded = false
                        showMoreModels = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                }
                .buttonStyle(.plain)
            }
            
            
            // Models List (Now using a VStack to hug content instead of expanding)
            VStack(spacing: 10) {
                ForEach(topModels) { model in
                    ModelRowView(model: model)
                }
                
                if showMoreModels {
                    ForEach(moreModels) { model in
                        ModelRowView(model: model)
                    }
                }
                
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        showMoreModels.toggle()
                    }
                } label: {
                    HStack {
                        Text(showMoreModels ? "Fewer models" : "More models")
                        Image(systemName: showMoreModels ? "chevron.up" : "chevron.right")
                        Spacer()
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(.top, 3)
                }
            }
            
            Divider().opacity(0.55).padding(.horizontal, -22)
            
            
            // Action Buttons
            VStack(alignment: .leading, spacing: 18) {
                ActionRowView(icon: "square.and.arrow.up", title: "Share")
                ActionRowView(icon: "applepencil.gen1", title: "Rename")
                ActionRowView(icon: "archivebox", title: "Archive")
                ActionRowView(icon: "trash", title: "Delete", color: .red)
            }
            
            
            Divider().opacity(0.55).padding(.horizontal, -22)
            
            // Footer
            Text("Created today at 2:19 PM")
                .font(.system(size: 12.5))
                .foregroundStyle(.tertiary)
        }
        .padding(22) // Generous inner padding
        .background(
            RoundedRectangle(cornerRadius: 35, style: .continuous) // Much softer, Apple-like corner radius
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.12), radius: 30, y: 15)
                .matchedGeometryEffect(id: "menuBackground", in: menuAnimation)
        )
//        .matchedGeometryEffect(id: "menuContainer", in: menuAnimation, isSource: isExpanded)
        .padding(.horizontal, 16) // outer padding
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}


struct ModelRowView: View {
    private let model: ModelOption
    
    fileprivate init(model: ModelOption) {
        self.model = model
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(model.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if model.isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.callout.weight(.medium))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.quinary.opacity(0.4))
                .padding(.horizontal, -10)
        }
        
    }
}

struct ActionRowView: View {
    let icon: String
    let title: String
    var color: Color = .primary
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: 24)
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                Spacer()
            }
            .foregroundColor(color)
        }
    }
}

fileprivate struct ModelOption: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    var isSelected: Bool = false
}

#Preview {
    ChatGPTModelMenu()
}
