import Foundation
import Combine
import SwiftUI

@MainActor
class RegistrationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var acceptedTerms = false
    @Published var isLoading = false
    @Published var error: String?
    @Published var showPassword = false
    @Published var showConfirmPassword = false
    
    // MARK: - Private Properties
    private let authenticationService = AuthenticationService()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var isFormValid: Bool {
        !name.isEmpty && 
        !email.isEmpty && 
        !password.isEmpty && 
        !confirmPassword.isEmpty && 
        authenticationService.validateEmail(email) && 
        authenticationService.validatePassword(password) &&
        password == confirmPassword &&
        acceptedTerms
    }
    
    var nameValidationMessage: String? {
        if name.isEmpty { return nil }
        if name.count < 2 {
            return "Name must be at least 2 characters"
        }
        return nil
    }
    
    var emailValidationMessage: String? {
        if email.isEmpty { return nil }
        if !authenticationService.validateEmail(email) {
            return "Please enter a valid email address"
        }
        return nil
    }
    
    var passwordValidationMessage: String? {
        if password.isEmpty { return nil }
        if !authenticationService.validatePassword(password) {
            return "Password must be at least 8 characters"
        }
        return nil
    }
    
    var confirmPasswordValidationMessage: String? {
        if confirmPassword.isEmpty { return nil }
        if password != confirmPassword {
            return "Passwords do not match"
        }
        return nil
    }
    
    var nameFieldColor: Color {
        if name.isEmpty { return .primary }
        return nameValidationMessage != nil ? .red : .green
    }
    
    var emailFieldColor: Color {
        if email.isEmpty { return .primary }
        return emailValidationMessage != nil ? .red : .green
    }
    
    var passwordFieldColor: Color {
        if password.isEmpty { return .primary }
        return passwordValidationMessage != nil ? .red : .green
    }
    
    var confirmPasswordFieldColor: Color {
        if confirmPassword.isEmpty { return .primary }
        return confirmPasswordValidationMessage != nil ? .red : .green
    }
    
    var canCreateAccount: Bool {
        isFormValid && !isLoading
    }
    
    var createAccountButtonTitle: String {
        isLoading ? "Creating Account..." : "Create Account"
    }
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Clear error when user starts typing
        $name
            .dropFirst()
            .sink { [weak self] _ in
                self?.clearError()
            }
            .store(in: &cancellables)
        
        $email
            .dropFirst()
            .sink { [weak self] _ in
                self?.clearError()
            }
            .store(in: &cancellables)
        
        $password
            .dropFirst()
            .sink { [weak self] _ in
                self?.clearError()
            }
            .store(in: &cancellables)
        
        $confirmPassword
            .dropFirst()
            .sink { [weak self] _ in
                self?.clearError()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func createAccount() async {
        guard isFormValid else {
            error = "Please fill in all fields correctly"
            return
        }
        
        do {
            await MainActor.run {
                isLoading = true
                error = nil
            }
            
            // Call actual registration API
            try await authenticationService.register(name: name, email: email, password: password)
            
            await MainActor.run {
                isLoading = false
                // Registration successful - dismiss view
                // The user is now authenticated and will be redirected to main app
            }
            
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func clearError() {
        error = nil
    }
    
    func resetForm() {
        name = ""
        email = ""
        password = ""
        confirmPassword = ""
        acceptedTerms = false
        error = nil
        showPassword = false
        showConfirmPassword = false
    }
}
