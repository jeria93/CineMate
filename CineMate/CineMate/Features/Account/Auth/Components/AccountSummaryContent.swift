//
//  AccountSummaryContent.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-06-03.
//

import Foundation

/// Presentation data for the account summary card.
/// It converts auth session state into stable text and icon values for the summary view.
struct AccountSummaryContent {
    let title: String
    let detail: String?
    let iconSystemName: String
    let providerDescription: String
    let userID: String?
    
    init(
        isSignedIn: Bool,
        isGuest: Bool,
        currentUserEmail: String?,
        providerDescription: String,
        currentUID: String?
    ) {
        if let currentUserEmail, !currentUserEmail.isEmpty {
            title = currentUserEmail
        } else if isGuest {
            title = "Guest account"
        } else {
            title = isSignedIn ? "Signed in" : "Signed out"
        }
        
        if isGuest {
            detail = "Create an account to manage your details and unlock more features."
        } else if isSignedIn {
            detail = "Manage your email, security, and legal settings."
        } else {
            detail = "Sign in to manage your account."
        }
        
        if isGuest {
            iconSystemName = "person.crop.circle.badge.questionmark"
        } else {
            iconSystemName = isSignedIn
            ? "person.crop.circle.fill"
            : "person.crop.circle.badge.xmark"
        }
        
        self.providerDescription = providerDescription
        userID = currentUID.map { String($0.prefix(10)) }
    }
}
