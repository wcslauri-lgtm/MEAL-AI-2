
import Foundation

enum JSONTools {
    static func sanitizeJSON(_ s: String) -> String {
        guard let start = s.firstIndex(of: "{"), let end = s.lastIndex(of: "}") else { return s }
        return String(s[start...end])
    }
    static func decode<T: Decodable>(_ type: T.Type, from s: String) -> T? {
        if let data = s.data(using: .utf8) { return try? JSONDecoder().decode(T.self, from: data) }
        return nil
    }
}
