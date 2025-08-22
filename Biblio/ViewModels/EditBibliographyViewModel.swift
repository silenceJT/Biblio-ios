import Foundation
import SwiftUI

@MainActor
class EditBibliographyViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    @Published var showSuccess = false
    
    private let bibliographyService = BibliographyService()
    
    func updateBibliography(_ bibliography: Bibliography) async {
        isLoading = true
        showError = false
        errorMessage = nil
        showSuccess = false
        
        do {
            let _ = try await bibliographyService.updateBibliography(bibliography)
            showSuccess = true
            
            // Small delay to show success message
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteBibliography(_ bibliography: Bibliography) async {
        isLoading = true
        showError = false
        errorMessage = nil
        
        do {
            guard let bibliographyId = bibliography.id else {
                showError = true
                errorMessage = "Cannot delete bibliography without ID"
                isLoading = false
                return
            }
            
            try await bibliographyService.deleteBibliography(bibliographyId)
            showSuccess = true
            
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
