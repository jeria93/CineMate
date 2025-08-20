//
//  LoginViewModel.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-08-18.
//

import Foundation

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticating = false
    @Published var errorMessage: String?

    private let service: FirebaseAuthService?
    private let onSuccess: (String) -> Void

//    Production
    init(service: FirebaseAuthService, onSuccess: @escaping (String) -> Void) {
        self.service = service
        self.onSuccess = onSuccess
    }

//    Preview
    init(previewEmail: String = "", previewIsAuthenticating: Bool = false, previewError: String? = nil) {
        self.service = nil
        self.onSuccess = { _ in }
        self.email = previewEmail
        self.isAuthenticating = previewIsAuthenticating
        self.errorMessage = previewError
    }

    func login() async {
        guard let service else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            let uid = try await service.signIn(email: email, password: password)
            errorMessage = nil
            onSuccess(uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUp() async {
        guard let service else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            let uid = try await service.signUp(email: email, password: password)
            errorMessage = nil
            onSuccess(uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetPassword() async {
        guard let service else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            try await service.sendPasswordReset(email: email)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func continueAsGuest() async {
        guard let service else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            let uid = try await service.signInAnonymously()
            errorMessage = nil
            onSuccess(uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

}
