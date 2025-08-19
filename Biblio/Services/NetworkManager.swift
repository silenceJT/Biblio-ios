import Foundation
import Combine

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case noInternetConnection
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case unknownError
    
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
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error"
        case .unknownError:
            return "Unknown error occurred"
        }
    }
}

// MARK: - Network Manager
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let baseURL: String
    private var accessToken: String?
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        
        self.session = URLSession(configuration: config)
        
        // Use AppConfig for API base URL
        self.baseURL = AppConfig.shared.apiBaseURL
    }
    
    // MARK: - Token Management
    func setAccessToken(_ token: String) {
        self.accessToken = token
    }
    
    func clearAccessToken() {
        self.accessToken = nil
    }
    
    func getAccessToken() -> String? {
        return accessToken
    }
    
    // MARK: - Main Request Method
    func request<T: Codable>(_ endpoint: APIEndpoint, as type: T.Type = T.self) async throws -> T {
        let request = try createRequest(for: endpoint)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            // Handle HTTP status codes
            try handleHTTPStatus(httpResponse.statusCode)
            
            // Decode response
            do {
                let decoder = JSONDecoder()
                
                // Create a custom date decoding strategy that handles multiple ISO8601 formats
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    // Try multiple date formats
                    let formatters = [
                        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",  // With milliseconds
                        "yyyy-MM-dd'T'HH:mm:ss'Z'",      // Without milliseconds
                        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",    // With milliseconds, no quotes
                        "yyyy-MM-dd'T'HH:mm:ssZ"         // Without milliseconds, no quotes
                    ]
                    
                    for format in formatters {
                        let formatter = DateFormatter()
                        formatter.dateFormat = format
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.timeZone = TimeZone(abbreviation: "UTC")
                        
                        if let date = formatter.date(from: dateString) {
                            return date
                        }
                    }
                    
                    // If none of the formats work, throw an error
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Date string '\(dateString)' does not match any expected ISO8601 format"
                    )
                }
                
                return try decoder.decode(type, from: data)
            } catch {
                print("Decoding error: \(error)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "Unable to read data")")
                throw NetworkError.decodingError
            }
            
        } catch {
            if let networkError = error as? NetworkError {
                throw networkError
            }
            
            // Handle other errors
            if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.noInternetConnection
            }
            
            throw NetworkError.unknownError
        }
    }
    
    // MARK: - Convenience Methods for Common Types
    func requestBibliographyResponse(_ endpoint: APIEndpoint) async throws -> BibliographyResponse {
        return try await request(endpoint, as: BibliographyResponse.self)
    }
    
    func requestBibliography(_ endpoint: APIEndpoint) async throws -> Bibliography {
        return try await request(endpoint, as: Bibliography.self)
    }
    
    func requestUser(_ endpoint: APIEndpoint) async throws -> User {
        return try await request(endpoint, as: User.self)
    }
    
    func requestAuthResponse(_ endpoint: APIEndpoint) async throws -> AuthResponse {
        return try await request(endpoint, as: AuthResponse.self)
    }
    
    // MARK: - Private Methods
    private func createRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication header if token exists
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body for POST/PUT requests
        if endpoint.method == .POST || endpoint.method == .PUT || endpoint.method == .PATCH {
            if let body = endpoint.body {
                let jsonData = try JSONSerialization.data(withJSONObject: body)
                request.httpBody = jsonData
                
                // Debug logging
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("🌐 Request Body: \(jsonString)")
                    print("🌐 Request URL: \(request.url?.absoluteString ?? "nil")")
                    print("🌐 Request Method: \(request.httpMethod ?? "nil")")
                }
            }
        }
        
        // Add query parameters for GET requests
        if endpoint.method == .GET, let queryItems = endpoint.queryItems {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            if let finalURL = components?.url {
                request.url = finalURL
            }
        }
        
        return request
    }
    
    private func handleHTTPStatus(_ statusCode: Int) throws {
        switch statusCode {
        case 200...299:
            return // Success
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError
        default:
            throw NetworkError.httpError(statusCode: statusCode)
        }
    }
}

extension NetworkManager {
    // MARK: - Mobile API Helpers
    func requestMobileBibliographyResponse(_ endpoint: BibliographyEndpoint) async throws -> MobileBibliographyResponse {
        return try await request(endpoint, as: MobileBibliographyResponse.self)
    }
    
    func requestMobileDashboardResponse(_ endpoint: APIEndpoint) async throws -> MobileDashboardResponse {
        return try await request(endpoint, as: MobileDashboardResponse.self)
    }
}

// MARK: - API Endpoint Protocol
protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var body: [String: Any]? { get }
    var queryItems: [URLQueryItem]? { get }
}

// MARK: - Default Implementation
extension APIEndpoint {
    var body: [String: Any]? { nil }
    var queryItems: [URLQueryItem]? { nil }
}
