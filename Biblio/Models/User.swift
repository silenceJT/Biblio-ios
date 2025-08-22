import Foundation

struct User: Codable, Identifiable, Hashable {
    let id: String
    let email: String
    let name: String?
    let role: UserRole
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // Map backend "_id" to iOS "id"
        case email
        case name
        case role
        case createdAt
    }
    
    // MARK: - Computed Properties
    var displayName: String {
        name ?? email
    }
    
    var isAdmin: Bool {
        role == .admin || role == .superAdmin
    }
    
    var isSuperAdmin: Bool {
        role == .superAdmin
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

enum UserRole: String, Codable, CaseIterable {
    case user = "user"
    case admin = "admin"
    case superAdmin = "super_admin"
    
    var displayName: String {
        switch self {
        case .user:
            return "User"
        case .admin:
            return "Admin"
        case .superAdmin:
            return "Super Admin"
        }
    }
    
    var icon: String {
        switch self {
        case .user:
            return "person"
        case .admin:
            return "person.2"
        case .superAdmin:
            return "person.3"
        }
    }
}

// MARK: - Mock Data for Development
extension User {
    static func mock() -> User {
        User(
            id: "user123",
            email: "user@example.com",
            name: "John Doe",
            role: .user,
            createdAt: Date().addingTimeInterval(-86400 * 30)
        )
    }
    
    static func mockAdmin() -> User {
        User(
            id: "admin456",
            email: "admin@example.com",
            name: "Admin User",
            role: .admin,
            createdAt: Date().addingTimeInterval(-86400 * 60)
        )
    }
    
    static func mockSuperAdmin() -> User {
        User(
            id: "super789",
            email: "super@example.com",
            name: "Super Admin",
            role: .superAdmin,
            createdAt: Date().addingTimeInterval(-86400 * 90)
        )
    }
    
    // Mock without createdAt for backend compatibility
    static func mockFromBackend() -> User {
        User(
            id: "689adb464e60b85ef28ec206",
            email: "jessewjt@gmail.com",
            name: "Jiatao Wu",
            role: .superAdmin,
            createdAt: nil
        )
    }
}
