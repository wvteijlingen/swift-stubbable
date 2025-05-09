# swift-stubbable

## Usage

```swift
import Foundation
import Stubbable

@Stubbable
struct User {
    let id: String
    let username: String
    let age: Date?
    let isAdmin: Bool
}

// Expands to:

extension User {
    #if STUBS_ENABLED
    static func stub(
        id: String = "id.\(UUID().uuidString)",
        username: String = "username.\(UUID().uuidString)",
        age: Date? = Date(timeIntervalSince1970: 0),
        isAdmin: Bool = false
    ) -> User {
        User(
            id: id,
            username: username,
            age: age,
            isAdmin: isAdmin
        )
    }
    #endif
}

// Can be used in tests as:

let user = User.stub()
```