# iOS Migration Plan for Bibliography App

## Overview
This document outlines the comprehensive plan to migrate the Bibliography web application to a native iOS app using SwiftUI and modern iOS development practices.

## Current Web App Architecture Analysis

### Backend (Keep as-is)
- ✅ Next.js API routes (`/api/bibliography`, `/api/auth`, etc.)
- ✅ MongoDB database with existing schemas
- ✅ NextAuth.js authentication
- ✅ Existing data models and business logic

### Frontend (Migrate to iOS)
- ✅ React components → SwiftUI Views
- ✅ TypeScript interfaces → Swift structs/protocols
- ✅ React hooks → SwiftUI @State, @ObservableObject
- ✅ Tailwind CSS → SwiftUI styling
- ✅ Client-side routing → NavigationView/NavigationStack

## Phase 1: Project Setup & Foundation (Week 1-2)

### 1.1 Development Environment Setup
- [ ] Install Xcode 15+ and iOS 17+ SDK
- [ ] Create new iOS project with SwiftUI
- [ ] Set up Git repository for iOS app
- [ ] Configure development team and certificates
- [ ] Set up CI/CD pipeline (GitHub Actions/Fastlane)

### 1.2 Project Structure
```
BibliographyApp/
├── BibliographyApp/
│   ├── App/
│   │   ├── BibliographyAppApp.swift
│   │   └── AppDelegate.swift
│   ├── Models/
│   │   ├── Bibliography.swift
│   │   ├── User.swift
│   │   └── AuthModels.swift
│   ├── Views/
│   │   ├── Authentication/
│   │   ├── Dashboard/
│   │   ├── Bibliography/
│   │   ├── UserManagement/
│   │   └── Common/
│   ├── ViewModels/
│   ├── Services/
│   ├── Utils/
│   └── Resources/
└── BibliographyAppTests/
```

### 1.3 Dependencies Setup
- [ ] Swift Package Manager configuration
- [ ] Core dependencies:
  - [ ] Alamofire (HTTP networking)
  - [ ] SwiftyJSON (JSON parsing)
  - [ ] KeychainAccess (secure storage)
  - [ ] Combine (reactive programming)

## Phase 2: Data Models & API Integration (Week 2-3)

### 2.1 Core Data Models
```swift
// Bibliography.swift
struct Bibliography: Codable, Identifiable {
    let id: String
    let title: String
    let authors: [String]
    let publicationYear: Int?
    let journal: String?
    let doi: String?
    let abstract: String?
    let keywords: [String]
    let createdAt: Date
    let updatedAt: Date
    let userId: String
}

// User.swift
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String?
    let role: UserRole
    let createdAt: Date
}

enum UserRole: String, Codable {
    case user = "user"
    case admin = "admin"
    case superAdmin = "super_admin"
}
```

### 2.2 API Service Layer
```swift
// APIService.swift
class APIService: ObservableObject {
    private let baseURL = "https://your-domain.com/api"
    private let session = URLSession.shared
    
    func fetchBibliographies(page: Int, limit: Int) async throws -> BibliographyResponse
    func createBibliography(_ bibliography: Bibliography) async throws -> Bibliography
    func updateBibliography(_ bibliography: Bibliography) async throws -> Bibliography
    func deleteBibliography(id: String) async throws
    func searchBibliographies(query: String) async throws -> BibliographyResponse
}
```

### 2.3 Authentication Service
```swift
// AuthService.swift
class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    func signIn(email: String, password: String) async throws
    func signOut() async throws
    func refreshToken() async throws
    func getCurrentUser() async throws -> User
}
```

## Phase 3: Core UI Components (Week 3-4)

### 3.1 Navigation Structure
```swift
// MainTabView.swift
struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Dashboard")
                }
            
            BibliographyListView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Bibliography")
                }
            
            if userRole == .admin || userRole == .superAdmin {
                UserManagementView()
                    .tabItem {
                        Image(systemName: "person.2")
                        Text("Users")
                    }
            }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}
```

### 3.2 Bibliography List View
```swift
// BibliographyListView.swift
struct BibliographyListView: View {
    @StateObject private var viewModel = BibliographyListViewModel()
    @State private var searchText = ""
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.bibliographies) { bibliography in
                    BibliographyRowView(bibliography: bibliography)
                        .onTapGesture {
                            viewModel.selectBibliography(bibliography)
                        }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Bibliography")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        showingAddSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddBibliographyView()
            }
        }
    }
}
```

