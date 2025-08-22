import SwiftUI

struct AddBibliographyView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddBibliographyViewModel()
    @State private var formModel = BibliographyFormModel()
    
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
            }
            .navigationTitle("Add Bibliography")
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
                            await viewModel.createBibliography(formModel.toBibliography())
                        }
                    }
                    .disabled(!formModel.isValid || viewModel.isLoading)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Creating...")
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
                Text("Bibliography created successfully!")
            }
        }
    }
}

#Preview {
    AddBibliographyView()
}
