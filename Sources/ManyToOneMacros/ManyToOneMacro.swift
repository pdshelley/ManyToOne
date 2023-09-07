import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


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
        let elements = caseDecls.flatMap { $0.elements }
        
        let initializer = try InitializerDeclSyntax("init?(rawValue: String)") {
            try SwitchExprSyntax("switch rawValue") {
                for element in elements {
                    if let initializerClause = element.rawValue {
                        let expression = initializerClause.value
                        if expression.is(StringLiteralExprSyntax.self) {
                            if let stringLiteralExpression = expression.as(StringLiteralExprSyntax.self) {
                                if let stringValue = stringLiteralExpression.representedLiteralValue {
                                    SwitchCaseSyntax(
                                        """
                                        case "\(raw: stringValue)": self = .\(element.name)
                                        """
                                    )
                                }
//                                let stringValue = stringLiteralExpression.segments.first
//                                strin
                            }
                            
//                            print("StringLiteralExprSyntax")
                        }
//                        for value in element.rawValue {
//                            value.
//                        }
                    } else {
                        SwitchCaseSyntax(
                            """
                            case "\(element.name)": self = .\(element.name)
                            """
                        )
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
