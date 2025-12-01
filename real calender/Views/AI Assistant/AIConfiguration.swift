import Foundation

struct AIConfiguration {
    // MARK: - API Configuration
    
    /// Google Vision API key - configured and ready to use
    static let googleVisionAPIKey = "AIzaSyDM4vCFfJBJ5sI9zSxBe_bpIT4cljm5j9Y"
    
    // MARK: - API Endpoints
    
    static let googleVisionEndpoint = "https://vision.googleapis.com/v1/images:annotate"
    static let googleTextAnalysisEndpoint = "https://language.googleapis.com/v1/documents:analyzeSentiment"
    
    // MARK: - Model Configuration
    
    static let preferredModel = "google-vision"
    
    // MARK: - Analysis Settings
    
    static let maxImageSize: CGFloat = 1024
    static let imageCompressionQuality: CGFloat = 0.8
    static let maxRetryAttempts = 3
    static let requestTimeout: TimeInterval = 60
    
    // MARK: - Validation
    
    static var isConfigured: Bool {
        return !googleVisionAPIKey.isEmpty
    }
    
    static func validateConfiguration() -> String? {
        if !isConfigured {
            return "API configuration error"
        }
        return nil
    }
}