import Foundation

// MARK: - Bibliography Endpoints
enum BibliographyEndpoint: APIEndpoint {
    case fetchBibliographies(page: Int, limit: Int)
    case fetchBibliography(id: String)
    case createBibliography(Bibliography)
    case updateBibliography(Bibliography)
    case deleteBibliography(id: String)
    case searchBibliographies(query: String, page: Int, limit: Int, filters: BibliographyFilters?)
    
    var path: String {
        switch self {
        case .fetchBibliographies, .createBibliography:
            return "/bibliography"
        case .fetchBibliography(let id), .deleteBibliography(let id):
            return "/bibliography/\(id)"
        case .updateBibliography:
            return "/bibliography"
        case .searchBibliographies:
            return "/bibliography/search"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchBibliographies, .fetchBibliography, .searchBibliographies:
            return .GET
        case .createBibliography:
            return .POST
        case .updateBibliography:
            return .PUT
        case .deleteBibliography:
            return .DELETE
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .fetchBibliographies(let page, let limit):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        case .searchBibliographies(let query, let page, let limit, let filters):
            var items = [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
            
            if let filters = filters {
                if let year = filters.year {
                    items.append(URLQueryItem(name: "year", value: "\(year)"))
                }
                if !filters.authors.isEmpty {
                    items.append(URLQueryItem(name: "authors", value: filters.authors.joined(separator: ",")))
                }
                if !filters.journals.isEmpty {
                    items.append(URLQueryItem(name: "journals", value: filters.journals.joined(separator: ",")))
                }
                if !filters.keywords.isEmpty {
                    items.append(URLQueryItem(name: "keywords", value: filters.keywords.joined(separator: ",")))
                }
                if let dateFrom = filters.dateFrom {
                    let formatter = ISO8601DateFormatter()
                    items.append(URLQueryItem(name: "date_from", value: formatter.string(from: dateFrom)))
                }
                if let dateTo = filters.dateTo {
                    let formatter = ISO8601DateFormatter()
                    items.append(URLQueryItem(name: "date_to", value: formatter.string(from: dateTo)))
                }
            }
            
            return items
        default:
            return nil
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .createBibliography(let bibliography), .updateBibliography(let bibliography):
            return try? bibliography.asDictionary()
        default:
            return nil
        }
    }
}

// MARK: - Authentication Endpoints
enum AuthEndpoint: APIEndpoint {
    case login(email: String, password: String)
    case logout
    case refreshToken(String)
    case getCurrentUser
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .logout:
            return "/auth/logout"
        case .refreshToken:
            return "/auth/refresh"
        case .getCurrentUser:
            return "/auth/me"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .refreshToken:
            return .POST
        case .logout:
            return .POST
        case .getCurrentUser:
            return .GET
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .login(let email, let password):
            return [
                "email": email,
                "password": password
            ]
        case .refreshToken(let token):
            return [
                "refresh_token": token
            ]
        default:
            return nil
        }
    }
}

// MARK: - User Management Endpoints
enum UserEndpoint: APIEndpoint {
    case fetchUsers(page: Int, limit: Int)
    case fetchUser(id: String)
    case updateUser(id: String, User)
    case deleteUser(id: String)
    case updateUserRole(id: String, role: UserRole)
    
    var path: String {
        switch self {
        case .fetchUsers:
            return "/users"
        case .fetchUser(let id), .updateUser(let id, _), .deleteUser(let id), .updateUserRole(let id, _):
            return "/users/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchUsers, .fetchUser:
            return .GET
        case .updateUser, .updateUserRole:
            return .PUT
        case .deleteUser:
            return .DELETE
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .fetchUsers(let page, let limit):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        default:
            return nil
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .updateUser(_, let user):
            return try? user.asDictionary()
        case .updateUserRole(_, let role):
            return [
                "role": role.rawValue
            ]
        default:
            return nil
        }
    }
}

// MARK: - Export Endpoints
enum ExportEndpoint: APIEndpoint {
    case exportBibliographies(ExportRequest)
    
    var path: String {
        return "/export"
    }
    
    var method: HTTPMethod {
        return .POST
    }
    
    var body: [String: Any]? {
        switch self {
        case .exportBibliographies(let request):
            return try? request.asDictionary()
        }
    }
}

// MARK: - Helper Extensions
extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NetworkError.decodingError
        }
        return dictionary
    }
}
