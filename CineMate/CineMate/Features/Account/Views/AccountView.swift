//
//  AccountView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

struct AccountView: View {
    @StateObject private var viewModel: AccountViewModel

    init(viewModel: AccountViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Text("AccountView")
    }
}

#Preview {
    AccountView.previewDefault
}
