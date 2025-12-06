# swift-stubbable

`swift-stubbable` provides a Swift macro designed to autogenerate stub data for testing purposes.

## Installation

Add the following to your Package.swift dependencies:

```swift
.package(url: "https://github.com/wvteijlingen/swift-stubbable.git", from: "0.1.0")
```

## Usage

Attach the `@Stubbable` macro to a struct or class that you want to stub:

```swift
import Stubbable

@Stubbable
struct Company {
    let name: String
}

@Stubbable
struct User {
    let id: String
    let username: String
    let age: Date?
    let isAdmin: Bool
    let company: Company
}

// Usage
let stubbedUser = User.stub()
```

This will generate an extension that contains a static `stub` method, containing parameters and default values
for every property in the type. The `stub` method is gated behind an `#if DEBUG` compiler condition, ensuring
that stub code will not be included into a release build.

## Excluding properties

Using the `exclude` parameter, you can specify properties that should not have a default value in the stub.
This can be useful if you want to enforce the call site to supply a value, or when a referenced property type itself
is not stubbable.

Here we exclude the "id" and "company" properties, forcing the call site to supply a value for those properties:

```swift
@Stubbable(exclude: ["id", "company"])
struct User {
    let id: String
    let username: String
    let company: Company
}

// Usage
let stubbedUser = User.stub(id: "1", company: Company(name: "ACME"))
```

## Custom default values

Stubbable can generate a suitable default value for most built-in types. However, you can customize the default values
globally for all stubs or individually for a single stubbable type.

### Configuring global defaults

You can extend the `Stubber` type to provide default values by adding methods that provide a value for a
specific type.

Each method takes following parameter:
- `_ type: [type]`: The type for which to provide a value.
- `_ property: String`: The name of the stubbed property.
- `_ index: Int`: The index of the stubbed property. This can be useful to provide unique values per property.
- `_ symbol: String`: The name of the stubbed struct or class.

The following code snippet configures overrides the default values for the `String` and `SignedInteger` type. It also
provides a value for our custom `Company` type. 

> Tip: By using protocols like `SignedInteger` you don't have to specify defaults for every integer type
(Int, Int16, etc.)

```swift
extension Stubber {
    static func value(_ type: String.Type, _ property: String, index: Int, _ symbol: String) -> String {
        "customDefaultString"
    }
    
    static func value<T: SignedInteger>(_ type: T.Type, _ property: String, index: Int, _ symbol: String) -> T {
        10
    }
    
    static func value(_ type: Company, _ property: String, index: Int, _ symbol: String) -> Bar {
        Company(name: "ACME")
    }
}
```

### Configuring default per type

If you just want to override a default value for one specific stubbed struct or class, you can use the `defaults`
parameter: 

```swift
@Stubbable(defaults: [
    "id": "customDefaultId",
    "company": Company("ACME")
])
struct User {
    let id: String
    let username: String
    let company: Company
}
```


## Known issues

- Properties are only included in the `.stub` method when they have an explicit type annotation.
