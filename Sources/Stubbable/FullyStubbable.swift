/// A type that can be instantiated as a stub without arguments.
///
/// > Warning: Don't rely on this protocol or implement it yourself, it is an implementation detail of
/// the `@Stubbable` macro.
public protocol _FullyStubbable {
    /// > Warning: Don't call this method directly, it is an implementation detail of the `@Stubbable` macro.
    static func __stub() -> Self
}

extension Optional: _FullyStubbable {
    public static func __stub() -> Self where Wrapped: _FullyStubbable {
        let stub = Wrapped.__stub()
        return .some(stub)
    }

    public static func __stub() -> Self {
        .none
    }
}
