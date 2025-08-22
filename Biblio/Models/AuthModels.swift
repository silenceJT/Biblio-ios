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
    let success: Bool
    let user: User?
    let token: String?
    let message: String?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case user
        case token
        case message
        case error
    }
    
    // Helper computed properties for mobile API
    var isSuccess: Bool {
        return success == true
    }
    
    var errorMessage: String? {
        return error ?? message
    }
    
    var accessToken: String? {
        return token
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

// MARK: - NextAuth.js Models
struct NextAuthSession: Codable {
    let user: User
    let expires: String
}

struct NextAuthCsrfResponse: Codable {
    let csrfToken: String
}

// MARK: - Mobile API Response Models
struct MobileBibliographyResponse: Codable {
    let success: Bool
    let data: MobileBibliographyData
    let error: String?
}

struct MobileBibliographyData: Codable {
    let bibliographies: [Bibliography]
    let pagination: MobilePagination
    let search: MobileSearchData?
}

struct MobilePagination: Codable {
    let currentPage: Int
    let limit: Int?
    let totalCount: Int
    let totalPages: Int
    let hasNextPage: Bool
    let hasPreviousPage: Bool
    
    // Computed properties for backward compatibility
    var page: Int { currentPage }
    var total: Int { totalCount }
    var pages: Int { totalPages }
}

struct MobileSearchData: Codable {
    let query: String?
    let filters: [String: String?]? // Allow null values in filters
    let sortBy: String?
    let sortOrder: String?
}

struct MobileDashboardResponse: Codable {
    let success: Bool
    let data: MobileDashboardData
}

struct MobileDashboardData: Codable {
    let stats: MobileStats
    let languages: [MobileLanguageStat]
    let recentItems: [Bibliography]
}

struct MobileStats: Codable {
    let totalRecords: Int
    let thisYear: Int
    let languages: Int
    let countries: Int
}

struct MobileLanguageStat: Codable {
    let language: String
    let count: Int
    let percentage: Double
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
    let yearFrom: Int? // New: year range start
    let yearTo: Int?   // New: year range end
    let authors: [String]
    let journals: [String]
    let keywords: [String]
    let languagePublished: String?
    let languageResearched: String?
    let countryOfResearch: String?
    let source: String?
    let languageFamily: String?
    let publication: String?
    let publisher: String?
    let biblioName: String?
    let dateFrom: Date?
    let dateTo: Date?
    
    enum CodingKeys: String, CodingKey {
        case year
        case yearFrom = "year_from"
        case yearTo = "year_to"
        case authors
        case journals
        case keywords
        case languagePublished = "language_published"
        case languageResearched = "language_researched"
        case countryOfResearch = "country_of_research"
        case source
        case languageFamily = "language_family"
        case publication
        case publisher
        case biblioName = "biblio_name"
        case dateFrom = "date_from"
        case dateTo = "date_to"
    }
    
    init(year: Int? = nil, yearFrom: Int? = nil, yearTo: Int? = nil, authors: [String] = [], journals: [String] = [], keywords: [String] = [], languagePublished: String? = nil, languageResearched: String? = nil, countryOfResearch: String? = nil, source: String? = nil, languageFamily: String? = nil, publication: String? = nil, publisher: String? = nil, biblioName: String? = nil, dateFrom: Date? = nil, dateTo: Date? = nil) {
        self.year = year
        self.yearFrom = yearFrom
        self.yearTo = yearTo
        self.authors = authors
        self.journals = journals
        self.keywords = keywords
        self.languagePublished = languagePublished
        self.languageResearched = languageResearched
        self.countryOfResearch = countryOfResearch
        self.source = source
        self.languageFamily = languageFamily
        self.publication = publication
        self.publisher = publisher
        self.biblioName = biblioName
        self.dateFrom = dateFrom
        self.dateTo = dateTo
    }
    
    var isEmpty: Bool {
        year == nil && yearFrom == nil && yearTo == nil && authors.isEmpty && journals.isEmpty && keywords.isEmpty && 
        languagePublished == nil && languageResearched == nil && countryOfResearch == nil && 
        source == nil && languageFamily == nil && publication == nil && publisher == nil && 
        biblioName == nil && dateFrom == nil && dateTo == nil
    }
}

// MARK: - Update Bibliography Response
struct UpdateBibliographyResponse: Codable {
    let success: Bool
    let data: Bibliography
    let timestamp: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case data
        case timestamp
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
