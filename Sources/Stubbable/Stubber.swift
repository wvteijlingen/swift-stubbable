#if DEBUG

public struct Stubber: Sendable {
    // MARK: - FullyStubbable

    @_disfavoredOverload
    public static func value<T: _FullyStubbable>(_ type: T.Type, _ property: String, _ index: Int, _ symbol: String) -> T {
        T.__stub()
    }

    @_disfavoredOverload
    public static func value<T: _FullyStubbable>(_ type: T?.Type, _ property: String, _ index: Int, _ symbol: String) -> T {
        T.__stub()
    }

    // MARK: - SignedInteger

    public static func value<T: SignedInteger>(_ type: T.Type, _ property: String, _ index: Int, _ symbol: String) -> T {
        T(index)
    }

    public static func value<T: SignedInteger>(_ type: T?.Type, _ property: String, _ index: Int, _ symbol: String) -> T {
        T(index)
    }

    // MARK: - UnsignedInteger

    public static func value<T: UnsignedInteger>(_ type: T.Type, _ property: String, _ index: Int, _ symbol: String) -> T {
        T(index)
    }

    public static func value<T: UnsignedInteger>(_ type: T?.Type, _ property: String, _ index: Int, _ symbol: String) -> T {
        T(index)
    }

    // MARK: - FloatingPoint

    public static func value<T: FloatingPoint>(_ type: T.Type, _ property: String, _ index: Int, _ symbol: String) -> T {
        T(index)
    }

    public static func value<T: FloatingPoint>(_ type: T?.Type, _ property: String, _ index: Int, _ symbol: String) -> T {
        T(index)
    }

    // MARK: - String

    public static func value(_ type: String.Type, _ property: String, _ index: Int, _ symbol: String) -> String {
        property
    }

    public static func value(_ type: String?.Type, _ property: String, _ index: Int, _ symbol: String) -> String {
        property
    }

    // MARK: - Character

    public static func value(_ type: Character.Type, _ property: String, _ index: Int, _ symbol: String) -> String {
        String(property.prefix(1))
    }

    public static func value(_ type: Character?.Type, _ property: String, _ index: Int, _ symbol: String) -> String {
        String(property.prefix(1))
    }

    // MARK: - Bool

    public static func value(_ type: Bool.Type, _ property: String, _ index: Int, _ symbol: String) -> Bool {
        false
    }

    public static func value(_ type: Bool?.Type, _ property: String, _ index: Int, _ symbol: String) -> Bool {
        false
    }

    // MARK: - Array

    public static func value<T>(_ type: [T].Type, _ property: String, _ index: Int, _ symbol: String) -> [T] {
        []
    }

    public static func value<T>(_ type: [T]?.Type, _ property: String, _ index: Int, _ symbol: String) -> [T] {
        []
    }

//    public static func value<T: _FullyStubbable>(_ type: [T].Type, _ property: String, _ index: Int, _ symbol: String) -> [T] {
//        [.__stub(), .__stub()]
//    }

    // MARK: - Set

    public static func value<T>(_ type: Set<T>.Type, _ property: String, _ index: Int, _ symbol: String) -> Set<T> {
        []
    }

    public static func value<T>(_ type: Set<T>?.Type, _ property: String, _ index: Int, _ symbol: String) -> Set<T> {
        []
    }

    // MARK: - Dictionary

    public static func value<T, U>(_ type: [T: U].Type, _ property: String, _ index: Int, _ symbol: String) -> [T: U] {
        [:]
    }

    public static func value<T, U>(_ type: [T: U]?.Type, _ property: String, _ index: Int, _ symbol: String) -> [T: U] {
        [:]
    }

    // MARK: - KeyValuePairs

    public static func value<T, U>(_ type: KeyValuePairs<T, U>.Type, _ property: String, _ index: Int, _ symbol: String) -> KeyValuePairs<T, U> {
        [:]
    }

    public static func value<T, U>(_ type: KeyValuePairs<T, U>?.Type, _ property: String, _ index: Int, _ symbol: String) -> KeyValuePairs<T, U> {
        [:]
    }

    // MARK: - ClosedRange

    public static func value<T: SignedInteger>(_ type: ClosedRange<T>.Type, _ property: String, _ index: Int, _ symbol: String) -> ClosedRange<T> {
        0...100
    }

    public static func value<T: SignedInteger>(_ type: ClosedRange<T>?.Type, _ property: String, _ index: Int, _ symbol: String) -> ClosedRange<T> {
        0...100
    }

    // MARK: - Range

    public static func value<T: SignedInteger>(_ type: Range<T>.Type, _ property: String, _ index: Int, _ symbol: String) -> Range<T> {
        0..<100
    }

    public static func value<T: SignedInteger>(_ type: Range<T>?.Type, _ property: String, _ index: Int, _ symbol: String) -> Range<T> {
        0..<100
    }

    // MARK: - Error

    public static func value<T: Error>(_ type: T.Type, _ property: String, _ index: Int, _ symbol: String) -> Error {
        StubbedError(name: property)
    }

    public static func value<T: Error>(_ type: T?.Type, _ property: String, _ index: Int, _ symbol: String) -> Error {
        StubbedError(name: property)
    }
}

#endif
