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
            let response = try await networkManager.requestMobileBibliographyResponse(
                BibliographyEndpoint.fetchBibliographies(page: page, limit: pageSize)
            )
            
            await MainActor.run {
                if page == 1 {
                    self.bibliographies = response.data.bibliographies
                } else {
                    self.bibliographies.append(contentsOf: response.data.bibliographies)
                }
                
                self.currentPage = response.data.pagination.currentPage
                self.totalPages = response.data.pagination.totalPages
                self.totalCount = response.data.pagination.totalCount
                self.hasNextPage = response.data.pagination.hasNextPage
                self.hasPreviousPage = response.data.pagination.hasPreviousPage
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
            let response = try await networkManager.requestMobileBibliographyResponse(
                BibliographyEndpoint.searchBibliographies(
                    query: query,
                    page: 1,
                    limit: pageSize,
                    filters: filters
                )
            )
            
            await MainActor.run {
                self.bibliographies = response.data.bibliographies
                self.currentPage = response.data.pagination.currentPage
                self.totalPages = response.data.pagination.totalPages
                self.totalCount = response.data.pagination.totalCount
                self.hasNextPage = response.data.pagination.hasNextPage
                self.hasPreviousPage = response.data.pagination.hasPreviousPage
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
            // Create minimal create payload with only updatable fields (no _id, createdAt, updatedAt)
            let createData: [String: Any] = [
                "title": bibliography.title,
                "author": bibliography.author,
                "year": bibliography.year,
                "publication": bibliography.publication,
                "publisher": bibliography.publisher,
                "language_published": bibliography.languagePublished,
                "language_researched": bibliography.languageResearched,
                "country_of_research": bibliography.countryOfResearch,
                "keywords": bibliography.keywords,
                "source": bibliography.source,
                "language_family": bibliography.languageFamily,
                "biblio_name": bibliography.biblioName,
                "isbn": bibliography.isbn,
                "issn": bibliography.issn,
                "url": bibliography.url,
                "date_of_entry": bibliography.dateOfEntry
            ].compactMapValues { $0 } // Remove nil values
            
            let response: UpdateBibliographyResponse = try await networkManager.request(
                BibliographyEndpoint.createBibliography(createData)
            )
            
            let created = response.data
            
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
            // Create minimal update payload with only updatable fields
            let updateData: [String: Any] = [
                "title": bibliography.title,
                "author": bibliography.author,
                "year": bibliography.year,
                "publication": bibliography.publication,
                "publisher": bibliography.publisher,
                "language_published": bibliography.languagePublished,
                "language_researched": bibliography.languageResearched,
                "country_of_research": bibliography.countryOfResearch,
                "keywords": bibliography.keywords,
                "source": bibliography.source,
                "language_family": bibliography.languageFamily,
                "biblio_name": bibliography.biblioName,
                "isbn": bibliography.isbn,
                "issn": bibliography.issn,
                "url": bibliography.url,
                "date_of_entry": bibliography.dateOfEntry
            ].compactMapValues { $0 } // Remove nil values
            
            guard let bibliographyId = bibliography.id else {
                throw NSError(domain: "BibliographyService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Cannot update bibliography without ID"])
            }
            
            let response: UpdateBibliographyResponse = try await networkManager.request(
                BibliographyEndpoint.updateBibliography(id: bibliographyId, updateData: updateData)
            )
            
            let updated = response.data
            
            await MainActor.run {
                if let bibliographyId = bibliography.id,
                   let index = self.bibliographies.firstIndex(where: { $0.id == bibliographyId }) {
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
                self.bibliographies.removeAll { $0.identifier == id }
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
        return try await networkManager.request(
            BibliographyEndpoint.fetchBibliography(id: id),
            as: Bibliography.self
        )
    }
    
    /// Clear error message
    func clearError() {
        error = nil
    }
    
    /// Get bibliography by ID from local cache
    func getBibliography(id: String) -> Bibliography? {
        return bibliographies.first { $0.identifier == id }
    }
    
    /// Check if bibliography exists locally
    func hasBibliography(id: String) -> Bool {
        return bibliographies.contains { $0.identifier == id }
    }
}

// MARK: - Empty Response for DELETE operations
struct EmptyResponse: Codable {}
