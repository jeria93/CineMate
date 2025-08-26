//
//  ValidationMessageView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-07.
//

import SwiftUI

/// A reusable view for showing validation feedback to the user.
struct ValidationMessageView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.footnote)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .padding(.top, 4)
    }
}

#Preview("ValidationMessageView") {
    ValidationMessageView(message: "Query must be at least 2 characters.")
}
