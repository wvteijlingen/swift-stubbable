extension StubbableMacro {
    static func defaultValue(forProperty property: String, type: String, attachedSymbol: String) -> String? {
        let nonOptionalType = type.suffix(1) == "?" ? String(type.dropLast()) : type

        // TODO: Improve logic to detect dictionaries
        if nonOptionalType.starts(with: "[") && nonOptionalType.contains(":") && nonOptionalType.suffix(1) == "]" {
            return "[:]"
        }

        // TODO: Improve logic to detect arrays
        if nonOptionalType.starts(with: "[") ||
            nonOptionalType.starts(with: "Array<") ||
            nonOptionalType.starts(with: "Set<")
        {
            return "[]"
        }

        return switch nonOptionalType {
        case "Int", "Int8", "Int16", "Int32", "Int64", "UInt", "UInt8", "UInt16", "UInt32", "UInt64":
            "0"
        case "UUID":
            "UUID()"
        case "String":
            "\"\(property)\""
        case "Character":
            String(type.prefix(1))
        case "Bool":
            "false"
        case "Double":
            "0.0"
        case "Float":
            "0.0"
        case "URL":
            "URL(string: \"https://example.com/\(property)\")!"
        case "Date":
            "Date(timeIntervalSince1970: 0)"
        case "Error", "NSError":
            "NSError(domain: \"\(attachedSymbol).\(property)\", code: 0, userInfo: nil)"
        case "Any", "AnyObject":
            nil
        default:
            ".stub()"
        }
    }
}
