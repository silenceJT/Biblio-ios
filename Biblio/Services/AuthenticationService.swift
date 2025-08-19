import Foundation
import Combine
import LocalAuthentication

@MainActor
class AuthenticationService: ObservableObject {
    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    @Published var biometricType: LABiometryType = .none
    
    // MARK: - Private Properties
    private let networkManager = NetworkManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Keychain Keys
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let userDataKey = "userData"
    private let biometricEnabledKey = "biometricEnabled"
    
    init() {
        setupBiometricType()
        loadStoredCredentials()
    }
    
    // MARK: - Setup
    private func setupBiometricType() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        } else {
            biometricType = .none
        }
    }
    
    // MARK: - Authentication Methods
    func register(name: String, email: String, password: String) async throws {
        await MainActor.run { 
            isLoading = true
            error = nil
        }
        
        do {
            let response: AuthResponse = try await networkManager.request(
                AuthEndpoint.register(name: name, email: email, password: password)
            )
            
            // Store credentials securely
            try await storeCredentials(response)
            
            await MainActor.run {
                self.currentUser = response.user
                self.isAuthenticated = true
                self.isLoading = false
                self.error = nil
            }
            
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        await MainActor.run { 
            isLoading = true
            error = nil
        }
        
        do {
            // Sign in with mobile API
            let response: AuthResponse = try await networkManager.request(
                AuthEndpoint.login(email: email, password: password)
            )
            
            print("🔐 AuthResponse: success=\(response.success), user=\(response.user?.email ?? "nil"), error=\(response.error ?? "none")")
            
            // Validate the response
            guard response.isSuccess, let user = response.user else {
                let errorMsg = response.errorMessage ?? "Invalid response from server"
                print("🔐 Authentication failed: \(errorMsg)")
                throw AuthError.authenticationFailed(errorMsg)
            }
            
            print("🔐 Authentication successful for user: \(user.email)")
            
            // Store credentials securely
            try await storeCredentials(response)
            
            await MainActor.run {
                print("🔐 Updating UI state: isAuthenticated = true")
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
                self.error = nil
            }
            
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    func signInWithBiometrics() async throws {
        guard biometricType != .none else {
            throw AuthError.biometricsNotAvailable
        }
        
        await MainActor.run { isLoading = true }
        
        do {
            let context = LAContext()
            let reason = "Sign in to Bibliography App"
            
            try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            
            // Biometric authentication successful, try to restore session
            try await restoreSessionFromStoredCredentials()
            
        } catch {
            await MainActor.run { isLoading = false }
            throw AuthError.biometricAuthenticationFailed
        }
    }
    
    func signOut() async {
        await MainActor.run { isLoading = true }
        
        do {
            // Call logout endpoint if we have a valid token
            if let _ = getStoredAccessToken() {
                let _: EmptyResponse = try await networkManager.request(AuthEndpoint.logout, as: EmptyResponse.self)
            }
        } catch {
            print("Logout API call failed: \(error)")
        }
        
        // Clear stored credentials
        await clearStoredCredentials()
        
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
            self.isLoading = false
            self.error = nil
        }
    }
    
    func refreshToken() async throws {
        guard let refreshToken = getStoredRefreshToken() else {
            throw AuthError.noRefreshToken
        }
        
        do {
            let request = RefreshTokenRequest(refreshToken: refreshToken)
            let response: RefreshTokenResponse = try await networkManager.request(
                AuthEndpoint.refreshToken(request.refreshToken)
            )
            
            // Store new tokens
            try await storeNewTokens(accessToken: response.accessToken, refreshToken: refreshToken)
            
        } catch {
            // Refresh failed, user needs to login again
            await signOut()
            throw AuthError.tokenRefreshFailed
        }
    }
    
    // MARK: - User Management
    func getCurrentUser() async throws -> User {
        if let user = currentUser {
            return user
        }
        
        // Try to fetch from API
        let response: AuthResponse = try await networkManager.request(AuthEndpoint.getCurrentUser)
        
        guard response.isSuccess, let user = response.user else {
            throw AuthError.invalidCredentials
        }
        
        await MainActor.run {
            self.currentUser = user
        }
        
        return user
    }
    
    func updateUserProfile(_ user: User) async throws -> User {
        let updatedUser: User = try await networkManager.request(
            UserEndpoint.updateUser(id: user.id, user)
        )
        
        await MainActor.run {
            self.currentUser = updatedUser
        }
        
        return updatedUser
    }
    
    // MARK: - Biometric Settings
    func enableBiometricAuthentication() async throws {
        guard biometricType != .none else {
            throw AuthError.biometricsNotAvailable
        }
        
        // Test biometric authentication
        let context = LAContext()
        let reason = "Enable biometric authentication"
        
        try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
        
        // Store biometric preference
        UserDefaults.standard.set(true, forKey: biometricEnabledKey)
    }
    
    func disableBiometricAuthentication() {
        UserDefaults.standard.set(false, forKey: biometricEnabledKey)
    }
    
    var isBiometricEnabled: Bool {
        UserDefaults.standard.bool(forKey: biometricEnabledKey)
    }
    
    // MARK: - Private Methods
    private func loadStoredCredentials() {
        Task {
            do {
                try await restoreSessionFromStoredCredentials()
            } catch {
                print("Failed to restore session: \(error)")
            }
        }
    }
    
    private func restoreSessionFromStoredCredentials() async throws {
        guard let _ = getStoredAccessToken(),
              let _ = getStoredUserData() else {
            throw AuthError.noStoredCredentials
        }
        
        // Validate token by making a test API call
        do {
            let response: AuthResponse = try await networkManager.request(AuthEndpoint.getCurrentUser)
            
            guard response.isSuccess, let user = response.user else {
                throw AuthError.invalidCredentials
            }
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
            }
            
        } catch {
            // Token is invalid, try to refresh
            try await refreshToken()
        }
    }
    
    private func storeCredentials(_ response: AuthResponse) async throws {
        // Store tokens in keychain if available
        if let accessToken = response.accessToken, let refreshToken = response.refreshToken {
            try await storeTokens(accessToken: accessToken, refreshToken: refreshToken)
        }
        
        // Store user data if available
        if let user = response.user {
            try await storeUserData(user)
        }
    }
    
    private func storeTokens(accessToken: String, refreshToken: String) async throws {
        // Store in NetworkManager for immediate use
        networkManager.setAccessToken(accessToken)
        
        // Store in UserDefaults for persistence (not secure for production)
        UserDefaults.standard.set(accessToken, forKey: accessTokenKey)
        UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
    }
    
    private func storeNewTokens(accessToken: String, refreshToken: String) async throws {
        try await storeTokens(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    private func storeUserData(_ user: User) async throws {
        let encoder = JSONEncoder()
        let userData = try encoder.encode(user)
        UserDefaults.standard.set(userData, forKey: userDataKey)
    }
    
    private func getStoredAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: accessTokenKey)
    }
    
    private func getStoredRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: refreshTokenKey)
    }
    
    private func getStoredUserData() -> Data? {
        return UserDefaults.standard.data(forKey: userDataKey)
    }
    
    private func clearStoredCredentials() async {
        // Clear from NetworkManager
        networkManager.clearAccessToken()
        
        // Clear from UserDefaults
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: userDataKey)
    }
    
    // MARK: - Validation
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validatePassword(_ password: String) -> Bool {
        return password.count >= 8
    }
    
    // MARK: - NextAuth.js Session Validation
    private func validateSession() async throws {
        // Call NextAuth.js session endpoint to validate the authentication
        let session: NextAuthSession = try await networkManager.request(
            AuthEndpoint.getCurrentUser
        )
        
        // Update current user with session data
        await MainActor.run {
            self.currentUser = session.user
        }
    }
}

// MARK: - Authentication Errors
enum AuthError: LocalizedError {
    case biometricsNotAvailable
    case biometricAuthenticationFailed
    case noRefreshToken
    case tokenRefreshFailed
    case noStoredCredentials
    case invalidCredentials
    case authenticationFailed(String)
    case networkError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .biometricsNotAvailable:
            return "Biometric authentication is not available on this device"
        case .biometricAuthenticationFailed:
            return "Biometric authentication failed"
        case .noRefreshToken:
            return "No refresh token available"
        case .tokenRefreshFailed:
            return "Failed to refresh authentication token"
        case .noStoredCredentials:
            return "No stored credentials found"
        case .invalidCredentials:
            return "Invalid email or password"
        case .authenticationFailed(let message):
            return message
        case .networkError:
            return "Network error occurred"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Biometric Type Extension
extension LABiometryType {
    var displayName: String {
        switch self {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        case .none:
            return "None"
        @unknown default:
            return "Unknown"
        }
    }
    
    var iconName: String {
        switch self {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "faceid"
        case .none:
            return "lock"
        @unknown default:
            return "lock"
        }
    }
}
