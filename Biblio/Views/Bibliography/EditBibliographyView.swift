import SwiftUI

struct EditBibliographyView: View {
    let bibliography: Bibliography
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EditBibliographyViewModel()
    @State private var formModel: BibliographyFormModel
    @State private var showingDeleteAlert = false
    
    init(bibliography: Bibliography) {
        self.bibliography = bibliography
        self._formModel = State(initialValue: BibliographyFormModel(bibliography: bibliography))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Title *", text: $formModel.title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Author *", text: $formModel.author)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Year", text: $formModel.year)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    
                    TextField("Publication/Journal", text: $formModel.publication)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Publisher", text: $formModel.publisher)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section("Additional Details") {
                    TextField("Keywords (comma separated)", text: $formModel.keywords)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Source", text: $formModel.source)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Language Published", text: $formModel.languagePublished)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Language Researched", text: $formModel.languageResearched)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Country of Research", text: $formModel.countryOfResearch)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section("Advanced Information") {
                    TextField("Bibliography Name", text: $formModel.biblioName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Language Family", text: $formModel.languageFamily)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("ISBN", text: $formModel.isbn)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.default)
                    
                    TextField("ISSN", text: $formModel.issn)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.default)
                    
                    TextField("URL", text: $formModel.url)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    
                    TextField("Date of Entry", text: $formModel.dateOfEntry)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section {
                    Button("Delete Bibliography") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Bibliography")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            let updatedBibliography = formModel.updateBibliography(bibliography)
                            await viewModel.updateBibliography(updatedBibliography)
                        }
                    }
                    .disabled(!formModel.isValid || viewModel.isLoading)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Saving...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error occurred")
            }
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Bibliography updated successfully!")
            }
            .alert("Delete Bibliography", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteBibliography(bibliography)
                    }
                }
            } message: {
                Text("Are you sure you want to delete '\(bibliography.title)'? This action cannot be undone.")
            }
        }
    }
}

#Preview {
    EditBibliographyView(bibliography: Bibliography(
        id: "preview-id",
        title: "Sample Research Paper",
        author: "John Doe",
        year: 2024,
        publication: "Journal of Research",
        publisher: "Academic Press",
        languagePublished: "English",
        languageResearched: "Spanish",
        countryOfResearch: "USA",
        keywords: "research, sample, preview",
        source: "Academic Journal",
        languageFamily: "Indo-European",
        biblioName: nil,
        isbn: nil,
        issn: nil,
        url: nil,
        dateOfEntry: nil,
        createdAt: nil,
        updatedAt: nil
    ))
}
