@attached(extension, conformances: _FullyStubbable, names: named(init), named(stub), named(_stub))
public macro Stubbable(
    exclude: [String] = [],
    defaults: [String: Any] = [:]
) = #externalMacro(module: "StubbableMacros", type: "StubbableMacro")
