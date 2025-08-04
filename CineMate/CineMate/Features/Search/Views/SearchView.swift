import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(text: $viewModel.query)

            if let message = viewModel.validationMessage {
                ValidationMessageView(message: message)
            }

            contentView
        }
        .navigationTitle("Search")
    }

    // MARK: - State-driven UI
    @ViewBuilder
    private var contentView: some View {
        if viewModel.query.isEmpty {
            SearchPromptView()
        } else if viewModel.isLoading {
            LoadingView(title: "Searching movies...")
        } else if let error = viewModel.error {
            ErrorMessageView(
                title: "Error",
                message: error.localizedDescription,
                onRetry: { Task { await viewModel.search(viewModel.query) } }
            )
        } else if viewModel.results.isEmpty && !viewModel.trimmedQuery.isEmpty {
            EmptyResultsView(query: viewModel.trimmedQuery)
        } else {
            SearchResultsList(movies: viewModel.results)
        }
    }
}

#Preview("Prompt") {
    SearchView.previewPrompt.withPreviewNavigation()
}

#Preview("With Results") {
    SearchView.previewDefault.withPreviewNavigation()
}

#Preview("Empty State") {
    SearchView.previewEmpty.withPreviewNavigation()
}

#Preview("Loading") {
    SearchView.previewLoading.withPreviewNavigation()
}

#Preview("Error") {
    SearchView.previewError.withPreviewNavigation()
}

#Preview("Validation Error") {
    SearchView.previewValidation
}
