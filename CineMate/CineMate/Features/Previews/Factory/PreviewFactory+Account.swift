//
//  PreviewFactory+Account.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-06.
//

import SwiftUI

@MainActor
extension PreviewFactory {
    
    /// A default account view model (extend with user later)
    static func accountViewModel() -> AccountViewModel {
        AccountViewModel()
    }
    
    /// A logged-in user mock (future feature)
    static func loggedInAccountViewModel() -> AccountViewModel {
        let vm = AccountViewModel()
        // vm.user = PreviewData.mockUser
        return vm
    }
    
    /// A logged-out user mock
    static func loggedOutAccountViewModel() -> AccountViewModel {
        AccountViewModel()
    }
    
    /// An error state for account (if needed)
    static func errorAccountViewModel() -> AccountViewModel {
        let vm = AccountViewModel()
        // vm.errorMessage = "Unable to load user data"
        return vm
    }
}
