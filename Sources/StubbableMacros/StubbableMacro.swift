import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct StubbableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let excludedProperties = parseExcludeParameter(from: node)
        let defaults = parseDefaultsParameter(from: node)

        let structDecl = declaration.as(StructDeclSyntax.self)
        let classDecl = declaration.as(ClassDeclSyntax.self)
        let attachedSymbol = structDecl?.name.text ?? classDecl?.name.text

        guard let attachedSymbol else {
            context.diagnose(
                Diagnostic(
                    node: declaration,
                    message: MacroExpansionErrorMessage("Macro error: could not extract type name")
                )
            )

            return []
        }

        guard let memberBlock = structDecl?.memberBlock ?? classDecl?.memberBlock else {
            context.diagnose(
                Diagnostic(
                    node: declaration,
                    message: MacroExpansionErrorMessage("@Stubbable can only be applied to structs or classes")
                )
            )

            return []
        }

        let structProperties = parseProperties(from: memberBlock)

        for property in excludedProperties {
            if structProperties.contains(where: { $0.0 == property }) == false {
                context.diagnose(
                    Diagnostic(
                        node: declaration,
                        message: MacroExpansionErrorMessage(
                            "Excluded property '\(property)' is not present in '\(attachedSymbol)'"
                        )
                    )
                )
            }
        }

        let parameters = structProperties
            .map { (name, type) in
                let defaultValue = if let customDefault = defaults[name] {
                    customDefault
                } else if excludedProperties.contains(name) {
                    type.suffix(1) == "?" ? "nil" : nil
                } else {
                    defaultValue(forProperty: name, type: type, attachedSymbol: attachedSymbol)
                }

                if let defaultValue {
                    return "\(name): \(type) = \(defaultValue)"
                } else {
                    return "\(name): \(type)"
                }
            }
            .joined(separator: ",\n")

        let assignments = structProperties
            .map { parameter in
                "\(parameter.name): \(parameter.name)"
            }
            .joined(separator: ",\n")

        let stubFunction: DeclSyntax = """
            extension \(raw: attachedSymbol) {
                #if DEBUG
                static func stub(
                    \(raw: parameters)
                ) -> \(raw: attachedSymbol) {
                    \(raw: attachedSymbol)(
                        \(raw: assignments)
                    )
                }
                #endif
            }
            """

        guard let extensionDecl = stubFunction.as(ExtensionDeclSyntax.self) else {
            fatalError("@Stubbable: Could not convert output to ExtensionDeclSyntax")
        }

        return [extensionDecl]
    }

    private static func parseExcludeParameter(from node: AttributeSyntax) -> [String] {
        guard case let .argumentList(arguments) = node.arguments,
              let argument = arguments.first(where: { $0.label?.text == "exclude" }),
              let expression = argument.expression.as(ArrayExprSyntax.self)
        else {
            return []
        }

        return expression.elements
            .children(viewMode: .sourceAccurate)
            .compactMap { arrayElement in
                arrayElement.as(ArrayElementSyntax.self)?
                    .expression
                    .as(StringLiteralExprSyntax.self)?
                    .segments
                    .first?
                    .description
            }
    }

    private static func parseDefaultsParameter(from node: AttributeSyntax) -> [String: String] {
        guard case let .argumentList(arguments) = node.arguments,
              let argument = arguments.first(where: { $0.label?.text == "defaults" }),
              let expression = argument.expression.as(DictionaryExprSyntax.self)
        else {
            return [:]
        }

        var defaults: [String: String] = [:]

        expression.content
            .children(viewMode: .sourceAccurate)
            .forEach { syntax in
                let key = syntax.as(DictionaryElementSyntax.self)?
                        .key
                        .as(StringLiteralExprSyntax.self)?
                        .segments
                        .first?
                        .description

                let value = syntax.as(DictionaryElementSyntax.self)?.value.trimmed.description

                if let key, let value {
                    defaults[key] = value
                }
            }

        return defaults
    }

    private static func parseProperties(from memberBlock: MemberBlockSyntax) -> [(name: String, type: String)] {
        memberBlock.members.compactMap { member -> (String, String)? in
            guard let variableDecl = member.decl.as(VariableDeclSyntax.self),
                  let binding = variableDecl.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
                  let typeAnnotation = binding.typeAnnotation
            else {
                return nil
            }

            return (identifier.identifier.text, typeAnnotation.type.description)
        }
    }
}
