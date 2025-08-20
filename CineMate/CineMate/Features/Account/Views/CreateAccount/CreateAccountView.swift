//
//  CreateAccountView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-19.
//

import SwiftUI

struct CreateAccountView: View {
    @ObservedObject private var createViewModel: CreateAccountViewModel

    init(createViewModel: CreateAccountViewModel) {
        self ._createViewModel = ObservedObject(wrappedValue: createViewModel)
    }

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview { CreateAccountView.previewEmpty }
#Preview { CreateAccountView.previewFilledValid }
#Preview { CreateAccountView.previewPasswordMismatch }
#Preview { CreateAccountView.previewInvalidEmail }
#Preview { CreateAccountView.previewIsAuthenticating }
#Preview { CreateAccountView.previewServerError }

