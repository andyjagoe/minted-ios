import Foundation
import MintedUI

public enum AppConfig {
    public enum Environment {
        case development
        case production
        
        var apiBaseURL: String {
            switch self {
            case .development:
                return "http://localhost:3000/api"
            case .production:
                return "https://minted-api.vercel.app/api"
            }
        }
    }
    
    #if DEBUG
    public static let environment: Environment = .development
    #else
    public static let environment: Environment = .production
    #endif
    
    public static var apiBaseURL: String {
        let url = environment.apiBaseURL
        #if DEBUG
        DebugLog.log("Using \(environment) environment", category: "AppConfig")
        DebugLog.log("API Base URL: \(url)", category: "AppConfig")
        #endif
        return url
    }
} 