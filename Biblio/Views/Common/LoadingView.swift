import SwiftUI

struct LoadingView: View {
    let message: String
    let showSpinner: Bool
    
    init(message: String = "Loading...", showSpinner: Bool = true) {
        self.message = message
        self.showSpinner = showSpinner
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if showSpinner {
                ProgressView()
                    .scaleEffect(1.2)
                    .progressViewStyle(CircularProgressViewStyle())
            }
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Loading Button
struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                
                Text(title)
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(isLoading)
    }
}

// MARK: - Loading Row
struct LoadingRow: View {
    let message: String
    
    var body: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Loading Overlay
struct LoadingOverlay: View {
    let message: String
    let isVisible: Bool
    
    var body: some View {
        if isVisible {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .shadow(radius: 10)
                )
            }
        }
    }
}

// MARK: - Skeleton Loading
struct SkeletonRow: View {
    let height: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .frame(height: height)
            .cornerRadius(8)
            .shimmer()
    }
}

struct SkeletonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title skeleton
            SkeletonRow(height: 20)
            
            // Author skeleton
            SkeletonRow(height: 16)
            
            // Year and journal skeleton
            HStack {
                SkeletonRow(height: 16)
                Spacer()
                SkeletonRow(height: 16)
            }
            
            // Keywords skeleton
            HStack {
                SkeletonRow(height: 24)
                SkeletonRow(height: 24)
                SkeletonRow(height: 24)
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Shimmer Effect
extension View {
    func shimmer() -> some View {
        self.overlay(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.white.opacity(0.3),
                    Color.clear
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: -200)
            .animation(
                Animation.linear(duration: 1.5)
                    .repeatForever(autoreverses: false),
                value: UUID()
            )
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingView(message: "Loading bibliographies...")
        
        LoadingButton(title: "Save", isLoading: true) {}
        
        LoadingRow(message: "Loading...")
        
        SkeletonCard()
    }
    .padding()
}
