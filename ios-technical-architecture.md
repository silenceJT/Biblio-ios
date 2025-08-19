# iOS Technical Architecture

## Architecture Overview

### Design Pattern: MVVM + Combine
We'll use the Model-View-ViewModel (MVVM) pattern with Combine framework for reactive programming, ensuring clean separation of concerns and testable code.

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│       View      │◄──►│   ViewModel      │◄──►│   Model/Service │
│   (SwiftUI)     │    │  (@Observable)   │    │   (API/Data)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Core Architecture Components

### 1. Data Layer

#### 1.1 Network Layer
```swift
// NetworkManager.swift
class NetworkManager {
    static let shared = NetworkManager()
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try endpoint.asURLRequest()
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// APIEndpoint.swift
enum APIEndpoint {
    case bibliographies(page: Int, limit: Int)
    case bibliography(id: String)
    case createBibliography(Bibliography)
    case updateBibliography(Bibliography)
    case deleteBibliography(id: String)
    case searchBibliographies(query: String)
    case login(email: String, password: String)
    case logout
    case users
    case user(id: String)
    
    var path: String {
        switch self {
        case .bibliographies:
            return "/bibliography"
        case .bibliography(let id):
            return "/bibliography/\(id)"
        case .createBibliography:
            return "/bibliography"
        case .updateBibliography:
            return "/bibliography"
        case .deleteBibliography(let id):
            return "/bibliography/\(id)"
        case .searchBibliographies:
            return "/bibliography"
        case .login:
            return "/auth/login"
        case .logout:
            return "/auth/logout"
        case .users:
            return "/users"
        case .user(let id):
            return "/users/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .bibliographies, .bibliography, .searchBibliographies, .users, .user:
            return .GET
        case .createBibliography, .login:
            return .POST
        case .updateBibliography:
            return .PUT
        case .deleteBibliography, .logout:
            return .DELETE
        }
    }
}
```

#### 1.2 Local Storage
```swift
// CoreDataManager.swift
class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BibliographyApp")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Core Data save error: \(error)")
            }
        }
    }
}

// BibliographyEntity+CoreDataClass.swift
@objc(BibliographyEntity)
public class BibliographyEntity: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var authors: [String]
    @NSManaged public var publicationYear: Int32
    @NSManaged public var journal: String?
    @NSManaged public var doi: String?
    @NSManaged public var abstract: String?
    @NSManaged public var keywords: [String]
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var userId: String
    @NSManaged public var isSynced: Bool
}
```

### 2. Service Layer

#### 2.1 Bibliography Service
```swift
// BibliographyService.swift
class BibliographyService: ObservableObject {
    private let networkManager = NetworkManager.shared
    private let coreDataManager = CoreDataManager.shared
    
    @Published var bibliographies: [Bibliography] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func fetchBibliographies(page: Int = 1, limit: Int = 20) async {
        await MainActor.run { isLoading = true }
        
        do {
            let response: BibliographyResponse = try await networkManager.request(
                .bibliographies(page: page, limit: limit)
            )
            
            await MainActor.run {
                self.bibliographies = response.data
                self.isLoading = false
                self.error = nil
            }
            
            // Cache to Core Data
            await cacheBibliographies(response.data)
            
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func createBibliography(_ bibliography: Bibliography) async throws -> Bibliography {
        let created: Bibliography = try await networkManager.request(
            .createBibliography(bibliography)
        )
        
        await MainActor.run {
            self.bibliographies.append(created)
        }
        
        return created
    }
    
    func searchBibliographies(query: String) async {
        await MainActor.run { isLoading = true }
        
        do {
            let response: BibliographyResponse = try await networkManager.request(
                .searchBibliographies(query: query)
            )
            
            await MainActor.run {
                self.bibliographies = response.data
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func cacheBibliographies(_ bibliographies: [Bibliography]) async {
        // Implementation for caching to Core Data
    }
}
```

