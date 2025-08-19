import Foundation

struct Bibliography: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let author: String
    let year: Int?
    let publication: String?
    let biblioName: String?
    let languagePublished: String?
    let languageResearched: String?
    let countryOfResearch: String?
    let keywords: String?
    let source: String?
    let languageFamily: String?
    let isbn: String?
    let issn: String?
    let url: String?
    let dateOfEntry: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    // MARK: - Initializers
    init(id: String, title: String, author: String, year: Int?, publication: String?, biblioName: String?, languagePublished: String?, languageResearched: String?, countryOfResearch: String?, keywords: String?, source: String?, languageFamily: String?, isbn: String?, issn: String?, url: String?, dateOfEntry: String?, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.title = title
        self.author = author
        self.year = year
        self.publication = publication
        self.biblioName = biblioName
        self.languagePublished = languagePublished
        self.languageResearched = languageResearched
        self.countryOfResearch = countryOfResearch
        self.keywords = keywords
        self.source = source
        self.languageFamily = languageFamily
        self.isbn = isbn
        self.issn = issn
        self.url = url
        self.dateOfEntry = dateOfEntry
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Custom Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(String.self, forKey: .author)
        year = try container.decodeIfPresent(Int.self, forKey: .year)
        publication = try container.decodeIfPresent(String.self, forKey: .publication)
        biblioName = try container.decodeIfPresent(String.self, forKey: .biblioName)
        languagePublished = try container.decodeIfPresent(String.self, forKey: .languagePublished)
        languageResearched = try container.decodeIfPresent(String.self, forKey: .languageResearched)
        countryOfResearch = try container.decodeIfPresent(String.self, forKey: .countryOfResearch)
        keywords = try container.decodeIfPresent(String.self, forKey: .keywords)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        languageFamily = try container.decodeIfPresent(String.self, forKey: .languageFamily)
        
        // Handle mixed types for ISBN and ISSN
        if let isbnValue = try? container.decodeIfPresent(String.self, forKey: .isbn) {
            isbn = isbnValue
        } else if let isbnNumber = try? container.decodeIfPresent(Int.self, forKey: .isbn) {
            isbn = String(isbnNumber)
        } else {
            isbn = nil
        }
        
        if let issnValue = try? container.decodeIfPresent(String.self, forKey: .issn) {
            issn = issnValue
        } else if let issnNumber = try? container.decodeIfPresent(Int.self, forKey: .issn) {
            issn = String(issnNumber)
        } else {
            issn = nil
        }
        
        url = try container.decodeIfPresent(String.self, forKey: .url)
        dateOfEntry = try container.decodeIfPresent(String.self, forKey: .dateOfEntry)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
    }
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case author
        case year
        case publication
        case biblioName = "biblio_name"
        case languagePublished = "language_published"
        case languageResearched = "language_researched"
        case countryOfResearch = "country_of_research"
        case keywords
        case source
        case languageFamily = "language_family"
        case isbn
        case issn
        case url
        case dateOfEntry = "date_of_entry"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Computed Properties
    var authorsDisplay: String {
        author
    }
    
    var yearDisplay: String {
        year?.description ?? "N/A"
    }
    
    var keywordsDisplay: String {
        keywords ?? "N/A"
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Bibliography, rhs: Bibliography) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mock Data for Development
extension Bibliography {
    static func mock() -> Bibliography {
        Bibliography(
            id: UUID().uuidString,
            title: "Sample Research Paper Title",
            author: "John Doe, Jane Smith",
            year: 2024,
            publication: "Journal of Computer Science",
            biblioName: "sample_paper.pdf",
            languagePublished: "English",
            languageResearched: "English",
            countryOfResearch: "United States",
            keywords: "computer science, research, sample",
            source: "Sample source",
            languageFamily: "Indo_European",
            isbn: "1234567890",
            issn: nil,
            url: nil,
            dateOfEntry: nil,
            createdAt: Date(),
            updatedAt: nil
        )
    }
    
    static func mockList() -> [Bibliography] {
        [
            Bibliography(
                id: "1",
                title: "Machine Learning in Modern Applications",
                author: "Alice Johnson, Bob Wilson",
                year: 2024,
                publication: "AI Research Journal",
                biblioName: "ml_paper.pdf",
                languagePublished: "English",
                languageResearched: "English",
                countryOfResearch: "United States",
                keywords: "machine learning, AI, software",
                source: "AI Research Journal",
                languageFamily: "Indo_European",
                isbn: "1234567890",
                issn: nil,
                url: nil,
                dateOfEntry: nil,
                createdAt: Date().addingTimeInterval(-86400),
                updatedAt: nil
            ),
            Bibliography(
                id: "2",
                title: "Data Structures and Algorithms",
                author: "Charlie Brown",
                year: 2023,
                publication: "Computer Science Quarterly",
                biblioName: "dsa_paper.pdf",
                languagePublished: "English",
                languageResearched: "English",
                countryOfResearch: "United States",
                keywords: "data structures, algorithms, computer science",
                source: "Computer Science Quarterly",
                languageFamily: "Indo_European",
                isbn: "1234567890",
                issn: nil,
                url: nil,
                dateOfEntry: nil,
                createdAt: Date().addingTimeInterval(-172800),
                updatedAt: nil
            )
        ]
    }
}
