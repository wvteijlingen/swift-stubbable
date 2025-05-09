@attached(extension, names: arbitrary)
public macro Stubbable(ignore: [String] = []) = #externalMacro(module: "StubbableMacros", type: "StubbableMacro")
