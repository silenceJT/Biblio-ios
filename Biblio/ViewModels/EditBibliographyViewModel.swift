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
            let updated = try await bibliographyService.updateBibliography(bibliography)
            print("Successfully updated bibliography: \(updated.title)")
            showSuccess = true
            
            // Small delay to show success message
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
        } catch {
            showError = true
            errorMessage = error.localizedDescription
            print("Failed to update bibliography: \(error)")
        }
        
        isLoading = false
    }
    
    func deleteBibliography(_ bibliography: Bibliography) async {
        isLoading = true
        showError = false
        errorMessage = nil
        
        do {
            try await bibliographyService.deleteBibliography(bibliography.id)
            print("Successfully deleted bibliography: \(bibliography.title)")
            showSuccess = true
            
        } catch {
            showError = true
            errorMessage = error.localizedDescription
            print("Failed to delete bibliography: \(error)")
        }
        
        isLoading = false
    }
    
    func resetForm() {
        showError = false
        errorMessage = nil
        showSuccess = false
    }
}
