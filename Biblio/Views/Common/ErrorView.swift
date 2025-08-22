import SwiftUI

struct ErrorView: View {
    let error: String
    let retryAction: (() -> Void)?
    let dismissAction: (() -> Void)?
    
    init(error: String, retryAction: (() -> Void)? = nil, dismissAction: (() -> Void)? = nil) {
        self.error = error
        self.retryAction = retryAction
        self.dismissAction = dismissAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Error Icon
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            // Error Title
            Text("Something went wrong")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Error Message
            Text(error)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Action Buttons
            HStack(spacing: 16) {
                if let retryAction = retryAction {
                    Button("Try Again") {
                        retryAction()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                if let dismissAction = dismissAction {
                    Button("Dismiss") {
                        dismissAction()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Error Row
struct ErrorRow: View {
    let error: String
    let retryAction: (() -> Void)?
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
                .font(.caption)
            
            Text(error)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Spacer()
            
            if let retryAction = retryAction {
                Button("Retry") {
                    retryAction()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Error Banner
struct ErrorBanner: View {
    let error: String
    let isVisible: Bool
    let dismissAction: () -> Void
    
    var body: some View {
        if isVisible {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.white)
                
                Text(error)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Spacer()
                
                Button("Dismiss") {
                    dismissAction()
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.2))
                .cornerRadius(4)
            }
            .padding()
            .background(Color.red)
            .cornerRadius(8)
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.3), value: isVisible)
        }
    }
}

// MARK: - Network Error View
struct NetworkErrorView: View {
    let error: NetworkError
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            // Error Icon based on error type
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundColor(iconColor)
            
            // Error Title
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            // Error Message
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Additional help text
            if let helpText = helpText {
                Text(helpText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Action Buttons
            HStack(spacing: 16) {
                if let retryAction = retryAction {
                    Button("Try Again") {
                        retryAction()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Button("Check Settings") {
                    // Open system settings
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private var iconName: String {
        switch error {
        case .noInternetConnection:
            return "wifi.slash"
        case .unauthorized, .forbidden:
            return "lock.shield"
        case .notFound:
            return "magnifyingglass"
        case .serverError:
            return "server.rack"
        default:
            return "exclamationmark.triangle"
        }
    }
    
    private var iconColor: Color {
        switch error {
        case .noInternetConnection:
            return .orange
        case .unauthorized, .forbidden:
            return .red
        case .notFound:
            return .blue
        case .serverError:
            return .purple
        default:
            return .orange
        }
    }
    
    private var title: String {
        switch error {
        case .noInternetConnection:
            return "No Internet Connection"
        case .unauthorized:
            return "Access Denied"
        case .forbidden:
            return "Forbidden"
        case .notFound:
            return "Not Found"
        case .serverError:
            return "Server Error"
        default:
            return "Something went wrong"
        }
    }
    
    private var helpText: String? {
        switch error {
        case .noInternetConnection:
            return "Please check your internet connection and try again."
        case .unauthorized:
            return "Please log in again to continue."
        case .forbidden:
            return "You don't have permission to access this resource."
        case .notFound:
            return "The requested resource could not be found."
        case .serverError:
            return "Our servers are experiencing issues. Please try again later."
        default:
            return nil
        }
    }
}

// MARK: - Validation Error View
struct ValidationErrorView: View {
    let errors: [String]
    let dismissAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Error Icon
            Image(systemName: "checkmark.circle.badge.xmark")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            // Error Title
            Text("Validation Errors")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Error List
            VStack(alignment: .leading, spacing: 8) {
                ForEach(errors, id: \.self) { error in
                    HStack(alignment: .top) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        
                        Text(error)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Dismiss Button
            Button("OK") {
                dismissAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    VStack(spacing: 20) {
        ErrorView(error: "Failed to load data", retryAction: {
            // Retry action for preview
        })
        
        ErrorRow(error: "Network error occurred", retryAction: {
            // Retry action for preview
        })
        
        NetworkErrorView(error: .noInternetConnection) {
            // Retry action for preview
        }
        
        ValidationErrorView(errors: [
            "Title is required",
            "At least one author is required",
            "Publication year must be valid"
        ]) {
            // Dismiss action for preview
        }
    }
    .padding()
}
