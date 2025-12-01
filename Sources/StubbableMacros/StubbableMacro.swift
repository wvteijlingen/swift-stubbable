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
        let protocolConformances = excludedProperties.isEmpty || structProperties.isEmpty ? ": _FullyStubbable" : ""
        let stubInitializer = structProperties.isEmpty ? "" : generateStubInitializer(properties: structProperties)
        let stubMethod = generateStubMethod(
            properties: structProperties,
            defaults: defaults,
            excludedProperties: excludedProperties,
            attachedSymbol: type.description
        )

        let extensionSyntax: DeclSyntax = """
            extension \(raw: type.description)\(raw: protocolConformances) {
                #if DEBUG
                \(raw: stubInitializer)
                
                \(raw: stubMethod)
            
                // Implementation of _FullyStubbable
                static func _stub() -> Self { .stub() }
                #endif
            }
            """

        guard let extensionDecl = extensionSyntax.as(ExtensionDeclSyntax.self) else {
            fatalError("@Stubbable: Could not convert output to ExtensionDeclSyntax")
        }

        return [extensionDecl]
    }

    private static func generateStubInitializer(
        properties: [(name: String, type: String, initializer: String?)]
    ) -> DeclSyntax {
        let parameters = properties
            .map { (name, type, _) in
                "_stub_\(name): \(type)"
            }
            .joined(separator: ",\n")

        let assignments = properties
            .map { parameter in
                "self.\(parameter.name) = _stub_\(parameter.name)"
            }
            .joined(separator: "\n")

        let syntax: DeclSyntax = """
            private init(
                \(raw: parameters)
            ) {
                \(raw: assignments)
            }
            """

        return syntax
    }

    private static func generateStubMethod(
        properties: [(name: String, type: String, initializer: String?)],
        defaults:  [String: String],
        excludedProperties: [String],
        attachedSymbol: String
    ) -> DeclSyntax {
        let parameters = properties.enumerated()
            .map { (index, element) in
                let name = element.name
                let type = element.type
                let initializer = element.initializer

                let defaultValue: String? = if let customDefault = defaults[name] {
                    customDefault
                } else if let initializer {
                    initializer
                } else if !excludedProperties.contains(name) {
                    "StubbableConfig.value(forType: \(type).self, property: \"\(name)\", index: \(index), symbol: \"\(attachedSymbol)\")"
                } else {
                    nil
                }

                if let defaultValue {
                    return "\(name): \(type) = \(defaultValue)"
                } else {
                    return "\(name): \(type)"
                }
            }
            .joined(separator: ",\n")

        let assignments = properties
            .map { parameter in
                "_stub_\(parameter.name): \(parameter.name)"
            }
            .joined(separator: ",\n")

        let syntax: DeclSyntax = """
            static func stub(
                \(raw: parameters)
            ) -> \(raw: attachedSymbol) {
                \(raw: attachedSymbol)(
                    \(raw: assignments)
                )
            }
        """

        return syntax
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

    private static func parseProperties(from memberBlock: MemberBlockSyntax) -> [(
        name: String,
        type: String,
        initializer: String?
    )] {
        memberBlock.members.compactMap { member in
            guard let variableDecl = member.decl.as(VariableDeclSyntax.self),
                  let binding = variableDecl.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
                  let typeAnnotation = binding.typeAnnotation,
                  binding.accessorBlock == nil // Ignore computed properties
            else {
                return nil
            }

            return (
                identifier.identifier.text,
                typeAnnotation.type.description,
                binding.initializer?.value.description
            )
        }
    }
}
