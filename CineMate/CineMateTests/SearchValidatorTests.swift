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
}
