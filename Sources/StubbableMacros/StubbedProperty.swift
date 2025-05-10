struct StubbedProperty {
    let name: String
    let type: String
    let defaultValue: String?

    init(
        name: String,
        type: String,
        defaultValue: String?
    ) {
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
    }
}

extension StubbedProperty {
    static func `for`(property: String, type: String, attachedSymbol: String) -> StubbedProperty {
        let nonOptionalType = type.suffix(1) == "?" ? String(type.dropLast()) : type

        // TODO: Improve logic to detect dictionaries
        if nonOptionalType.starts(with: "[") && nonOptionalType.contains(":") && nonOptionalType.suffix(1) == "]" {
            return StubbedProperty(
                name: property,
                type: type,
                defaultValue: "[:]"
            )
        }

        // TODO: Improve logic to detect arrays
        if nonOptionalType.starts(with: "[") ||
            nonOptionalType.starts(with: "Array<") ||
            nonOptionalType.starts(with: "Set<")
        {
            return StubbedProperty(
                name: property,
                type: type,
                defaultValue: "[]"
            )
        }

        let parameterDefaultValue: String? = switch nonOptionalType {
        case "Int", "Int8", "Int16", "Int32", "Int64", "UInt", "UInt8", "UInt16", "UInt32", "UInt64":
            "0"
        case "UUID":
            "UUID().uuidString"
        case "String":
            "\"\(property).\\(UUID().uuidString)\""
        case "Character":
            String(type.prefix(1))
        case "Bool":
            "false"
        case "Double":
            "0.0"
        case "Float":
            "0.0"
        case "URL":
            "URL(string: \"https://example.com/\(property)/\\(UUID().uuidString)\")!"
        case "Date":
            "Date(timeIntervalSince1970: 0)"
        case "Error":
            "NSError(domain: \"\(attachedSymbol).\(property)\", code: 0, userInfo: nil)"
        case "Any", "AnyObject":
            nil
        default:
            ".stub()"
        }

        return StubbedProperty(
            name: property,
            type: type,
            defaultValue: parameterDefaultValue
        )
    }

    static func `for`(excludedProperty name: String, type: String) -> StubbedProperty {
        if type.suffix(1) == "?" {
            StubbedProperty(name: name, type: type, defaultValue: "nil")
        } else {
            StubbedProperty(name: name, type: type, defaultValue: nil)
        }
    }
}
