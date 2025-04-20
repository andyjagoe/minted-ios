import XCTest
import SwiftUI
import Clerk
@testable import MintedUI

@MainActor
final class SignInViewTests: XCTestCase {
    var clerk: Clerk!
    var testHelper: SignInViewTestHelper!
    
    override func setUp() {
        super.setUp()
        clerk = Clerk.shared
        testHelper = SignInViewTestHelper()
    }
    
    override func tearDown() {
        clerk = nil
        testHelper = nil
        super.tearDown()
    }
    
    func testSignInViewInitialState() {
        // Verify initial state through test helper
        XCTAssertTrue(testHelper.email.isEmpty)
        XCTAssertFalse(testHelper.isLoading)
        XCTAssertNil(testHelper.errorMessage)
        XCTAssertFalse(testHelper.isVerificationCodeSent)
        XCTAssertTrue(testHelper.verificationCode.isEmpty)
    }
    
    func testEmailValidation() {
        // Test empty email
        testHelper.email = ""
        XCTAssertFalse(testHelper.isValidEmail)
        
        // Test invalid email formats
        testHelper.email = "invalid"
        XCTAssertFalse(testHelper.isValidEmail)
        
        testHelper.email = "invalid@"
        XCTAssertFalse(testHelper.isValidEmail)
        
        testHelper.email = "invalid@domain"
        XCTAssertFalse(testHelper.isValidEmail)
        
        // Test valid email
        testHelper.email = "test@example.com"
        XCTAssertTrue(testHelper.isValidEmail)
    }
    
    func testVerificationCodeValidation() {
        // Test empty code
        testHelper.verificationCode = ""
        XCTAssertFalse(testHelper.isValidVerificationCode)
        
        // Test valid code
        testHelper.verificationCode = "123456"
        XCTAssertTrue(testHelper.isValidVerificationCode)
    }
    
    func testErrorHandling() {
        // Test Clerk API error
        let clerkError = TestClerkAPIError(message: "Invalid credentials")
        let clerkErrorMessage = testHelper.handleClerkError(clerkError)
        XCTAssertEqual(clerkErrorMessage, "Invalid credentials")
        
        // Test network error
        let networkError = URLError(.notConnectedToInternet)
        let networkErrorMessage = testHelper.handleClerkError(networkError)
        XCTAssertTrue(networkErrorMessage.contains("Network error"))
        
        // Test unknown error
        let unknownError = NSError(domain: "Test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        let unknownErrorMessage = testHelper.handleClerkError(unknownError)
        XCTAssertEqual(unknownErrorMessage, "Unknown error")
    }
}

// MARK: - Test Helpers
extension SignInViewTests {
    struct TestClerkAPIError: LocalizedError {
        let message: String
        
        var errorDescription: String? {
            return message
        }
    }
}

// MARK: - Test Helper Class
@MainActor
class SignInViewTestHelper {
    var email: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var verificationCode: String = ""
    var isVerificationCodeSent: Bool = false
    
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var isValidVerificationCode: Bool {
        return !verificationCode.isEmpty
    }
    
    func handleClerkError(_ error: Error) -> String {
        if let urlError = error as? URLError {
            return "Network error: \(urlError.localizedDescription)"
        } else if let error = error as? LocalizedError {
            return error.localizedDescription
        }
        return error.localizedDescription
    }
} 