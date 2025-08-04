//
//  AccountView.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-04.
//

import SwiftUI

struct AccountView: View {
    @ObservedObject var viewModel: AccountViewModel

    var body: some View {
        Text("AccountView")
    }
}

#Preview {
    AccountView.previewDefault
}
