import SwiftUI
import Clerk

public struct SignInView: View {
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var verificationCode = ""
    @State private var isVerificationCodeSent = false
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        VStack(spacing: 20) {
            if !Clerk.shared.isLoaded {
                ProgressView("Initializing...")
            } else {
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.callout)
                }
                
                VStack(spacing: 15) {
                    if !isVerificationCodeSent {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.emailAddress)
                            .textCase(.lowercase)
                        
                        Button(action: sendVerificationCode) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Send Verification Code")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoading || email.isEmpty)
                    } else {
                        Text("Enter the verification code sent to \(email)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 8)
                        
                        TextField("Verification Code", text: $verificationCode)
                            .textFieldStyle(.roundedBorder)
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                        
                        Button(action: verifyCode) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Verify Code")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoading || verificationCode.isEmpty)
                        
                        Button("Send new code") {
                            sendVerificationCode()
                        }
                        .font(.callout)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .task {
            do {
                print("SignInView: Starting Clerk configuration")
                try await ClerkConfig.configure()
                print("SignInView: Clerk configuration completed")
                
                if !Clerk.shared.isLoaded {
                    print("SignInView: Clerk is not loaded after configuration")
                    errorMessage = "Failed to initialize authentication service. Please try again later."
                }
            } catch {
                print("SignInView: Clerk configuration failed: \(error)")
                errorMessage = "Failed to initialize authentication service: \(error.localizedDescription)"
            }
        }
    }
    
    private func sendVerificationCode() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                print("SignInView: Checking Clerk state")
                guard Clerk.shared.isLoaded else {
                    print("SignInView: Clerk is not loaded")
                    errorMessage = "Authentication service is not ready. Please try again."
                    isLoading = false
                    return
                }
                print("SignInView: Clerk is loaded")
                
                print("Attempting to create sign-in with email: \(email)")
                let signIn = try await SignIn.create(strategy: .identifier(email))
                print("Sign-in created, preparing first factor")
                try await signIn.prepareFirstFactor(strategy: .emailCode())
                print("First factor prepared successfully")
                isVerificationCodeSent = true
            } catch {
                print("Error during sign-in: \(error)")
                if let urlError = error as? URLError {
                    print("URL Error details: \(urlError)")
                    errorMessage = "Network error: \(urlError.localizedDescription)"
                } else {
                    errorMessage = handleClerkError(error)
                }
            }
            isLoading = false
        }
    }
    
    private func verifyCode() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                guard let inProgressSignIn = Clerk.shared.client?.signIn else {
                    errorMessage = "No sign-in in progress"
                    return
                }
                
                let signIn = try await inProgressSignIn.attemptFirstFactor(
                    strategy: .emailCode(code: verificationCode)
                )
                
                if signIn.status == .complete, let sessionId = signIn.createdSessionId {
                    try await Clerk.shared.setActive(sessionId: sessionId)
                    dismiss()
                }
            } catch {
                errorMessage = handleClerkError(error)
            }
            isLoading = false
        }
    }
    
    private func handleClerkError(_ error: Error) -> String {
        if let clerkError = error as? ClerkAPIError {
            return clerkError.message ?? "An error occurred"
        }
        return error.localizedDescription
    }
}

#Preview {
    SignInView()
} 