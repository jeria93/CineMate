//
//  GoogleLegalAcceptanceSheet.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2026-05-22.
//

import SwiftUI

struct GoogleLegalAcceptanceSheet: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var activeLegalSheet: LegalSheet?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(AuthTheme.popcorn)
                    Text("Review before continuing")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AuthTheme.textOnCurtainPrimary)
                    Text("Accept the same terms and privacy policy used for email accounts to finish Google sign-in.")
                        .font(.callout)
                        .foregroundStyle(AuthTheme.textOnCurtainSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                legalConsentRow(
                    title: "I accept the Terms of Service",
                    linkTitle: "View terms",
                    isAccepted: $viewModel.acceptedGoogleTerms,
                    helperText: viewModel.googleTermsHelperText,
                    onLinkTap: { activeLegalSheet = .terms }
                )

                legalConsentRow(
                    title: "I accept the Privacy Policy",
                    linkTitle: "View privacy policy",
                    isAccepted: $viewModel.acceptedGooglePrivacyPolicy,
                    helperText: viewModel.googlePrivacyPolicyHelperText,
                    onLinkTap: { activeLegalSheet = .privacyPolicy }
                )

                if let message = viewModel.errorMessage {
                    AuthErrorBlock(message: message)
                }

                Button {
                    Task { await viewModel.acceptGoogleLegalTerms() }
                } label: {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.pillWhite)
                .controlSize(.large)
                .frame(height: 48)
                .disabled(viewModel.isAuthenticating)

                Spacer(minLength: 0)
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                LinearGradient(
                    colors: [AuthTheme.curtainTop, AuthTheme.curtainBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .overlay {
                if viewModel.isAuthenticating {
                    LoadingView(title: viewModel.loadingTitle).transition(.opacity)
                }
            }
            .sheet(item: $activeLegalSheet) { document in
                TermsSheet(
                    markdown: document.markdown,
                    title: document.title,
                    subtitle: "Please review before continuing",
                    iconSystemName: document.iconSystemName
                )
            }
            .onChange(of: viewModel.acceptedGoogleTerms) { _, _ in
                viewModel.clearGoogleLegalError()
            }
            .onChange(of: viewModel.acceptedGooglePrivacyPolicy) { _, _ in
                viewModel.clearGoogleLegalError()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.cancelGoogleLegalAcceptance()
                    }
                    .disabled(viewModel.isAuthenticating)
                }
            }
        }
    }

    private func legalConsentRow(
        title: String,
        linkTitle: String,
        isAccepted: Binding<Bool>,
        helperText: String?,
        onLinkTap: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(AuthTheme.textOnCurtainPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Toggle("", isOn: isAccepted)
                    .labelsHidden()
                    .tint(AuthTheme.linkOnCurtain)
                    .disabled(viewModel.isAuthenticating)
            }

            Button(linkTitle, action: onLinkTap)
                .buttonStyle(.plain)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AuthTheme.linkOnCurtain)
                .underline()
                .frame(maxWidth: .infinity, alignment: .leading)

            if let helperText {
                ValidationMessageView(message: helperText, palette: .curtain)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private enum LegalSheet: String, Identifiable {
        case terms
        case privacyPolicy

        var id: String { rawValue }

        var title: String {
            switch self {
            case .terms: "Terms of Service"
            case .privacyPolicy: "Privacy Policy"
            }
        }

        var iconSystemName: String {
            switch self {
            case .terms: "doc.text"
            case .privacyPolicy: "lock.doc"
            }
        }

        var markdown: String {
            switch self {
            case .terms: TermsContent.termsMarkdown
            case .privacyPolicy: TermsContent.privacyPolicyMarkdown
            }
        }
    }
}
