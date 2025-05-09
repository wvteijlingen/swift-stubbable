import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct StubbableMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StubbableMacro.self
    ]
}
