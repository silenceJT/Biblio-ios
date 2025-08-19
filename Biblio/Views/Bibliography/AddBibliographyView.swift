import SwiftUI

struct AddBibliographyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Add Bibliography")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("This view will be implemented in Phase 3")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Add Bibliography")
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
    AddBibliographyView()
}
