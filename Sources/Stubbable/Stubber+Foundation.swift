#if DEBUG
#if canImport(Foundation)

import Foundation

extension Stubber {
    // MARK: - UUID

    public static func value(_ type: UUID.Type, _ property: String, _ index: Int, _ symbol: String) -> UUID {
        UUID()
    }

    public static func value(_ type: UUID?.Type, _ property: String, _ index: Int, _ symbol: String) -> UUID {
        UUID()
    }

    // MARK: - URL

    public static func value(_ type: URL.Type, _ property: String, _ index: Int, _ symbol: String) -> URL {
        URL(string: "https://example.com/\(property)")!
    }

    public static func value(_ type: URL?.Type, _ property: String, _ index: Int, _ symbol: String) -> URL {
        URL(string: "https://example.com/\(property)")!
    }

    // MARK: - Date

    public static func value(_ type: Date.Type, _ property: String, _ index: Int, _ symbol: String) -> Date {
        Date(timeIntervalSince1970: Double(index))
    }

    public static func value(_ type: Date?.Type, _ property: String, _ index: Int, _ symbol: String) -> Date {
        Date(timeIntervalSince1970: Double(index))
    }

    // MARK: - NSError

    public static func value(_ type: NSError.Type, _ property: String, _ index: Int, _ symbol: String) -> NSError {
        NSError(domain: "\(symbol).\(property)", code: index, userInfo: nil)
    }

    public static func value(_ type: NSError?.Type, _ property: String, _ index: Int, _ symbol: String) -> NSError {
        NSError(domain: "\(symbol).\(property)", code: index, userInfo: nil)
    }

    // MARK: - DateInterval

    public static func value(_ type: DateInterval, _ property: String, _ index: Int, _ symbol: String) -> DateInterval {
        DateInterval(start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100))
    }

    public static func value(_ type: DateInterval?, _ property: String, _ index: Int, _ symbol: String) -> DateInterval {
        DateInterval(start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100))
    }
}

#endif
#endif
