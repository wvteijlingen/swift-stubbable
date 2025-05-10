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
            @Stubbable(exclude: ["id"])
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
                    b: String = "b.\\(UUID().uuidString)",
                    c: Bool = false,
                    d: URL = URL(string: "https://example.com/d/\\(UUID().uuidString)")!,
                    e: Date? = Date(timeIntervalSince1970: 0),
                    f: [Int] = [],
                    g: Bar? = .stub(),
                    h: Bar = .stub()
                ) -> Foo {
                    Foo(
                        id: id,
                        a: a,
                        b: b,
                        c: c,
                        d: d,
                        e: e,
                        f: f,
                        g: g,
                        h: h
                    )
                }
                #endif
            }
            """,
            macros: testMacros
        )
    }
}
