import SwiftUI

struct BibliographyListView: View {
    @StateObject private var viewModel = BibliographyListViewModel()
    @State private var showingAddSheet = false
    @State private var showingFilters = false
    @State private var selectedBibliography: Bibliography?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                searchAndFilterBar
                
                // Content
                if viewModel.isLoading && viewModel.bibliographies.isEmpty {
                    LoadingView(message: "Loading bibliographies...")
                } else if let error = viewModel.error, viewModel.bibliographies.isEmpty {
                    ErrorView(error: error) {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                } else if viewModel.bibliographies.isEmpty {
                    emptyStateView
                } else {
                    bibliographyList
                }
            }
            .navigationTitle("Bibliography")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        showingAddSheet = true
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $showingAddSheet) {
                AddBibliographyView()
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(filters: $viewModel.selectedFilters)
            }
            .sheet(item: $selectedBibliography) { bibliography in
                BibliographyDetailView(bibliography: bibliography)
            }
        }
        .onAppear {
            // Load mock data for development
            if viewModel.bibliographies.isEmpty {
                viewModel.loadMockData()
            }
        }
    }
    
    // MARK: - Search and Filter Bar
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search bibliographies...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: viewModel.searchText) { oldValue, newValue in
                        // Real-time search as user types
                        Task {
                            await viewModel.performLocalSearch(query: newValue)
                        }
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button("Clear") {
                        viewModel.clearSearch()
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Filter Bar
            HStack {
                Button(action: { showingFilters = true }) {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("Filters")
                        if !viewModel.selectedFilters.isEmpty {
                            Text("(\(viewModel.selectedFilters.filterCount))")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Results count - show filtered count when searching
                if !viewModel.searchText.isEmpty || !viewModel.selectedFilters.isEmpty {
                    Text("\(viewModel.filteredBibliographies.count) of \(viewModel.totalCount) results")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("\(viewModel.totalCount) results")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Bibliography List
    private var bibliographyList: some View {
        List {
            // Show filtered results when searching/filtering, otherwise show all
            let displayBibliographies = (!viewModel.searchText.isEmpty || !viewModel.selectedFilters.isEmpty) 
                ? viewModel.filteredBibliographies 
                : viewModel.bibliographies
            
            if displayBibliographies.isEmpty && (!viewModel.searchText.isEmpty || !viewModel.selectedFilters.isEmpty) {
                // No results for current search/filter
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No results found")
                            .font(.headline)
                        Text("Try adjusting your search or filters")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                }
                .listRowBackground(Color.clear)
            } else {
                ForEach(displayBibliographies) { bibliography in
                    BibliographyRowView(bibliography: bibliography) {
                        selectedBibliography = bibliography
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", role: .destructive) {
                            Task {
                                try? await viewModel.deleteBibliography(bibliography.id)
                            }
                        }
                    }
                }
            }
            
            // Load more button - only show when not filtering
            if viewModel.hasNextPage && !viewModel.isLoading && viewModel.searchText.isEmpty && viewModel.selectedFilters.isEmpty {
                Button("Load More") {
                    Task {
                        await viewModel.loadNextPage()
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.blue)
                .listRowBackground(Color.clear)
            }
            
            // Loading indicator for pagination
            if viewModel.isLoading && !viewModel.bibliographies.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Bibliographies")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start by adding your first bibliography entry")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add Bibliography") {
                showingAddSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Bibliography Row View
struct BibliographyRowView: View {
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
            if !bibliography.author.isEmpty {
                Text(bibliography.authorsDisplay)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Publication details
            HStack {
                if let year = bibliography.year {
                    Text("\(year)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
                
                if let publication = bibliography.publication {
                    Text(publication)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Source indicator
                if bibliography.source != nil {
                    Image(systemName: "link")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            // Keywords
            if let keywords = bibliography.keywords, !keywords.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(keywords.components(separatedBy: ", ").prefix(3), id: \.self) { keyword in
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
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Filter Count Extension
extension BibliographyFilters {
    var filterCount: Int {
        var count = 0
        if year != nil { count += 1 }
        if !authors.isEmpty { count += 1 }
        if !journals.isEmpty { count += 1 }
        if !keywords.isEmpty { count += 1 }
        if dateFrom != nil { count += 1 }
        if dateTo != nil { count += 1 }
        return count
    }
}

#Preview {
    BibliographyListView()
}
