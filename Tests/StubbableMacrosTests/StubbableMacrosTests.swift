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
        let fooDeclaration = """
        struct Foo {
            let a: ExcludedPropertyType
            let b: Int
            let c: String
            let d: Bool
            let e: URL
            let f: Date?
            let g: [Int]
            let h: CustomType
            let i: CustomType?
            let j: Error
            let k: Array<Int>
            let l: Set<Int>
            let m: [String: Bool]
            let n: Any
            let o: AnyObject
            let p: UUID
            let q: Int
        }
        """

        let source = """
        @Stubbable(exclude: ["a"], defaults: ["q": 999])
        \(fooDeclaration)
        """

        let expandedSource = """
        \(fooDeclaration)
        
        extension Foo {
            #if DEBUG
            static func stub(
                a: ExcludedPropertyType,
                b: Int = 0,
                c: String = "c",
                d: Bool = false,
                e: URL = URL(string: "https://example.com/e")!,
                f: Date? = Date(timeIntervalSince1970: 0),
                g: [Int] = [],
                h: CustomType = .stub(),
                i: CustomType? = .stub(),
                j: Error = NSError(domain: "Foo.j", code: 0, userInfo: nil),
                k: Array<Int> = [],
                l: Set<Int> = [],
                m: [String: Bool] = [:],
                n: Any,
                o: AnyObject,
                p: UUID = UUID(),
                q: Int = 999
            ) -> Foo {
                Foo(
                    a: a,
                    b: b,
                    c: c,
                    d: d,
                    e: e,
                    f: f,
                    g: g,
                    h: h,
                    i: i,
                    j: j,
                    k: k,
                    l: l,
                    m: m,
                    n: n,
                    o: o,
                    p: p,
                    q: q
                )
            }
            #endif
        }
        """

        assertMacroExpansion(source, expandedSource: expandedSource, macros: testMacros)
    }
}
