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
            let _ = try await bibliographyService.createBibliography(bibliography)
            showSuccess = true
            
            // Small delay to show success message
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func resetForm() {
        showError = false
        errorMessage = nil
        showSuccess = false
    }
}
