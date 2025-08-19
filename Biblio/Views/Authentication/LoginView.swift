import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showingRegistration = false
    
    init(authenticationService: AuthenticationService) {
        self._viewModel = StateObject(wrappedValue: LoginViewModel(authenticationService: authenticationService))
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section
                        headerSection
                            .frame(height: geometry.size.height * 0.3)
                        
                        // Form Section
                        formSection
                            .frame(minHeight: geometry.size.height * 0.7)
                    }
                }
            }
            .background(backgroundGradient)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingRegistration) {
            RegistrationView()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            // App Icon
            Image(systemName: "book.closed.fill")
                .font(.system(size: 80))
                .foregroundColor(.white)
                .padding(.top, 40)
            
            // App Title
            VStack(spacing: 8) {
                Text("Bibliography")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Your Research, Organized")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: 30) {
            // Welcome Text
            VStack(spacing: 8) {
                Text("Welcome Back")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Sign in to continue to your bibliography")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Login Form
            VStack(spacing: 20) {
                // Email Field
                emailField
                
                // Password Field
                passwordField
                
                // Remember Me & Forgot Password
                HStack {
                    Toggle("Remember Me", isOn: $viewModel.rememberMe)
                        .font(.subheadline)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    Spacer()
                    
                    Button("Forgot Password?") {
                        // TODO: Implement forgot password
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                
                // Sign In Button
                signInButton
                
                // Biometric Sign In
                if viewModel.biometricType != .none {
                    biometricSignInButton
                }
                
                // Error Message
                if let error = viewModel.error {
                    errorView
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Footer
            footerSection
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
    
    // MARK: - Email Field
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                TextField("Email Address", text: $viewModel.email)
                    .textFieldStyle(PlainTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .textContentType(.emailAddress)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.emailFieldColor, lineWidth: 1)
                    )
            )
            
            if let message = viewModel.emailValidationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 4)
            }
        }
    }
    
    // MARK: - Password Field
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                if viewModel.showPassword {
                    TextField("Password", text: $viewModel.password)
                        .textFieldStyle(PlainTextFieldStyle())
                        .textContentType(.password)
                } else {
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(PlainTextFieldStyle())
                        .textContentType(.password)
                }
                
                Button(action: {
                    viewModel.showPassword.toggle()
                }) {
                    Image(systemName: viewModel.showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.passwordFieldColor, lineWidth: 1)
                    )
            )
            
            if let message = viewModel.passwordValidationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 4)
            }
        }
    }
    
    // MARK: - Sign In Button
    private var signInButton: some View {
        Button(action: {
            Task {
                await viewModel.signIn()
            }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                
                Text(viewModel.signInButtonTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(!viewModel.canSignIn)
        .opacity(viewModel.canSignIn ? 1.0 : 0.6)
    }
    
    // MARK: - Biometric Sign In Button
    private var biometricSignInButton: some View {
        Button(action: {
            Task {
                await viewModel.signInWithBiometrics()
            }
        }) {
            HStack {
                Image(systemName: viewModel.biometricIconName)
                    .font(.headline)
                
                Text("Sign in with \(viewModel.biometricDisplayName)")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .disabled(viewModel.isLoading)
    }
    
    // MARK: - Error View
    private var errorView: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text(viewModel.error ?? "")
                .font(.subheadline)
                .foregroundColor(.red)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Button("Dismiss") {
                viewModel.clearError()
            }
            .font(.caption)
            .foregroundColor(.red)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.red.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Footer Section
    private var footerSection: some View {
        VStack(spacing: 16) {
            Divider()
                .padding(.horizontal, 30)
            
            HStack {
                Text("Don't have an account?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button("Sign Up") {
                    showingRegistration = true
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            }
            
            Text("By signing in, you agree to our Terms of Service and Privacy Policy")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemBackground),
                Color(.systemGray6)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Preview
#Preview {
    LoginView(authenticationService: AuthenticationService())
        .preferredColorScheme(.light)
}

#Preview {
    LoginView(authenticationService: AuthenticationService())
        .preferredColorScheme(.dark)
}
