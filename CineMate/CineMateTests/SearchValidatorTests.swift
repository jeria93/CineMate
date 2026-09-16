import XCTest
@testable import CineMate

final class SearchValidatorTests: XCTestCase {
    func testEmptyQueryReturnsEmptyCase() {
        let result = SearchValidator.validate("   ")

        switch result {
        case .empty:
            XCTAssertNil(result.message)
            XCTAssertNil(result.trimmed)
        default:
            XCTFail("Expected .empty")
        }
    }

    func testNormalizesWhitespaceForValidQuery() {
        let result = SearchValidator.validate("  Star    Wars  ")

        switch result {
        case .valid(let trimmed):
            XCTAssertEqual(trimmed, "Star Wars")
            XCTAssertEqual(result.trimmed, "Star Wars")
        default:
            XCTFail("Expected .valid(trimmed:)")
        }
    }

    func testTooShortMessageIsClear() {
        let result = SearchValidator.validate("a")

        switch result {
        case .tooShort(let min):
            XCTAssertEqual(min, 2)
            XCTAssertEqual(result.message, "Enter at least 2 characters.")
        default:
            XCTFail("Expected .tooShort")
        }
    }

    func testInvalidCharactersMessageIsClear() {
        let result = SearchValidator.validate("abc🙂")

        switch result {
        case .invalidCharacters:
            XCTAssertEqual(result.message, "Use letters, numbers, spaces, and basic punctuation.")
        default:
            XCTFail("Expected .invalidCharacters")
        }
    }

    func testSanitizedInputRemovesLeadingSpacesAndEmoji() {
        let sanitized = SearchValidator.sanitizedInput("   Star🙂 Wars")
        XCTAssertEqual(sanitized, "Star Wars")
    }

    func testSanitizedInputCapsLength() {
        let longQuery = String(repeating: "a", count: 80)
        let sanitized = SearchValidator.sanitizedInput(longQuery)
        XCTAssertEqual(sanitized.count, SearchValidator.maxLength)
    }
}

final class AuthValidatorTests: XCTestCase {
    func testSanitizedEmailLowercasesAndStripsDisallowedCharacters() {
        let sanitized = AuthValidator.sanitizedEmail(from: " TeSt_+🙂Namn@Exämple.COM ")
        XCTAssertEqual(sanitized, "test_+namn@exmple.com")
    }

    func testEmailValidationAllowsExpectedCharacters() {
        XCTAssertTrue(AuthValidator.isValidEmail("user_name-1+tag@example-domain.com"))
    }

    func testSanitizedPasswordRemovesEmojiAndSmartQuotesAndTrimsEdges() {
        let sanitized = AuthValidator.sanitizedPassword(from: "  Abc🙂123“x”!  ")
        XCTAssertEqual(sanitized, "Abc123x!")
    }

    func testSanitizedPasswordKeepsCommonAsciiSymbols() {
        let sanitized = AuthValidator.sanitizedPassword(from: "Abc123!@#$%^&*()[]{}_-+=/?.,:;")
        XCTAssertEqual(sanitized, "Abc123!@#$%^&*()[]{}_-+=/?.,:;")
    }

    func testLoginPasswordRejectsOnlyEmojiAndWhitespace() {
        XCTAssertFalse(AuthValidator.isValidLoginPassword("🙂 \n\t"))
    }

    func testConfirmPasswordMatchingUsesSameInputRules() {
        let helper = AuthValidator.confirmPasswordHelperText(
            password: "  Pa🙂sswordA1!  ",
            confirmPassword: "PasswordA1!",
            hasTriedSubmit: true
        )
        XCTAssertNil(helper)
    }
}

final class AppRuntimeModeTests: XCTestCase {
    func testMissingConfigurationDefaultsToDemo() {
        XCTAssertEqual(
            AppRuntimeMode.resolve(environment: [:], hasLiveConfiguration: false),
            .demo
        )
    }

    func testAvailableConfigurationDefaultsToLive() {
        XCTAssertEqual(
            AppRuntimeMode.resolve(environment: [:], hasLiveConfiguration: true),
            .live
        )
    }

    func testDemoOverrideWinsWhenConfigurationExists() {
        XCTAssertEqual(
            AppRuntimeMode.resolve(
                environment: [AppRuntimeMode.environmentKey: "demo"],
                hasLiveConfiguration: true
            ),
            .demo
        )
    }

    func testLiveOverrideFallsBackToDemoWithoutConfiguration() {
        XCTAssertEqual(
            AppRuntimeMode.resolve(
                environment: [AppRuntimeMode.environmentKey: "live"],
                hasLiveConfiguration: false
            ),
            .demo
        )
    }

    func testLiveOverrideUsesLiveWhenConfigurationExists() {
        XCTAssertEqual(
            AppRuntimeMode.resolve(
                environment: [AppRuntimeMode.environmentKey: " LIVE "],
                hasLiveConfiguration: true
            ),
            .live
        )
    }
}

final class EnumBackedMappingTests: XCTestCase {
    func testPersonDetailGenderTextKeepsKnownAndUnknownMappings() {
        XCTAssertEqual(personDetail(gender: 1).safeGenderText, "Female")
        XCTAssertEqual(personDetail(gender: 2).safeGenderText, "Male")
        XCTAssertEqual(personDetail(gender: 0).safeGenderText, "Not specified")
        XCTAssertNil(personDetail(gender: nil).safeGenderText)
        XCTAssertNil(personDetail(gender: 99).safeGenderText)
    }

