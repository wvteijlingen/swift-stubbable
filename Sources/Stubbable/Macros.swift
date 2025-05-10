@attached(extension, names: arbitrary)
public macro Stubbable(exclude: [String] = []) = #externalMacro(module: "StubbableMacros", type: "StubbableMacro")
