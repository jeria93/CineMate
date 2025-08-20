//
//  CreateAccountViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-19.
//

import Foundation

@MainActor
final class CreateAccountViewModel: ObservableObject {

// Form States
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var acceptedTerms: Bool = false

//    UI States
    @Published var isAuthenticating: Bool = false
    @Published var errorMessage: String?

    private let service: FirebaseAuthService?
    private let onSuccess: (String) -> Void

//    Production
    init(service: FirebaseAuthService, onSuccess: @escaping (String) -> Void) {
        self.service = service
        self.onSuccess = onSuccess
    }

//    Preview
    init (
        previewEmail: String = "",
        previewIsAuthenticating: Bool = false,
        previewErrorMessage: String? = nil
    ) {
        self.service = nil
        self.onSuccess = { _ in }
        self.email = previewEmail
        self.isAuthenticating = previewIsAuthenticating
        self.errorMessage = previewErrorMessage
    }

//    Simple validation for now(Extract to a Validator at later point?)
    var isPasswordMatch: Bool { !password.isEmpty && password == confirmPassword }
    var isFormValid: Bool { email.contains("@") && isPasswordMatch && acceptedTerms}

    func signUp() async {
        guard let service, isFormValid else { return }
        isAuthenticating = true
        defer { isAuthenticating = false } // Always end loading on exit (success or error)

        do {
            let uid = try await service.signUp(email: email, password: password)
            errorMessage = nil
            onSuccess(uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func upgradeAnonymousAccount() async {
        guard let service, isFormValid else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }
        
        do {
            let uid = try await service.linkAnonymousAccount(email: email, password: password)
            errorMessage = nil
            onSuccess(uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
