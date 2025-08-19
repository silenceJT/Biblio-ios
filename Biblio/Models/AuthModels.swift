import Foundation

// MARK: - Authentication Request Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let name: String
}

// MARK: - Authentication Response Models
struct AuthResponse: Codable {
    let user: User
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case user
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

struct RefreshTokenResponse: Codable {
    let accessToken: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
    }
}

// MARK: - API Response Models
struct BibliographyResponse: Codable {
    let data: [Bibliography]
    let total: Int
    let page: Int
    let totalPages: Int
    let hasNext: Bool
    let hasPrevious: Bool
    
    enum CodingKeys: String, CodingKey {
        case data
        case total
        case page
        case totalPages = "total_pages"
        case hasNext = "has_next"
        case hasPrevious = "has_previous"
    }
}

struct UserResponse: Codable {
    let data: [User]
    let total: Int
    let page: Int
    let totalPages: Int
}

struct ErrorResponse: Codable {
    let error: String
    let message: String?
    let statusCode: Int?
    
    enum CodingKeys: String, CodingKey {
        case error
        case message
        case statusCode = "status_code"
    }
}

// MARK: - Search and Filter Models
struct SearchRequest: Codable {
    let query: String
    let page: Int
    let limit: Int
    let filters: BibliographyFilters?
}

struct BibliographyFilters: Codable {
    let year: Int?
    let authors: [String]
    let journals: [String]
    let keywords: [String]
    let dateFrom: Date?
    let dateTo: Date?
    
    enum CodingKeys: String, CodingKey {
        case year
        case authors
        case journals
        case keywords
        case dateFrom = "date_from"
        case dateTo = "date_to"
    }
    
    init(year: Int? = nil, authors: [String] = [], journals: [String] = [], keywords: [String] = [], dateFrom: Date? = nil, dateTo: Date? = nil) {
        self.year = year
        self.authors = authors
        self.journals = journals
        self.keywords = keywords
        self.dateFrom = dateFrom
        self.dateTo = dateTo
    }
    
    var isEmpty: Bool {
        year == nil && authors.isEmpty && journals.isEmpty && keywords.isEmpty && dateFrom == nil && dateTo == nil
    }
}

// MARK: - Export Models
struct ExportRequest: Codable {
    let bibliographyIds: [String]
    let format: ExportFormat
    let includeAbstract: Bool
    let includeKeywords: Bool
    
    enum CodingKeys: String, CodingKey {
        case bibliographyIds = "bibliography_ids"
        case format
        case includeAbstract = "include_abstract"
        case includeKeywords = "include_keywords"
    }
}

enum ExportFormat: String, Codable, CaseIterable {
    case bibtex = "bibtex"
    case csv = "csv"
    case json = "json"
    case pdf = "pdf"
    
    var displayName: String {
        switch self {
        case .bibtex:
            return "BibTeX"
        case .csv:
            return "CSV"
        case .json:
            return "JSON"
        case .pdf:
            return "PDF"
        }
    }
    
    var fileExtension: String {
        switch self {
        case .bibtex:
            return "bib"
        case .csv:
            return "csv"
        case .json:
            return "json"
        case .pdf:
            return "pdf"
        }
    }
    
    var mimeType: String {
        switch self {
        case .bibtex:
            return "application/x-bibtex"
        case .csv:
            return "text/csv"
        case .json:
            return "application/json"
        case .pdf:
            return "application/pdf"
        }
    }
}
