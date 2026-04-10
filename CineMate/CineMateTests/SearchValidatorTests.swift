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
