import Foundation

#if DEBUG
public enum DebugLog {
    public static func log(_ message: String, category: String? = nil) {
        let prefix = category.map { "\($0): " } ?? ""
        print("\(prefix)\(message)")
    }
}
#endif 