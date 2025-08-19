import Foundation
import Combine

@MainActor
class BibliographyListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var bibliographies: [Bibliography] = []
    @Published var filteredBibliographies: [Bibliography] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText = ""
    @Published var selectedFilters = BibliographyFilters()
    
    // MARK: - Computed Properties
    var totalCount: Int {
        bibliographyService.totalCount
    }
    
    var hasNextPage: Bool {
        bibliographyService.hasNextPage
    }
    
    // MARK: - Private Properties
    private let bibliographyService = BibliographyService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadInitialData()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Combine search text with filters for real-time filtering
        Publishers.CombineLatest($searchText, $selectedFilters)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText, filters in
                self?.applyFiltersAndSearch(searchText: searchText, filters: filters)
            }
            .store(in: &cancellables)
        
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
    
    // MARK: - Data Loading
    private func loadInitialData() {
        Task {
            await loadBibliographies()
        }
    }
    
    func loadBibliographies() async {
        await bibliographyService.loadBibliographies()
    }
    
    func refresh() async {
        await bibliographyService.refresh()
    }
    
    func loadNextPage() async {
        await bibliographyService.loadNextPage()
    }
    
    // MARK: - Search and Filtering
    func searchBibliographies(query: String) async {
        if query.isEmpty {
            await refresh()
        } else {
            await bibliographyService.searchBibliographies(query: query, filters: selectedFilters)
        }
    }
    
    /// Perform local search/filtering on existing data
    func performLocalSearch(query: String) async {
        // This triggers the Combine binding which will call applyFiltersAndSearch
        // The debounce ensures we don't filter on every keystroke
    }
    
    func clearSearch() {
        searchText = ""
        Task {
            await refresh()
        }
    }
    
    func clearFilters() {
        selectedFilters = BibliographyFilters()
        Task {
            await refresh()
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
                } ||
                (bibliography.journal?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (bibliography.doi?.localizedCaseInsensitiveContains(searchText) ?? false)
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
        
        if !filters.journals.isEmpty {
            filtered = filtered.filter { bibliography in
                bibliography.journal != nil && filters.journals.contains(bibliography.journal!)
            }
        }
        
        if !filters.keywords.isEmpty {
            filtered = filtered.filter { bibliography in
                bibliography.keywords.contains { keyword in
                    filters.keywords.contains(keyword)
                }
            }
        }
        
        if let dateFrom = filters.dateFrom {
            filtered = filtered.filter { $0.createdAt >= dateFrom }
        }
        
        if let dateTo = filters.dateTo {
            filtered = filtered.filter { $0.createdAt <= dateTo }
        }
        
        filteredBibliographies = filtered
    }
    
    // MARK: - CRUD Operations
    func createBibliography(_ bibliography: Bibliography) async throws -> Bibliography {
        return try await bibliographyService.createBibliography(bibliography)
    }
    
    func updateBibliography(_ bibliography: Bibliography) async throws -> Bibliography {
        return try await bibliographyService.updateBibliography(bibliography)
    }
    
    func deleteBibliography(_ id: String) async throws {
        try await bibliographyService.deleteBibliography(id)
    }
    
    // MARK: - Selection
    func selectBibliography(_ bibliography: Bibliography) {
        // Handle bibliography selection
        // This could navigate to detail view or perform other actions
    }
    
    // MARK: - Utility Methods
    func getBibliography(id: String) -> Bibliography? {
        return bibliographyService.getBibliography(id: id)
    }
    
    func hasBibliography(id: String) -> Bool {
        return bibliographyService.hasBibliography(id: id)
    }
    
    func clearError() {
        error = nil
        bibliographyService.clearError()
    }
    
    // MARK: - Mock Data for Development
    func loadMockData() {
        bibliographyService.loadMockData()
    }
    
    func clearData() {
        bibliographyService.clearData()
    }
    
    // MARK: - Computed Properties
    var hasResults: Bool {
        !filteredBibliographies.isEmpty
    }
    
    var resultCount: Int {
        filteredBibliographies.count
    }
    
    var hasActiveFilters: Bool {
        !selectedFilters.isEmpty
    }
    
    var filterSummary: String {
        var filters: [String] = []
        
        if let year = selectedFilters.year {
            filters.append("Year: \(year)")
        }
        if !selectedFilters.authors.isEmpty {
            filters.append("Authors: \(selectedFilters.authors.joined(separator: ", "))")
        }
        if !selectedFilters.journals.isEmpty {
            filters.append("Journals: \(selectedFilters.journals.joined(separator: ", "))")
        }
        if !selectedFilters.keywords.isEmpty {
            filters.append("Keywords: \(selectedFilters.keywords.joined(separator: ", "))")
        }
        
        return filters.joined(separator: " • ")
    }
}

// MARK: - Filter Management
extension BibliographyListViewModel {
    func addYearFilter(_ year: Int) {
        selectedFilters = BibliographyFilters(
            year: year,
            authors: selectedFilters.authors,
            journals: selectedFilters.journals,
            keywords: selectedFilters.keywords,
            dateFrom: selectedFilters.dateFrom,
            dateTo: selectedFilters.dateTo
        )
    }
    
    func addAuthorFilter(_ author: String) {
        var authors = selectedFilters.authors
        if !authors.contains(author) {
            authors.append(author)
        }
        selectedFilters = BibliographyFilters(
            year: selectedFilters.year,
            authors: authors,
            journals: selectedFilters.journals,
            keywords: selectedFilters.keywords,
            dateFrom: selectedFilters.dateFrom,
            dateTo: selectedFilters.dateTo
        )
    }
    
    func removeAuthorFilter(_ author: String) {
        let authors = selectedFilters.authors.filter { $0 != author }
        selectedFilters = BibliographyFilters(
            year: selectedFilters.year,
            authors: authors,
            journals: selectedFilters.journals,
            keywords: selectedFilters.keywords,
            dateFrom: selectedFilters.dateFrom,
            dateTo: selectedFilters.dateTo
        )
    }
    
    func addKeywordFilter(_ keyword: String) {
        var keywords = selectedFilters.keywords
        if !keywords.contains(keyword) {
            keywords.append(keyword)
        }
        selectedFilters = BibliographyFilters(
            year: selectedFilters.year,
            authors: selectedFilters.authors,
            journals: selectedFilters.journals,
            keywords: keywords,
            dateFrom: selectedFilters.dateFrom,
            dateTo: selectedFilters.dateTo
        )
    }
    
    func removeKeywordFilter(_ keyword: String) {
        let keywords = selectedFilters.keywords.filter { $0 != keyword }
        selectedFilters = BibliographyFilters(
            year: selectedFilters.year,
            authors: selectedFilters.authors,
            journals: selectedFilters.journals,
            keywords: keywords,
            dateFrom: selectedFilters.dateFrom,
            dateTo: selectedFilters.dateTo
        )
    }
}
