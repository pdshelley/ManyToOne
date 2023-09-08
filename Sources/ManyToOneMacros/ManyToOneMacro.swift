import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


func makeSwitchCaseSyntaxFrom(name: StringLiteralExprSyntax, rawValue: String) -> SwitchCaseSyntax {
    guard let stringValue = name.representedLiteralValue else { fatalError() }
    return makeSwitchCaseSyntax(name: stringValue, rawValue: rawValue)
}

func makeSwitchCaseSyntax(name: String, rawValue: String) -> SwitchCaseSyntax {
    return SwitchCaseSyntax(
        """
        case "\(raw: name)": self = .\(raw: rawValue)
        """
    )
}

/// Implementation of the `ManyToOneMacro` macro.
public struct ManyToOneMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            // TODO: Emit an error here
            return []
        }
        
        let members = enumDecl.memberBlock.members
        let caseDecls = members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let enumeration = caseDecls.flatMap { $0.elements }
        
        let initializer = try InitializerDeclSyntax("init?(rawValue: String)") {
            try SwitchExprSyntax("switch rawValue") {
                
                // For all of the Cases in the Enum
                for enumCase in enumeration {
                    if let initializerClause = enumCase.rawValue {
                        let expression = initializerClause.value
                        
                        if let stringLiteralExpression = expression.as(StringLiteralExprSyntax.self) {
                            // Triggers when the enum case has a single raw value.
                            makeSwitchCaseSyntaxFrom(name: stringLiteralExpression, rawValue: enumCase.name.text)
                        }
                        
                        
                        if let sequenceExprSyntax = expression.as(SequenceExprSyntax.self) {
                            if let elements = sequenceExprSyntax.elements.as(ExprListSyntax.self) {
                                for element in elements {
                                    if let stringLiteralExpression = element.as(StringLiteralExprSyntax.self) {
                                        // Triggers when the enum has multiple raw values.
                                        makeSwitchCaseSyntaxFrom(name: stringLiteralExpression, rawValue: enumCase.name.text)
                                    }
                                }
                            }
                        }
                    } else {
                        // Triggers when the enum case does not have a raw value.
                        makeSwitchCaseSyntax(name: enumCase.name.text, rawValue: enumCase.name.text)
                    }
                }
                
                SwitchCaseSyntax(
                    """
                    default: fatalError("No Coding Key for: ")
                    """
                )
            }
        }
        
        return [DeclSyntax(initializer)]
    }
}


@main
struct ManyToOnePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ManyToOneMacro.self
    ]
}




// case paris = "Paris"
//                    EnumCaseElementSyntax
//                    ├─name: identifier("paris")
//                    ╰─rawValue: InitializerClauseSyntax
//                      ├─equal: equal
//                      ╰─value: StringLiteralExprSyntax
//                        ├─openingQuote: stringQuote
//                        ├─segments: StringLiteralSegmentListSyntax
//                        │ ╰─[0]: StringSegmentSyntax
//                        │   ╰─content: stringSegment("Paris")
//                        ╰─closingQuote: stringQuote

// case paris
//                    EnumCaseElementSyntax
//                    ╰─name: identifier("paris")

// case paris = "Paris" || "France"
//                    EnumCaseElementSyntax
//                    ├─name: identifier("paris")
//                    ╰─rawValue: InitializerClauseSyntax
//                      ├─equal: equal
//                      ╰─value: SequenceExprSyntax
//                        ╰─elements: ExprListSyntax
//                          ├─[0]: StringLiteralExprSyntax
//                          │ ├─openingQuote: stringQuote
//                          │ ├─segments: StringLiteralSegmentListSyntax
//                          │ │ ╰─[0]: StringSegmentSyntax
//                          │ │   ╰─content: stringSegment("Paris")
//                          │ ╰─closingQuote: stringQuote
//                          ├─[1]: BinaryOperatorExprSyntax
//                          │ ╰─operator: binaryOperator("||")
//                          ╰─[2]: StringLiteralExprSyntax
//                            ├─openingQuote: stringQuote
//                            ├─segments: StringLiteralSegmentListSyntax
//                            │ ╰─[0]: StringSegmentSyntax
//                            │   ╰─content: stringSegment("France")
//                            ╰─closingQuote: stringQuote



// case "Paris": self = .paris

// if let stringSegment {}
// else use element.name

// case "\(stringSegment)": self = .\(element.name)
