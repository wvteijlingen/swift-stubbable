#if DEBUG

#if canImport(Foundation)
import Foundation
#endif

/// A type that can be instantiated using a stub method without arguments.
///
/// > Warning: Don't rely on this protocol or implement it yourself, it is an implementation detail of
/// the `@Stubbable` macro.
public protocol _FullyStubbable {
    /// > Warning: Don't use this method directly, it is an implementation detail of the `@Stubbable` macro.
    static func _stub() -> Self
}

extension Optional: _FullyStubbable {
    public static func _stub() -> Self { .none }
}

public struct StubbableConfig: Sendable {
    public static let stubber = StubbableConfig()

    public static func value<T: _FullyStubbable>(forType type: T.Type, property: String, index: Int, symbol: String) -> T {
        T._stub()
    }

    public static func value<T: SignedInteger>(forType type: T.Type, property: String, index: Int, symbol: String) -> T {
        T(index)
    }

    public static func value<T: UnsignedInteger>(forType type: T.Type, property: String, index: Int, symbol: String) -> T {
        T(index)
    }

    public static func value<T: FloatingPoint>(forType type: T.Type, property: String, index: Int, symbol: String) -> T {
        T(index)
    }

    public static func value(forType type: String.Type, property: String, index: Int, symbol: String) -> String {
        property
    }

    public static func value(forType type: Character.Type, property: String, index: Int, symbol: String) -> String {
        String(property.prefix(1))
    }

    public static func value(forType type: Bool.Type, property: String, index: Int, symbol: String) -> Bool {
        false
    }

    public static func value<T>(forType type: [T].Type, property: String, index: Int, symbol: String) -> [T] {
        []
    }

//    public static func value<T: _FullyStubbable>(forType type: [T].Type, property: String, index: Int, symbol: String) -> [T] {
//        [._stub(), ._stub()]
//    }

    public static func value<T, U>(forType type: [T: U].Type, property: String, index: Int, symbol: String) -> [T: U] {
        [:]
    }

    public static func value<T: SignedInteger>(forType type: ClosedRange<T>.Type, property: String, index: Int, symbol: String) -> ClosedRange<T> {
        0...100
    }

    public static func value<T: SignedInteger>(forType type: Range<T>.Type, property: String, index: Int, symbol: String) -> Range<T> {
        0..<100
    }
}

#if canImport(Foundation)
import Foundation
extension StubbableConfig {
    public static func value(forType type: UUID.Type, property: String, index: Int, symbol: String) -> UUID {
        UUID()
    }

    public static func value(forType type: URL.Type, property: String, index: Int, symbol: String) -> URL {
        URL(string: "https://example.com/\(property)")!
    }

    public static func value(forType type: Date.Type, property: String, index: Int, symbol: String) -> Date {
        Date(timeIntervalSince1970: Double(index))
    }

    public static func value<T: Error>(forType type: T.Type, property: String, index: Int, symbol: String) -> Error {
        NSError(domain: "\(symbol).\(property)", code: index, userInfo: nil)
    }

    public static func value(forType type: NSError.Type, property: String, index: Int, symbol: String) -> NSError {
        NSError(domain: "\(symbol).\(property)", code: index, userInfo: nil)
    }

    public static func value(forType type: DateInterval, property: String, index: Int, symbol: String) -> DateInterval {
        DateInterval(start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100))
    }
}
#endif

#endif
