import Foundation
import SwiftUI

@MainActor
class AddBibliographyViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    @Published var showSuccess = false
    
    private let bibliographyService = BibliographyService()
    
    func createBibliography(_ bibliography: Bibliography) async {
        isLoading = true
        showError = false
        errorMessage = nil
        showSuccess = false
        
        do {
            let created = try await bibliographyService.createBibliography(bibliography)
            print("Successfully created bibliography: \(created.title)")
            showSuccess = true
            
            // Small delay to show success message
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
        } catch {
            showError = true
            errorMessage = error.localizedDescription
            print("Failed to create bibliography: \(error)")
        }
        
        isLoading = false
    }
    
    func resetForm() {
        showError = false
        errorMessage = nil
        showSuccess = false
    }
}
