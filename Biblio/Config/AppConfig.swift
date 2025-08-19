import Foundation

struct AppConfig {
    // MARK: - API Configuration
    static let shared = AppConfig()
    
    // TODO: Update these URLs to match your actual backend
    #if DEBUG
    // Development - Local MongoDB backend
    let apiBaseURL = "http://localhost:3000/api"
    let webSocketURL = "ws://localhost:3000"
    #else
    // Production - Your deployed backend
    let apiBaseURL = "https://your-production-domain.com/api"
    let webSocketURL = "wss://your-production-domain.com"
    #endif
    
    // MARK: - Authentication Endpoints
    var authEndpoints: AuthEndpoints {
        AuthEndpoints(baseURL: apiBaseURL)
    }
    
    // MARK: - Bibliography Endpoints
    var bibliographyEndpoints: BibliographyEndpoints {
        BibliographyEndpoints(baseURL: apiBaseURL)
    }
    
    // MARK: - User Endpoints
    var userEndpoints: UserEndpoints {
        UserEndpoints(baseURL: apiBaseURL)
    }
    
    // MARK: - Export Endpoints
    var exportEndpoints: ExportEndpoints {
        ExportEndpoints(baseURL: apiBaseURL)
    }
}

// MARK: - Endpoint Groups
struct AuthEndpoints {
    let baseURL: String
    
    var login: String { "\(baseURL)/auth/login" }
    var register: String { "\(baseURL)/auth/register" }
    var logout: String { "\(baseURL)/auth/logout" }
    var refreshToken: String { "\(baseURL)/auth/refresh" }
    var getCurrentUser: String { "\(baseURL)/auth/me" }
    var forgotPassword: String { "\(baseURL)/auth/forgot-password" }
    var resetPassword: String { "\(baseURL)/auth/reset-password" }
}

struct BibliographyEndpoints {
    let baseURL: String
    
    var list: String { "\(baseURL)/bibliography" }
    var create: String { "\(baseURL)/bibliography" }
    var get: String { "\(baseURL)/bibliography/{id}" }
    var update: String { "\(baseURL)/bibliography/{id}" }
    var delete: String { "\(baseURL)/bibliography/{id}" }
    var search: String { "\(baseURL)/bibliography/search" }
    var importBibTeX: String { "\(baseURL)/bibliography/import/bibtex" }
    var exportBibTeX: String { "\(baseURL)/bibliography/export/bibtex" }
}

struct UserEndpoints {
    let baseURL: String
    
    var list: String { "\(baseURL)/users" }
    var get: String { "\(baseURL)/users/{id}" }
    var create: String { "\(baseURL)/users" }
    var update: String { "\(baseURL)/users/{id}" }
    var delete: String { "\(baseURL)/users/{id}" }
    var updateRole: String { "\(baseURL)/users/{id}/role" }
    var profile: String { "\(baseURL)/users/profile" }
}

struct ExportEndpoints {
    let baseURL: String
    
    var exportBibTeX: String { "\(baseURL)/export/bibtex" }
    var exportCSV: String { "\(baseURL)/export/csv" }
    var exportPDF: String { "\(baseURL)/export/pdf" }
    var exportJSON: String { "\(baseURL)/export/json" }
}

// MARK: - Environment Configuration
extension AppConfig {
    var isDevelopment: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    var isProduction: Bool {
        !isDevelopment
    }
    
    var logLevel: LogLevel {
        isDevelopment ? .debug : .error
    }
}

enum LogLevel: String, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

// MARK: - MongoDB Connection Info (for reference)
extension AppConfig {
    // Your actual MongoDB connection details
    var mongoDBInfo: MongoDBInfo {
        MongoDBInfo(
            connectionString: "mongodb+srv://jiataow:jesse_0626X@cluster0-f0faw.mongodb.net/test?retryWrites=true&w=majority",
            database: "test",
            collections: [
                "users",
                "biblio_200419",
                "sessions"
            ]
        )
    }
}

struct MongoDBInfo {
    let connectionString: String
    let database: String
    let collections: [String]
}
