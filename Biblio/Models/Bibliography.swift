import Foundation

struct Bibliography: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let authors: [String]
    let publicationYear: Int?
    let journal: String?
    let doi: String?
    let abstract: String?
    let keywords: [String]
    let createdAt: Date
    let updatedAt: Date
    let userId: String
    
    // MARK: - Computed Properties
    var authorsDisplay: String {
        authors.joined(separator: ", ")
    }
    
    var yearDisplay: String {
        publicationYear?.description ?? "N/A"
    }
    
    var keywordsDisplay: String {
        keywords.joined(separator: ", ")
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
            authors: ["John Doe", "Jane Smith"],
            publicationYear: 2024,
            journal: "Journal of Computer Science",
            doi: "10.1000/example.doi",
            abstract: "This is a sample abstract for development and testing purposes.",
            keywords: ["computer science", "research", "sample"],
            createdAt: Date(),
            updatedAt: Date(),
            userId: "user123"
        )
    }
    
    static func mockList() -> [Bibliography] {
        [
            Bibliography(
                id: "1",
                title: "Machine Learning in Modern Applications",
                authors: ["Alice Johnson", "Bob Wilson"],
                publicationYear: 2024,
                journal: "AI Research Journal",
                doi: "10.1000/ml.paper",
                abstract: "An overview of machine learning applications in modern software development.",
                keywords: ["machine learning", "AI", "software"],
                createdAt: Date().addingTimeInterval(-86400),
                updatedAt: Date().addingTimeInterval(-86400),
                userId: "user123"
            ),
            Bibliography(
                id: "2",
                title: "Data Structures and Algorithms",
                authors: ["Charlie Brown"],
                publicationYear: 2023,
                journal: "Computer Science Quarterly",
                doi: "10.1000/dsa.paper",
                abstract: "Comprehensive study of fundamental data structures and algorithms.",
                keywords: ["data structures", "algorithms", "computer science"],
                createdAt: Date().addingTimeInterval(-172800),
                updatedAt: Date().addingTimeInterval(-172800),
                userId: "user123"
            )
        ]
    }
}
