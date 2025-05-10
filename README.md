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

struct Company {}

@Stubbable
struct User {
    let id: String
    let username: String
    let age: Date?
    let isAdmin: Bool
    let company: Company
}
```

This will generate an extension that contains a static `stub` method, containing parameters and default values for every property in the type:

```swift
extension User {
    #if STUBS_ENABLED
    static func stub(
        id: String = "id.\(UUID().uuidString)",
        username: String = "username.\(UUID().uuidString)",
        age: Date? = Date(timeIntervalSince1970: 0),
        isAdmin: Bool = false,
        company: Company = .stub()
    ) -> User {
        User(
            id: id,
            username: username,
            age: age,
            isAdmin: isAdmin,
            company: company
        )
    }
    #endif
}
```

## Excluding properties

Using the `exclude` parameter, you can specify properties that should not have default value in the stub. This can be useful if you want to enforce the call site to supply a value, or when a referenced property type does not conform to Stubbable.

Here we exclude the "id" and "company" properties, forcing the call site to supply a value for those parameters:

```swift
@Stubbable(exclude: ["id", "company"])
struct User {
    let id: String
    let username: String
    let company: Company
}
```

Will expand to:

```swift
extension User {
    #if STUBS_ENABLED
    static func stub(
        id: String,
        username: String = "username.\(UUID().uuidString)",
        company: Company,
    ) -> User {
        User(
            id: id,
            username: username,
            company: company
        )
    }
    #endif
}
```
