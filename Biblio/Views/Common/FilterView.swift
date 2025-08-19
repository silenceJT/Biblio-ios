import SwiftUI

struct FilterView: View {
    @Binding var filters: BibliographyFilters
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Filters")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("This view will be implemented in Phase 4")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    FilterView(filters: .constant(BibliographyFilters()))
}
