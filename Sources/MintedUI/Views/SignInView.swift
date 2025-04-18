import SwiftUI
import Clerk

public struct SignInView: View {
    @Environment(Clerk.self) private var clerk
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var verificationCode = ""
    @State private var isVerificationCodeSent = false
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        VStack(spacing: 20) {
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
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        #endif
                    
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
        .padding()
    }
    
    private func sendVerificationCode() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                print("SignInView: Checking Clerk state")
                guard clerk.isLoaded else {
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
                print("SignInView: Checking Clerk state")
                guard clerk.isLoaded else {
                    print("SignInView: Clerk is not loaded")
                    errorMessage = "Authentication service is not ready. Please try again."
                    isLoading = false
                    return
                }
                print("SignInView: Clerk is loaded")
                
                guard let inProgressSignIn = clerk.client?.signIn else {
                    errorMessage = "No sign-in in progress"
                    return
                }
                
                let signIn = try await inProgressSignIn.attemptFirstFactor(
                    strategy: .emailCode(code: verificationCode)
                )
                
                if signIn.status == .complete, let sessionId = signIn.createdSessionId {
                    try await clerk.setActive(sessionId: sessionId)
                    
                    // Log user information
                    if let user = clerk.user {
                        print("SignInView: User signed in successfully")
                        print("User ID: \(user.id)")
                        print("Primary Email: \(user.emailAddresses.first(where: { $0.id == user.primaryEmailAddressId })?.emailAddress ?? "No email")")
                        print("Profile Image URL: \(user.imageUrl ?? "No profile image")")
                    }
                    
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
        .environment(Clerk.shared)
} 