#### 2.2 Authentication Service
```swift
// AuthenticationService.swift
class AuthenticationService: ObservableObject {
    private let networkManager = NetworkManager.shared
    private let keychain = Keychain(service: "com.bibliographyapp")
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    init() {
        loadStoredCredentials()
    }
    
    func signIn(email: String, password: String) async throws {
        await MainActor.run { isLoading = true }
        
        do {
            let loginRequest = LoginRequest(email: email, password: password)
            let response: AuthResponse = try await networkManager.request(
                .login(email: email, password: password)
            )
            
            // Store credentials securely
            try keychain.set(response.accessToken, key: "accessToken")
            try keychain.set(response.refreshToken, key: "refreshToken")
            
            await MainActor.run {
                self.currentUser = response.user
                self.isAuthenticated = true
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.isLoading = false
                throw error
            }
        }
    }
    
    func signOut() async {
        do {
            try await networkManager.request(.logout)
        } catch {
            print("Logout error: \(error)")
        }
        
        // Clear stored credentials
        try? keychain.remove("accessToken")
        try? keychain.remove("refreshToken")
        
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
    
    private func loadStoredCredentials() {
        // Load stored tokens and validate
    }
}
```

### 3. ViewModel Layer

#### 3.1 Bibliography List ViewModel
```swift
// BibliographyListViewModel.swift
@MainActor
class BibliographyListViewModel: ObservableObject {
    @Published var bibliographies: [Bibliography] = []
    @Published var filteredBibliographies: [Bibliography] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText = ""
    @Published var selectedFilters: BibliographyFilters = BibliographyFilters()
    
    private let bibliographyService = BibliographyService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        Task {
            await loadBibliographies()
        }
    }
    
    private func setupBindings() {
        // Combine search text with filters
        Publishers.CombineLatest($searchText, $selectedFilters)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText, filters in
                self?.applyFiltersAndSearch(searchText: searchText, filters: filters)
            }
            .store(in: &cancellables)
    }
    
    func loadBibliographies() async {
        await bibliographyService.fetchBibliographies()
        
        // Observe service changes
        bibliographyService.$bibliographies
            .assign(to: \.bibliographies, on: self)
            .store(in: &cancellables)
        
        bibliographyService.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        bibliographyService.$error
            .assign(to: \.error, on: self)
            .store(in: &cancellables)
    }
    
    func refresh() async {
        await loadBibliographies()
    }
    
    func deleteBibliography(_ bibliography: Bibliography) async {
        do {
            try await bibliographyService.deleteBibliography(bibliography.id)
            await loadBibliographies()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func applyFiltersAndSearch(searchText: String, filters: BibliographyFilters) {
        var filtered = bibliographies
        
        // Apply search
        if !searchText.isEmpty {
            filtered = filtered.filter { bibliography in
                bibliography.title.localizedCaseInsensitiveContains(searchText) ||
                bibliography.authors.contains { author in
                    author.localizedCaseInsensitiveContains(searchText)
                } ||
                bibliography.keywords.contains { keyword in
                    keyword.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        
        // Apply filters
        if let year = filters.year {
            filtered = filtered.filter { $0.publicationYear == year }
        }
        
        if !filters.authors.isEmpty {
            filtered = filtered.filter { bibliography in
                bibliography.authors.contains { author in
                    filters.authors.contains(author)
                }
            }
        }
        
        filteredBibliographies = filtered
    }
}

// BibliographyFilters.swift
struct BibliographyFilters {
    var year: Int?
    var authors: [String] = []
    var journals: [String] = []
    var keywords: [String] = []
}
```

### 4. View Layer

#### 4.1 Custom SwiftUI Components
```swift
// BibliographyCardView.swift
struct BibliographyCardView: View {
    let bibliography: Bibliography
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text(bibliography.title)
                .font(.headline)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            // Authors
            if !bibliography.authors.isEmpty {
                Text(bibliography.authors.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Publication details
            HStack {
                if let year = bibliography.publicationYear {
                    Text("\(year)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
                
                if let journal = bibliography.journal {
                    Text(journal)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            // Keywords
            if !bibliography.keywords.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(bibliography.keywords.prefix(3), id: \.self) { keyword in
                            Text(keyword)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onTap()
        }
    }
}

// LoadingView.swift
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// ErrorView.swift
struct ErrorView: View {
    let error: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.headline)
            
            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
```

