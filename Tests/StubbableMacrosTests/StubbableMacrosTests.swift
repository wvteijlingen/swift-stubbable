import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import StubbableMacros

let testMacros: [String: Macro.Type] = [
    "Stubbable": StubbableMacro.self,
]

final class StubbableMacrosTests: XCTestCase {
    func testMacro() throws {
        assertMacroExpansion(
            """
            @Stubbable(ignore: ["id"])
            struct Foo {
                let id: String
                let a: Int
                let b: String
                let c: Bool
                let d: URL
                let e: Date?
                let f: [Int]
                let g: Bar?
                let h: Bar
            }
            """,
            expandedSource:
            """
            struct Foo {
                let id: String
                let a: Int
                let b: String
                let c: Bool
                let d: URL
                let e: Date?
                let f: [Int]
                let g: Bar?
                let h: Bar
            }
            
            extension Foo {
                #if STUBS_ENABLED
                static func stub(
                    id: String,
                    a: Int = 0,
                    b: String = "b",
                    c: Bool = false,
                    d: URL = URL(string: "https://example.com/d")!,
                    e: Date? = Date(timeIntervalSince1970: 0),
                    f: [Int] = [],
                    g: Bar? = nil,
                    h: Bar = .stub()
                ) -> Foo {
                    Foo(
                        id: String,
                        a: Int,
                        b: String,
                        c: Bool,
                        d: URL,
                        e: Date?,
                        f: [Int],
                        g: Bar?,
                        h: Bar
                    )
                }
                #endif
            }
            """,
            macros: testMacros
        )
    }
}
