import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
//#if canImport(MyMacroMacros)
import ManyToOneMacros

let testMacros: [String: Macro.Type] = [
//    "stringify": StringifyMacro.self,
    
    "ManyToOne" : ManyToOneMacro.self,
]
//#endif

final class ManyToOneTests: XCTestCase {
    
    func testStringNoValue() {
        assertMacroExpansion(
            """
            @ManyToOne
            enum location: String {
                case paris
                case newYork
                case chicago
            }
            """, expandedSource: """
            enum location: String {
                case paris
                case newYork
                case chicago

                init?(rawValue: String) {
                    switch rawValue {
                    case "paris":
                        self = .paris
                    case "newYork":
                        self = .newYork
                    case "chicago":
                        self = .chicago
                    default:
                        fatalError("No Coding Key for: ")
                    }
                }
            }
            """,
            macros: testMacros)
    }
    
    
    func testStringWithValue() {
        assertMacroExpansion(
            """
            @ManyToOne
            enum location: String {
                case paris = "Paris"
                case newYork = "New York"
                case chicago
            }
            """, expandedSource: """
            enum location: String {
                case paris = "Paris"
                case newYork = "New York"
                case chicago

                init?(rawValue: String) {
                    switch rawValue {
                    case "Paris":
                        self = .paris
                    case "New York":
                        self = .newYork
                    case "chicago":
                        self = .chicago
                    default:
                        fatalError("No Coding Key for: ")
                    }
                }
            }
            """,
            macros: testMacros)
    }
    
    func testSingleORStringValue() {
        assertMacroExpansion(
            """
            @ManyToOne
            enum location: String {
                case paris = "Paris"
                case newYork = "New York" || "NY"
                case chicago = "Chicago"
            }
            """, expandedSource: """
            enum location: String {
                case paris = "Paris"
                case newYork = "New York"
                case chicago = "Chicago"

                init?(rawValue: String) {
                    switch rawValue {
                    case "Paris":
                        self = .paris
                    case "New York":
                        self = .newYork
                    case "NY":
                        self = .newYork
                    case "Chicago":
                        self = .chicago
                    default:
                        fatalError("No Coding Key for: ")
                    }
                }
            }
            """,
            macros: testMacros)
    }
    
    func testDoubleORStringValues() {
        assertMacroExpansion(
            """
            @ManyToOne
            enum location: String {
                case paris = "Paris"
                case newYork = "New York" || "NY" || "ny"
                case chicago = "Chicago"
            }
            """, expandedSource: """
            enum location: String {
                case paris = "Paris"
                case newYork = "New York"
                case chicago = "Chicago"

                init?(rawValue: String) {
                    switch rawValue {
                    case "Paris":
                        self = .paris
                    case "New York":
                        self = .newYork
                    case "NY":
                        self = .newYork
                    case "ny":
                        self = .newYork
                    case "Chicago":
                        self = .chicago
                    default:
                        fatalError("No Coding Key for: ")
                    }
                }
            }
            """,
            macros: testMacros)
    }
}
