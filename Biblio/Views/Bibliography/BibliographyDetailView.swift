import SwiftUI

struct BibliographyDetailView: View {
    let bibliography: Bibliography
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text(bibliography.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Authors
                    if !bibliography.authors.isEmpty {
                        Text("Authors: \(bibliography.authorsDisplay)")
                            .font(.headline)
                    }
                    
                    // Publication details
                    if let year = bibliography.publicationYear {
                        Text("Year: \(year)")
                    }
                    
                    if let journal = bibliography.journal {
                        Text("Journal: \(journal)")
                    }
                    
                    if let doi = bibliography.doi {
                        Text("DOI: \(doi)")
                            .foregroundColor(.blue)
                    }
                    
                    // Abstract
                    if let abstract = bibliography.abstract {
                        Text("Abstract")
                            .font(.headline)
                        Text(abstract)
                    }
                    
                    // Keywords
                    if !bibliography.keywords.isEmpty {
                        Text("Keywords: \(bibliography.keywordsDisplay)")
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        // Will be implemented in Phase 3
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    BibliographyDetailView(bibliography: Bibliography.mock())
}