### 5. Dependency Injection

#### 5.1 Service Container
```swift
// ServiceContainer.swift
class ServiceContainer {
    static let shared = ServiceContainer()
    
    private init() {}
    
    lazy var bibliographyService: BibliographyService = {
        BibliographyService()
    }()
    
    lazy var authenticationService: AuthenticationService = {
        AuthenticationService()
    }()
    
    lazy var userService: UserService = {
        UserService()
    }()
    
    lazy var exportService: ExportService = {
        ExportService()
    }()
}
```

### 6. Error Handling

#### 6.1 Custom Error Types
```swift
// AppError.swift
enum AppError: LocalizedError {
    case networkError(NetworkError)
    case authenticationError(String)
    case validationError(String)
    case databaseError(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let networkError):
            return networkError.localizedDescription
        case .authenticationError(let message):
            return message
        case .validationError(let message):
            return message
        case .databaseError(let message):
            return message
        case .unknownError(let message):
            return message
        }
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case noInternetConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError:
            return "Failed to decode response"
        case .noInternetConnection:
            return "No internet connection"
        }
    }
}
```

### 7. Testing Strategy

#### 7.1 Unit Tests
```swift
// BibliographyServiceTests.swift
class BibliographyServiceTests: XCTestCase {
    var service: BibliographyService!
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        service = BibliographyService(networkManager: mockNetworkManager)
    }
    
    func testFetchBibliographiesSuccess() async {
        // Given
        let expectedBibliographies = [Bibliography.mock()]
        mockNetworkManager.result = .success(expectedBibliographies)
        
        // When
        await service.fetchBibliographies()
        
        // Then
        XCTAssertEqual(service.bibliographies.count, 1)
        XCTAssertFalse(service.isLoading)
        XCTAssertNil(service.error)
    }
    
    func testFetchBibliographiesFailure() async {
        // Given
        mockNetworkManager.result = .failure(NetworkError.httpError(statusCode: 500))
        
        // When
        await service.fetchBibliographies()
        
        // Then
        XCTAssertTrue(service.bibliographies.isEmpty)
        XCTAssertFalse(service.isLoading)
        XCTAssertNotNil(service.error)
    }
}
```

### 8. Performance Optimization

#### 8.1 Lazy Loading
```swift
// LazyBibliographyList.swift
struct LazyBibliographyList: View {
    let bibliographies: [Bibliography]
    let onBibliographyTap: (Bibliography) -> Void
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(bibliographies) { bibliography in
                BibliographyCardView(bibliography: bibliography) {
                    onBibliographyTap(bibliography)
                }
            }
        }
        .padding(.horizontal)
    }
}
```

#### 8.2 Image Caching
```swift
// ImageCache.swift
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
```

## Security Considerations

### 1. Network Security
- Certificate pinning for API calls
- App Transport Security (ATS) enforcement
- Secure token storage in Keychain

### 2. Data Protection
- Encrypted Core Data storage
- Secure deletion of sensitive data
- Biometric authentication integration

### 3. Code Security
- Obfuscation for release builds
- Jailbreak detection
- Anti-debugging measures

## Performance Metrics

### 1. App Launch Time
- Cold start: < 2 seconds
- Warm start: < 1 second
- Background resume: < 500ms

### 2. Memory Usage
- Peak memory: < 150MB
- Background memory: < 50MB
- Memory leaks: 0

### 3. Network Performance
- API response time: < 2 seconds
- Image loading: < 1 second
- Offline functionality: 100% core features

## Monitoring & Analytics

### 1. Crash Reporting
- Firebase Crashlytics integration
- Custom error tracking
- Performance monitoring

### 2. User Analytics
- Firebase Analytics
- Custom event tracking
- User journey analysis

### 3. Performance Monitoring
- App launch time tracking
- Memory usage monitoring
- Network performance metrics
