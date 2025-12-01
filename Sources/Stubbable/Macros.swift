@attached(extension, conformances: _FullyStubbable, names: arbitrary)
public macro Stubbable(
    exclude: [String] = [],
    defaults: [String: Any] = [:]
) = #externalMacro(module: "StubbableMacros", type: "StubbableMacro")