### 3.3 Bibliography Detail View
```swift
// BibliographyDetailView.swift
struct BibliographyDetailView: View {
    let bibliography: Bibliography
    @StateObject private var viewModel = BibliographyDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                Text(bibliography.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                // Authors
                if !bibliography.authors.isEmpty {
                    Text("Authors: \(bibliography.authors.joined(separator: ", "))")
                        .font(.headline)
                }
                
                // Publication details
                if let year = bibliography.publicationYear {
                    Text("Year: \(year)")
                }
                
                if let journal = bibliography.journal {
                    Text("Journal: \(journal)")
                }
                
                // Abstract
                if let abstract = bibliography.abstract {
                    Text("Abstract")
                        .font(.headline)
                    Text(abstract)
                }
                
                // Keywords
                if !bibliography.keywords.isEmpty {
                    Text("Keywords: \(bibliography.keywords.joined(separator: ", "))")
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    viewModel.showEditSheet = true
                }
            }
        }
    }
}
```

## Phase 4: Authentication & User Management (Week 4-5)

### 4.1 Login View
```swift
// LoginView.swift
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo/Title
                Text("Bibliography App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Email field
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                // Password field
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Login button
                Button("Sign In") {
                    Task {
                        await viewModel.signIn(email: email, password: password)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
                
                if viewModel.isLoading {
                    ProgressView()
                }
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
    }
}
```

### 4.2 User Management (Admin)
```swift
// UserManagementView.swift
struct UserManagementView: View {
    @StateObject private var viewModel = UserManagementViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.users) { user in
                    UserRowView(user: user) {
                        viewModel.toggleUserRole(user)
                    }
                }
            }
            .navigationTitle("User Management")
            .refreshable {
                await viewModel.loadUsers()
            }
        }
    }
}
```

## Phase 5: Advanced Features (Week 5-6)

### 5.1 Offline Support
- [ ] Core Data integration for local storage
- [ ] Sync mechanism for offline changes
- [ ] Conflict resolution strategies
- [ ] Background sync with CloudKit

### 5.2 Search & Filtering
```swift
// Search functionality
extension BibliographyListViewModel {
    func searchBibliographies(query: String) async {
        // Implement search with debouncing
        // Support for multiple search criteria
        // Local search for offline mode
    }
    
    func filterByYear(_ year: Int) {
        // Filter bibliographies by publication year
    }
    
    func filterByAuthor(_ author: String) {
        // Filter by author name
    }
}
```

### 5.3 Export & Sharing
```swift
// Export functionality
class ExportService {
    func exportToBibTeX(_ bibliographies: [Bibliography]) -> String
    func exportToCSV(_ bibliographies: [Bibliography]) -> String
    func shareBibliography(_ bibliography: Bibliography)
    func generatePDF(_ bibliographies: [Bibliography])
}
```

## Phase 6: Polish & Testing (Week 6-7)

### 6.1 UI/UX Polish
- [ ] Custom color scheme and typography
- [ ] Smooth animations and transitions
- [ ] Accessibility support (VoiceOver, Dynamic Type)
- [ ] Dark mode support
- [ ] iPad optimization

### 6.2 Performance Optimization
- [ ] Lazy loading for large lists
- [ ] Image caching and optimization
- [ ] Memory management
- [ ] Background task handling

### 6.3 Testing Strategy
- [ ] Unit tests for ViewModels and Services
- [ ] UI tests for critical user flows
- [ ] Integration tests for API calls
- [ ] Performance testing
- [ ] Accessibility testing

## Phase 7: Deployment & Distribution (Week 7-8)

### 7.1 App Store Preparation
- [ ] App Store Connect setup
- [ ] App icon and screenshots
- [ ] App description and metadata
- [ ] Privacy policy and terms of service
- [ ] App review submission

### 7.2 Production Deployment
- [ ] Production API endpoint configuration
- [ ] SSL certificate setup
- [ ] Analytics integration (Firebase Analytics)
- [ ] Crash reporting (Crashlytics)
- [ ] Beta testing with TestFlight

## Technical Considerations

### Security
- [ ] Keychain integration for secure storage
- [ ] Certificate pinning for API calls
- [ ] Biometric authentication (Face ID/Touch ID)
- [ ] App Transport Security (ATS)

### Performance
- [ ] Efficient list rendering with LazyVStack
- [ ] Background fetch for data updates
- [ ] Image caching with NSCache
- [ ] Memory-efficient data structures

### Accessibility
- [ ] VoiceOver support for all UI elements
- [ ] Dynamic Type support
- [ ] High contrast mode
- [ ] Reduced motion support

## Success Metrics
- [ ] App Store rating > 4.5 stars
- [ ] Crash rate < 1%
- [ ] App launch time < 2 seconds
- [ ] 95% of users complete onboarding
- [ ] 80% of users use app weekly

## Timeline Summary
- **Week 1-2**: Project setup and foundation
- **Week 2-3**: Data models and API integration
- **Week 3-4**: Core UI components
- **Week 4-5**: Authentication and user management
- **Week 5-6**: Advanced features
- **Week 6-7**: Polish and testing
- **Week 7-8**: Deployment and distribution

**Total Estimated Time: 8 weeks**
