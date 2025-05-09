import Stubbable
import Foundation

@Stubbable
class Bar {}

@Stubbable(ignore: ["g"])
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
    let i: Error
    let j: Array<Int>
    let k: Set<Int>
    let l: [String: Bool]
    let m: Any
    let n: AnyObject
}
