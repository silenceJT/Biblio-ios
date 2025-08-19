import Foundation
import Combine
import SwiftUI
import LocalAuthentication

@MainActor
class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: String?
    @Published var showPassword = false
    @Published var rememberMe = false
    
    // MARK: - Private Properties
    private let authenticationService: AuthenticationService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && 
        authenticationService.validateEmail(email) && 
        authenticationService.validatePassword(password)
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
    
    // MARK: - Initialization
    init(authenticationService: AuthenticationService) {
        self.authenticationService = authenticationService
        setupBindings()
        loadSavedCredentials()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Clear error when user starts typing
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
        
        // Observe authentication service
        authenticationService.$error
            .assign(to: \.error, on: self)
            .store(in: &cancellables)
        
        authenticationService.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func signIn() async {
        guard isFormValid else {
            error = "Please fill in all fields correctly"
            return
        }
        
        do {
            try await authenticationService.signIn(email: email, password: password)
            
            if rememberMe {
                saveCredentials()
            }
            
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func signInWithBiometrics() async {
        do {
            try await authenticationService.signInWithBiometrics()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func clearError() {
        error = nil
    }
    
    func resetForm() {
        email = ""
        password = ""
        error = nil
        showPassword = false
    }
    
    // MARK: - Private Methods
    private func loadSavedCredentials() {
        // Load saved email if available
        if let savedEmail = UserDefaults.standard.string(forKey: "savedEmail") {
            email = savedEmail
            rememberMe = true
        }
    }
    
    private func saveCredentials() {
        UserDefaults.standard.set(email, forKey: "savedEmail")
    }
    
    private func clearSavedCredentials() {
        UserDefaults.standard.removeObject(forKey: "savedEmail")
    }
}

// MARK: - Form Validation Extensions
extension LoginViewModel {
    var emailFieldColor: Color {
        if email.isEmpty { return .primary }
        return emailValidationMessage != nil ? .red : .green
    }
    
    var passwordFieldColor: Color {
        if password.isEmpty { return .primary }
        return passwordValidationMessage != nil ? .red : .green
    }
    
    var canSignIn: Bool {
        isFormValid && !isLoading
    }
    
    var signInButtonTitle: String {
        isLoading ? "Signing In..." : "Sign In"
    }
    
    var biometricType: LABiometryType {
        authenticationService.biometricType
    }
    
    var biometricDisplayName: String {
        authenticationService.biometricType.displayName
    }
    
    var biometricIconName: String {
        authenticationService.biometricType.iconName
    }
}
