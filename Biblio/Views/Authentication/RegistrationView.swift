import SwiftUI

struct RegistrationView: View {
    @StateObject private var viewModel = RegistrationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section
                        headerSection
                            .frame(height: geometry.size.height * 0.25)
                        
                        // Form Section
                        formSection
                            .frame(minHeight: geometry.size.height * 0.75)
                    }
                }
            }
            .background(backgroundGradient)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            // App Icon
            Image(systemName: "person.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .padding(.top, 20)
            
            // App Title
            VStack(spacing: 8) {
                Text("Create Account")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Join Bibliography App")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.green, Color.blue]),
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
                Text("Get Started")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Create your account to start organizing your research")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Registration Form
            VStack(spacing: 20) {
                // Name Field
                nameField
                
                // Email Field
                emailField
                
                // Password Field
                passwordField
                
                // Confirm Password Field
                confirmPasswordField
                
                // Terms and Conditions
                termsAndConditions
                
                // Create Account Button
                createAccountButton
                
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
    
    // MARK: - Name Field
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.green)
                    .frame(width: 20)
                
                TextField("Full Name", text: $viewModel.name)
                    .textFieldStyle(PlainTextFieldStyle())
                    .textContentType(.name)
                    .autocapitalization(.words)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.nameFieldColor, lineWidth: 1)
                    )
            )
            
            if let message = viewModel.nameValidationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 4)
            }
        }
    }
    
    // MARK: - Email Field
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.green)
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
                    .foregroundColor(.green)
                    .frame(width: 20)
                
                if viewModel.showPassword {
                    TextField("Password", text: $viewModel.password)
                        .textFieldStyle(PlainTextFieldStyle())
                        .textContentType(.newPassword)
                } else {
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(PlainTextFieldStyle())
                        .textContentType(.newPassword)
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
    
    // MARK: - Confirm Password Field
    private var confirmPasswordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.green)
                    .frame(width: 20)
                
                if viewModel.showConfirmPassword {
                    TextField("Confirm Password", text: $viewModel.confirmPassword)
                        .textFieldStyle(PlainTextFieldStyle())
                        .textContentType(.newPassword)
                } else {
                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .textFieldStyle(PlainTextFieldStyle())
                        .textContentType(.newPassword)
                }
                
                Button(action: {
                    viewModel.showConfirmPassword.toggle()
                }) {
                    Image(systemName: viewModel.showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.confirmPasswordFieldColor, lineWidth: 1)
                    )
            )
            
            if let message = viewModel.confirmPasswordValidationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 4)
            }
        }
    }
    
    // MARK: - Terms and Conditions
    private var termsAndConditions: some View {
        HStack {
            Toggle("", isOn: $viewModel.acceptedTerms)
                .toggleStyle(SwitchToggleStyle(tint: .green))
            
            Text("I agree to the ")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Terms of Service") {
                // TODO: Show terms
            }
            .font(.subheadline)
            .foregroundColor(.green)
            
            Text(" and ")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Privacy Policy") {
                // TODO: Show privacy policy
            }
            .font(.subheadline)
            .foregroundColor(.green)
        }
    }
    
    // MARK: - Create Account Button
    private var createAccountButton: some View {
        Button(action: {
            Task {
                await viewModel.createAccount()
            }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "person.badge.plus")
                        .font(.headline)
                }
                
                Text(viewModel.createAccountButtonTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.green, Color.blue]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(!viewModel.canCreateAccount)
        .opacity(viewModel.canCreateAccount ? 1.0 : 0.6)
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
                Text("Already have an account?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button("Sign In") {
                    dismiss()
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
            }
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
    RegistrationView()
        .preferredColorScheme(.light)
}

#Preview {
    RegistrationView()
        .preferredColorScheme(.dark)
}
