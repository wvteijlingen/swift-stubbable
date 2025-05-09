struct StubbedProperty {
    let parameterName: String
    let parameterType: String
    let parameterDefaultValue: String?
    let propertyName: String
    let propertyAssignment: String

    init(
        parameterName: String,
        parameterType: String,
        parameterDefaultValue: String?,
        propertyName: String,
        propertyAssignment: String
    ) {
        self.parameterName = parameterName
        self.parameterType = parameterType
        self.parameterDefaultValue = parameterDefaultValue
        self.propertyName = propertyName
        self.propertyAssignment = propertyAssignment
    }

    init(
        parameterName: String,
        parameterType: String,
        parameterDefaultValue: String?
    ) {
        self.init(
            parameterName: parameterName,
            parameterType: parameterType,
            parameterDefaultValue: parameterDefaultValue,
            propertyName: parameterName,
            propertyAssignment: parameterName
        )
    }
}

extension StubbedProperty {
    static func `for`(propertyName: String, type: String, attachedSymbol: String) -> StubbedProperty {
        let nonOptionalType = type.suffix(1) == "?" ? String(type.dropLast()) : type

        // TODO: Improve logic to detect dictionaries
        if nonOptionalType.starts(with: "[") &&
            nonOptionalType.contains(":") &&
            nonOptionalType.suffix(1) == "]"
        {
            return StubbedProperty(
                parameterName: propertyName,
                parameterType: type,
                parameterDefaultValue: "[:]"
            )
        }

        if nonOptionalType.starts(with: "[") ||
            nonOptionalType.starts(with: "Array<") ||
            nonOptionalType.starts(with: "Set<")
        {
            return StubbedProperty(
                parameterName: propertyName,
                parameterType: type,
                parameterDefaultValue: "[]"
            )
        }

        let parameterDefaultValue: String? = switch nonOptionalType {
        case "Int", "Int8", "Int16", "Int32", "Int64", "UInt", "UInt8", "UInt16", "UInt32", "UInt64":
            "0"
        case "UUID":
            "UUID().uuidString"
        case "String":
            "\"\(propertyName).\\(UUID().uuidString)\""
        case "Character":
            String(type.prefix(1))
        case "Bool":
            "false"
        case "Double":
            "0.0"
        case "Float":
            "0.0"
        case "URL":
            "URL(string: \"https://example.com/\(propertyName)/\\(UUID().uuidString)\")!"
        case "Date":
            "Date(timeIntervalSince1970: 0)"
        case "Error":
            "NSError(domain: \"\(attachedSymbol).\(propertyName)\", code: 0, userInfo: nil)"
        case "Any", "AnyObject":
            nil
        default:
            ".stub()"
        }

        return StubbedProperty(
            parameterName: propertyName,
            parameterType: type,
            parameterDefaultValue: parameterDefaultValue
        )
    }

    static func `for`(ignoredPropertyName name: String, type: String) -> StubbedProperty {
        if type.suffix(1) == "?" {
            StubbedProperty(parameterName: name, parameterType: type, parameterDefaultValue: "nil")
        } else {
            StubbedProperty(parameterName: name, parameterType: type, parameterDefaultValue: nil)
        }
    }
}
