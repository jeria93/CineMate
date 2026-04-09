//
//  ValidationMessageView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-07.
//

import SwiftUI

/// A reusable view for showing validation feedback to the user.
struct ValidationMessageView: View {
    enum Palette {
        case surface
        case curtain
    }
    
    let message: String
    var palette: Palette = .surface
    
    private var textColor: Color {
        switch palette {
        case .surface:
            return .appTextSecondary
        case .curtain:
            return AuthTheme.textOnCurtainSecondary
        }
    }
    
    var body: some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(textColor)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .padding(.top, 4)
    }
}

#Preview("ValidationMessageView") {
    ValidationMessageView(message: "Query must be at least 2 characters.")
}
