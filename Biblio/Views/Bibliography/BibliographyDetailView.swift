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
                    if !bibliography.author.isEmpty {
                        Text("Authors: \(bibliography.authorsDisplay)")
                            .font(.headline)
                    }
                    
                    // Publication details
                    if let year = bibliography.year {
                        Text("Year: \(year)")
                    }
                    
                    if let publication = bibliography.publication {
                        Text("Publication: \(publication)")
                    }
                    
                    if let source = bibliography.source {
                        Text("Source: \(source)")
                            .foregroundColor(.blue)
                    }
                    
                    // Language details
                    if let languagePublished = bibliography.languagePublished {
                        Text("Language Published: \(languagePublished)")
                    }
                    
                    if let languageResearched = bibliography.languageResearched {
                        Text("Language Researched: \(languageResearched)")
                    }
                    
                    if let countryOfResearch = bibliography.countryOfResearch, !countryOfResearch.isEmpty {
                        Text("Country of Research: \(countryOfResearch)")
                    }
                    
                    // Keywords
                    if let keywords = bibliography.keywords, !keywords.isEmpty {
                        Text("Keywords: \(keywords)")
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
