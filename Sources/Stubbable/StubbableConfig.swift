#if DEBUG

#if canImport(Foundation)
import Foundation
#endif

public protocol _FullyStubbable {
    static func _stub() -> Self
}

extension Optional: _FullyStubbable {
    public static func _stub() -> Self { .none }
}

open class StubbableConfig {
    public static var stubber: StubbableConfig { StubbableConfig() }

    open func value<T: _FullyStubbable>(forType type: T.Type, property: String, index: Int, symbol: String) -> T {
        T._stub()
    }

    open func value<T: SignedInteger>(forType type: T.Type, property: String, index: Int, symbol: String) -> T {
        T(index)
    }

    open func value<T: FloatingPoint>(forType type: T.Type, property: String, index: Int, symbol: String) -> T {
        T(index)
    }

    open func value(forType type: String.Type, property: String, index: Int, symbol: String) -> String {
        property
    }

    open func value(forType type: Character.Type, property: String, index: Int, symbol: String) -> String {
        String(property.prefix(1))
    }

    open func value(forType type: Bool.Type, property: String, index: Int, symbol: String) -> Bool {
        false
    }
}

#if canImport(Foundation)
import Foundation
extension StubbableConfig {
    open func value(forType type: UUID.Type, property: String, index: Int, symbol: String) -> UUID {
        UUID()
    }

    open func value(forType type: URL.Type, property: String, index: Int, symbol: String) -> URL {
        URL(string: "https://example.com/\(property)")!
    }

    open func value(forType type: Date.Type, property: String, index: Int, symbol: String) -> Date {
        Date(timeIntervalSince1970: 0)
    }

    open func value<T: Error>(forType type: T.Type, property: String, index: Int, symbol: String) -> Error {
        NSError(domain: "\(symbol).\(property)", code: 0, userInfo: nil)
    }

    open func value(forType type: NSError.Type, property: String, index: Int, symbol: String) -> NSError {
        NSError(domain: "\(symbol).\(property)", code: 0, userInfo: nil)
    }
}
#endif

#endif
