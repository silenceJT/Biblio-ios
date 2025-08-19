import Foundation

struct BibliographyFormModel {
    var title: String = ""
    var author: String = ""
    var year: String = ""
    var publication: String = ""
    var keywords: String = ""
    var source: String = ""
    var languagePublished: String = ""
    var languageResearched: String = ""
    var countryOfResearch: String = ""
    var biblioName: String = ""
    var languageFamily: String = ""
    var isbn: String = ""
    var issn: String = ""
    var url: String = ""
    var dateOfEntry: String = ""
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Initialize from existing Bibliography for editing
    init(bibliography: Bibliography? = nil) {
        guard let bibliography = bibliography else { return }
        
        self.title = bibliography.title
        self.author = bibliography.author
        self.year = bibliography.year?.description ?? ""
        self.publication = bibliography.publication ?? ""
        self.keywords = bibliography.keywords ?? ""
        self.source = bibliography.source ?? ""
        self.languagePublished = bibliography.languagePublished ?? ""
        self.languageResearched = bibliography.languageResearched ?? ""
        self.countryOfResearch = bibliography.countryOfResearch ?? ""
        self.biblioName = bibliography.biblioName ?? ""
        self.languageFamily = bibliography.languageFamily ?? ""
        self.isbn = bibliography.isbn ?? ""
        self.issn = bibliography.issn ?? ""
        self.url = bibliography.url ?? ""
        self.dateOfEntry = bibliography.dateOfEntry ?? ""
    }
    
    func toBibliography() -> Bibliography {
        Bibliography(
            id: UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            author: author.trimmingCharacters(in: .whitespacesAndNewlines),
            year: Int(year),
            publication: publication.isEmpty ? nil : publication,
            biblioName: biblioName.isEmpty ? nil : biblioName,
            languagePublished: languagePublished.isEmpty ? nil : languagePublished,
            languageResearched: languageResearched.isEmpty ? nil : languageResearched,
            countryOfResearch: countryOfResearch.isEmpty ? nil : countryOfResearch,
            keywords: keywords.isEmpty ? nil : keywords,
            source: source.isEmpty ? nil : source,
            languageFamily: languageFamily.isEmpty ? nil : languageFamily,
            isbn: isbn.isEmpty ? nil : isbn,
            issn: issn.isEmpty ? nil : issn,
            url: url.isEmpty ? nil : url,
            dateOfEntry: dateOfEntry.isEmpty ? nil : dateOfEntry,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    func updateBibliography(_ bibliography: Bibliography) -> Bibliography {
        Bibliography(
            id: bibliography.id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            author: author.trimmingCharacters(in: .whitespacesAndNewlines),
            year: Int(year),
            publication: publication.isEmpty ? nil : publication,
            biblioName: biblioName.isEmpty ? nil : biblioName,
            languagePublished: languagePublished.isEmpty ? nil : languagePublished,
            languageResearched: languageResearched.isEmpty ? nil : languageResearched,
            countryOfResearch: countryOfResearch.isEmpty ? nil : countryOfResearch,
            keywords: keywords.isEmpty ? nil : keywords,
            source: source.isEmpty ? nil : source,
            languageFamily: languageFamily.isEmpty ? nil : languageFamily,
            isbn: isbn.isEmpty ? nil : isbn,
            issn: issn.isEmpty ? nil : issn,
            url: url.isEmpty ? nil : url,
            dateOfEntry: dateOfEntry.isEmpty ? nil : dateOfEntry,
            createdAt: bibliography.createdAt,
            updatedAt: Date()
        )
    }
}
