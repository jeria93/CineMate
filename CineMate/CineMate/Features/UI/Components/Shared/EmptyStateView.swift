//
//  EmptyStateView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-11.
//

import SwiftUI

struct EmptyStateView: View {
    enum Layout {
        case fullScreen
        case inline
    }
    
    let systemImage: String
    let title: String
    let message: String
    let layout: Layout
    var actionTitle: String?
    var onAction: (() -> Void)?
    
    init(
        systemImage: String,
        title: String,
        message: String,
        layout: Layout = .fullScreen,
        actionTitle: String? = nil,
        onAction: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.layout = layout
        self.actionTitle = actionTitle
        self.onAction = onAction
    }
    
    var body: some View {
        Group {
            switch layout {
            case .fullScreen:
                OverlayContainer(backdrop: .material) {
                    OverlayCard {
                        content
                    }
                }
            case .inline:
                content
                    .padding(SharedUI.Overlay.cardPadding)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: SharedUI.Radius.large, style: .continuous)
                            .fill(Color.appSurface.opacity(0.96))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: SharedUI.Radius.large, style: .continuous)
                            .stroke(Color.appTextSecondary.opacity(0.20), lineWidth: 1)
                    )
            }
        }
    }
    
    private var content: some View {
        VStack(spacing: SharedUI.Spacing.medium) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(Color.appTextSecondary)
                .accessibilityHidden(true)
            
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            
            Text(message)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
            
            if let actionTitle, let onAction {
                Button(actionTitle, action: onAction)
                    .buttonStyle(.borderedProminent)
                    .tint(.appPrimaryAction)
                    .padding(.top, SharedUI.Spacing.small)
            }
        }
    }
}

#Preview("No Results") {
    EmptyStateView.previewNoResults
}

#Preview("No Favorites") {
    EmptyStateView.previewNoFavorites
}

#Preview("Generic") {
    EmptyStateView.previewGeneric
}
