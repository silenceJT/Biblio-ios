import SwiftUI

struct AppCoordinator: View {
    @StateObject private var authenticationService = AuthenticationService()
    
    var body: some View {
        Group {
            if authenticationService.isAuthenticated {
                // Main App
                MainAppView()
                    .environmentObject(authenticationService)
            } else {
                // Authentication Flow
                LoginView(authenticationService: authenticationService)
                    .environmentObject(authenticationService)
            }
        }
        .onAppear {
            // Check for stored credentials on app launch
            checkStoredCredentials()
        }
    }
    
    private func checkStoredCredentials() {
        // The AuthenticationService will automatically try to restore the session
        // when it's initialized
    }
}

// MARK: - Main App View
struct MainAppView: View {
    @EnvironmentObject var authenticationService: AuthenticationService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Bibliography Tab
            NavigationView {
                BibliographyListView()
                    .navigationTitle("Bibliography")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Profile") {
                                // TODO: Show profile view
                            }
                        }
                    }
            }
            .tabItem {
                Image(systemName: "book.closed")
                Text("Bibliography")
            }
            .tag(0)
            
            // Search Tab
            NavigationView {
                SearchView()
                    .navigationTitle("Search")
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            .tag(1)
            
            // Settings Tab
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(2)
        }
        .accentColor(.blue)
    }
}

// MARK: - Search View (Placeholder)
struct SearchView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Advanced Search")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Search functionality coming in Phase 3")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var authenticationService: AuthenticationService
    @State private var showingLogoutAlert = false
    
    var body: some View {
        List {
            // User Profile Section
            Section("Profile") {
                if let user = authenticationService.currentUser {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name ?? "User")
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(user.role.displayName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 4)
                }
                
                Button("Edit Profile") {
                    // TODO: Navigate to profile edit
                }
            }
            
            // Security Section
            Section("Security") {
                if authenticationService.biometricType != .none {
                    HStack {
                        Image(systemName: authenticationService.biometricType.iconName)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(authenticationService.biometricType.displayName) Authentication")
                            Text(authenticationService.isBiometricEnabled ? "Enabled" : "Disabled")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { authenticationService.isBiometricEnabled },
                            set: { isEnabled in
                                Task {
                                    if isEnabled {
                                        try? await authenticationService.enableBiometricAuthentication()
                                    } else {
                                        authenticationService.disableBiometricAuthentication()
                                    }
                                }
                            }
                        ))
                    }
                }
                
                Button("Change Password") {
                    // TODO: Navigate to password change
                }
            }
            
            // App Settings Section
            Section("App") {
                Button("About") {
                    // TODO: Show about view
                }
                
                Button("Privacy Policy") {
                    // TODO: Show privacy policy
                }
                
                Button("Terms of Service") {
                    // TODO: Show terms
                }
            }
            
            // Account Section
            Section {
                Button("Sign Out") {
                    showingLogoutAlert = true
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Settings")
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                Task {
                    await authenticationService.signOut()
                }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

// MARK: - Preview
#Preview {
    AppCoordinator()
}
