import Foundation
import Combine

@MainActor
class BibliographyService: ObservableObject {
    private let networkManager = NetworkManager.shared
    
    // MARK: - Published Properties
    @Published var bibliographies: [Bibliography] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var totalCount = 0
    @Published var hasNextPage = false
    @Published var hasPreviousPage = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let pageSize = 20
    
    init() {
        // Load initial data
        Task {
            await loadBibliographies()
        }
    }
    
    // MARK: - Public Methods
    
    /// Load bibliographies for the current page
    func loadBibliographies() async {
        await loadBibliographies(page: currentPage)
    }
    
    /// Load bibliographies for a specific page
    func loadBibliographies(page: Int) async {
        await MainActor.run { 
            isLoading = true
            error = nil
        }
        
        do {
            let response = try await networkManager.requestBibliographyResponse(
                BibliographyEndpoint.fetchBibliographies(page: page, limit: pageSize)
            )
            
            await MainActor.run {
                if page == 1 {
                    self.bibliographies = response.data
                } else {
                    self.bibliographies.append(contentsOf: response.data)
                }
                
                self.currentPage = response.page
                self.totalPages = response.totalPages
                self.totalCount = response.total
                self.hasNextPage = response.hasNext
                self.hasPreviousPage = response.hasPrevious
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    /// Load next page of bibliographies
    func loadNextPage() async {
        guard hasNextPage && !isLoading else { return }
        await loadBibliographies(page: currentPage + 1)
    }
    
    /// Refresh bibliographies (reset to first page)
    func refresh() async {
        currentPage = 1
        await loadBibliographies(page: 1)
    }
    
    /// Search bibliographies with query and filters
    func searchBibliographies(query: String, filters: BibliographyFilters? = nil) async {
        await MainActor.run { 
            isLoading = true
            error = nil
        }
        
        do {
            let response = try await networkManager.requestBibliographyResponse(
                BibliographyEndpoint.searchBibliographies(
                    query: query,
                    page: 1,
                    limit: pageSize,
                    filters: filters
                )
            )
            
            await MainActor.run {
                self.bibliographies = response.data
                self.currentPage = response.page
                self.totalPages = response.totalPages
                self.totalCount = response.total
                self.hasNextPage = response.hasNext
                self.hasPreviousPage = response.hasPrevious
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    /// Create a new bibliography
    func createBibliography(_ bibliography: Bibliography) async throws -> Bibliography {
        await MainActor.run { isLoading = true }
        
        do {
            let created = try await networkManager.requestBibliography(
                BibliographyEndpoint.createBibliography(bibliography)
            )
            
            await MainActor.run {
                self.bibliographies.insert(created, at: 0)
                self.isLoading = false
            }
            
            return created
            
        } catch {
            await MainActor.run { 
                self.error = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Update an existing bibliography
    func updateBibliography(_ bibliography: Bibliography) async throws -> Bibliography {
        await MainActor.run { isLoading = true }
        
        do {
            let updated = try await networkManager.requestBibliography(
                BibliographyEndpoint.updateBibliography(bibliography)
            )
            
            await MainActor.run {
                if let index = self.bibliographies.firstIndex(where: { $0.id == bibliography.id }) {
                    self.bibliographies[index] = updated
                }
                self.isLoading = false
            }
            
            return updated
            
        } catch {
            await MainActor.run { 
                self.error = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Delete a bibliography
    func deleteBibliography(_ id: String) async throws {
        await MainActor.run { isLoading = true }
        
        do {
            // For DELETE requests, we don't expect a response body
            let _: EmptyResponse = try await networkManager.request(
                BibliographyEndpoint.deleteBibliography(id: id),
                as: EmptyResponse.self
            )
            
            await MainActor.run {
                self.bibliographies.removeAll { $0.id == id }
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run { 
                self.error = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Fetch a single bibliography by ID
    func fetchBibliography(id: String) async throws -> Bibliography {
        return try await networkManager.requestBibliography(
            BibliographyEndpoint.fetchBibliography(id: id)
        )
    }
    
    /// Clear error message
    func clearError() {
        error = nil
    }
    
    /// Get bibliography by ID from local cache
    func getBibliography(id: String) -> Bibliography? {
        return bibliographies.first { $0.id == id }
    }
    
    /// Check if bibliography exists locally
    func hasBibliography(id: String) -> Bool {
        return bibliographies.contains { $0.id == id }
    }
}

// MARK: - Empty Response for DELETE operations
struct EmptyResponse: Codable {}

// MARK: - Mock Service for Development
extension BibliographyService {
    /// Load mock data for development
    func loadMockData() {
        bibliographies = Bibliography.mockList()
        currentPage = 1
        totalPages = 1
        totalCount = bibliographies.count
        hasNextPage = false
        hasPreviousPage = false
        isLoading = false
        error = nil
    }
    
    /// Clear all data
    func clearData() {
        bibliographies.removeAll()
        currentPage = 1
        totalPages = 1
        totalCount = 0
        hasNextPage = false
        hasPreviousPage = false
        isLoading = false
        error = nil
    }
}
