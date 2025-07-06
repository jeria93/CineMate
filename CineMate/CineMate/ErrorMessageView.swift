//
//  ErrorMessageView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

struct ErrorMessageView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .foregroundStyle(.red)
            .padding()
    }
}

#Preview("ErrorMessageView") {
    ErrorMessageView(message: "Something went wrong!")
}