    func testAccountSecurityStatusKeepsExistingCopy() {
        let emailAccount = AccountSecurityStatus(
            canChangeEmail: true,
            canSendPasswordReset: true
        )
        XCTAssertEqual(emailAccount.title, "Email account")
        XCTAssertEqual(
            emailAccount.detail,
            "Email changes and password reset links are available for this account."
        )

        let limitedControls = AccountSecurityStatus(
            canChangeEmail: true,
            canSendPasswordReset: false
        )
        XCTAssertEqual(limitedControls.title, "Limited controls")
        XCTAssertEqual(
            limitedControls.detail,
            "Some security actions are only available for email sign in."
        )
    }

    func testAccountLegalStatusKeepsExistingCopy() {
        let missing = AccountLegalStatus(
            summaryText: nil,
            acceptedAtText: nil,
            isOutdated: false
        )
        XCTAssertEqual(missing.title, "Missing")
        XCTAssertEqual(missing.detail, "No saved legal acceptance for this account yet.")

        let outdated = AccountLegalStatus(
            summaryText: "Terms 1.0",
            acceptedAtText: "Today",
            isOutdated: true
        )
        XCTAssertEqual(outdated.title, "Outdated")
        XCTAssertEqual(
            outdated.detail,
            "Review and accept the latest terms to keep your account up to date."
        )

        let accepted = AccountLegalStatus(
            summaryText: "Terms 1.0",
            acceptedAtText: "Today",
            isOutdated: false
        )
        XCTAssertEqual(accepted.title, "Accepted")
        XCTAssertEqual(accepted.detail, "Your saved legal acceptance is current.")
    }

    func testTrailerHelperKeepsCaseInsensitivePreferredTrailerSelection() {
        let videos = [
            MovieVideo(
                id: "1",
                key: "teaser-key",
                name: "Official Teaser",
                site: "YouTube",
                type: "Teaser"
            ),
            MovieVideo(
                id: "2",
                key: "official-key",
                name: "Official Trailer",
                site: "youtube",
                type: "trailer"
            ),
            MovieVideo(
                id: "3",
                key: "backup-key",
                name: "Trailer",
                site: "YouTube",
                type: "Trailer"
            )
        ]

        XCTAssertEqual(
            TrailerHelper.preferredTrailerURL(from: videos)?.absoluteString,
            "https://www.youtube.com/watch?v=official-key"
        )
    }

    private func personDetail(gender: Int?) -> PersonDetail {
        PersonDetail(
            id: 1,
            name: "Test Person",
            birthday: nil,
            deathday: nil,
            biography: nil,
            placeOfBirth: nil,
            profilePath: nil,
            imdbId: nil,
            gender: gender,
            knownForDepartment: nil,
            alsoKnownAs: []
        )
    }
}

final class DemoMovieRepositoryContractTests: XCTestCase {
    private let repository = DemoMovieRepository()

    func testEveryDemoMovieOpensItsOwnDetailAndCredits() async throws {
        for movie in DemoCatalog.moviesList {
            let detail = try await repository.fetchMovieDetails(for: movie.id)
            let credits = try await repository.fetchMovieCredits(for: movie.id)

            XCTAssertEqual(detail.id, movie.id, "Wrong detail ID for \(movie.title)")
            XCTAssertEqual(detail.title, movie.title, "Wrong detail title for \(movie.title)")
            XCTAssertEqual(detail.overview, movie.overview)
            XCTAssertEqual(detail.posterPath, movie.posterPath)
            XCTAssertEqual(Set(detail.genreNames), Set(movie.genres ?? []))
            XCTAssertEqual(credits.id, movie.id, "Wrong credits for \(movie.title)")
        }
    }

    func testEveryVisibleCreditPersonResolvesBackToTheSameMovie() async throws {
        for movie in DemoCatalog.moviesList {
            let credits = try await repository.fetchMovieCredits(for: movie.id)
            let people = credits.cast.map { ($0.id, $0.name) }
                + credits.crew.map { ($0.id, $0.name) }

            for (personID, expectedName) in people {
                let detail = try await repository.fetchPersonDetail(for: personID)
                let filmography = try await repository.fetchPersonMovieCredits(for: personID)

                XCTAssertEqual(detail.id, personID)
                XCTAssertEqual(detail.name, expectedName)
                XCTAssertTrue(
                    filmography.contains { $0.id == movie.id && $0.title == movie.title },
                    "\(expectedName) is missing \(movie.title) from the demo filmography"
                )
            }
        }
    }

    func testRecommendationsAndSearchOnlyReturnCatalogMovies() async throws {
        let catalogIDs = Set(DemoCatalog.moviesList.map(\.id))

        for movie in DemoCatalog.moviesList {
            let recommendations = try await repository.fetchRecommendedMovies(for: movie.id)
            XCTAssertFalse(recommendations.isEmpty)
            XCTAssertFalse(recommendations.contains { $0.id == movie.id })
            XCTAssertTrue(recommendations.allSatisfy { catalogIDs.contains($0.id) })
        }

        let search = try await repository.searchMovies(query: "inception", page: 1)
        XCTAssertEqual(search.results.map(\.id), [DemoCatalog.inception.id])
        XCTAssertEqual(search.results.map(\.title), [DemoCatalog.inception.title])
    }

    func testDemoCategoriesAreCuratedInsteadOfIdenticalCopies() async throws {
        var categoryIDs = [[Int]]()

        for category in MovieCategory.allCases {
            let result = try await repository.fetchMovies(category: category, page: 1)
            categoryIDs.append(result.results.map(\.id))
        }

        XCTAssertEqual(Set(categoryIDs).count, MovieCategory.allCases.count)
    }
}
