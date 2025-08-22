import Foundation

struct Bibliography: Codable, Identifiable, Hashable {
    let id: String?
    let title: String
    let author: String
    let year: Int?
    let publication: String?
    let publisher: String?
    let languagePublished: String?
    let languageResearched: String?
    let countryOfResearch: String?
    let keywords: String?
    let source: String?
    let languageFamily: String?
    let biblioName: String?
    let isbn: String?
    let issn: String?
    let url: String?
    let dateOfEntry: String?
    let createdAt: String?
    let updatedAt: String?
    let createdBy: String?
    let updatedBy: String?
    let publicationDate: String?
    
    // MARK: - Initializers
    init(id: String?, title: String, author: String, year: Int?, publication: String?, publisher: String?, languagePublished: String?, languageResearched: String?, countryOfResearch: String?, keywords: String?, source: String?, languageFamily: String?, biblioName: String?, isbn: String?, issn: String?, url: String?, dateOfEntry: String?, createdAt: String?, updatedAt: String?, createdBy: String? = nil, updatedBy: String? = nil, publicationDate: String? = nil) {
        self.id = id
        self.title = title
        self.author = author
        self.year = year
        self.publication = publication
        self.publisher = publisher
        self.languagePublished = languagePublished
        self.languageResearched = languageResearched
        self.countryOfResearch = countryOfResearch
        self.keywords = keywords
        self.source = source
        self.languageFamily = languageFamily
        self.biblioName = biblioName
        self.isbn = isbn
        self.issn = issn
        self.url = url
        self.dateOfEntry = dateOfEntry
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.createdBy = createdBy
        self.updatedBy = updatedBy
        self.publicationDate = publicationDate
    }
    
    // MARK: - Custom Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle _id field - try to decode it, but provide a fallback if missing
        id = try? container.decodeIfPresent(String.self, forKey: .id)
        
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(String.self, forKey: .author)
        year = try container.decodeIfPresent(Int.self, forKey: .year)
        publication = try container.decodeIfPresent(String.self, forKey: .publication)
        publisher = try container.decodeIfPresent(String.self, forKey: .publisher)
        languagePublished = try container.decodeIfPresent(String.self, forKey: .languagePublished)
        languageResearched = try container.decodeIfPresent(String.self, forKey: .languageResearched)
        countryOfResearch = try container.decodeIfPresent(String.self, forKey: .countryOfResearch)
        keywords = try container.decodeIfPresent(String.self, forKey: .keywords)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        languageFamily = try container.decodeIfPresent(String.self, forKey: .languageFamily)
        biblioName = try container.decodeIfPresent(String.self, forKey: .biblioName)
        
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
        
        // Handle date fields as ISO 8601 strings (as per API spec)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        updatedBy = try container.decodeIfPresent(String.self, forKey: .updatedBy)
        publicationDate = try container.decodeIfPresent(String.self, forKey: .publicationDate)
    }
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case author
        case year
        case publication
        case publisher
        case languagePublished = "language_published"
        case languageResearched = "language_researched"
        case countryOfResearch = "country_of_research"
        case keywords
        case source
        case languageFamily = "language_family"
        case biblioName = "biblio_name"
        case isbn
        case issn
        case url
        case dateOfEntry = "date_of_entry"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdBy = "created_by"
        case updatedBy = "updated_by"
        case publicationDate = "publicationDate"
    }
    
    // MARK: - Computed Properties
    var identifier: String {
        id ?? "temp_\(UUID().uuidString)"
    }
    
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
        hasher.combine(identifier)
    }
    
    static func == (lhs: Bibliography, rhs: Bibliography) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
