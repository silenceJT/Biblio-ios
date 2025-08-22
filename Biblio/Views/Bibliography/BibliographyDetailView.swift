import SwiftUI

struct BibliographyDetailView: View {
    let bibliography: Bibliography
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    
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
                    
                    if let publisher = bibliography.publisher {
                        Text("Publisher: \(publisher)")
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
                               showingEditSheet = true
                           }
                       }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                                       }
               }
           }
           .sheet(isPresented: $showingEditSheet) {
               EditBibliographyView(bibliography: bibliography)
           }
       }
   }
}

#Preview {
    BibliographyDetailView(bibliography: Bibliography(
        id: "preview_id",
        title: "Sample Research Paper",
        author: "John Doe, Jane Smith",
        year: 2024,
        publication: "Journal of Computer Science",
        publisher: "Academic Press",
        languagePublished: "English",
        languageResearched: "English",
        countryOfResearch: "United States",
        keywords: "computer science, research, sample",
        source: "Sample source",
        languageFamily: "Indo_European",
        biblioName: nil,
        isbn: "1234567890",
        issn: nil,
        url: nil,
        dateOfEntry: nil,
        createdAt: nil,
        updatedAt: nil
    ))
}
