//
//  Parser.swift
//  miniGoV2
//
//  Created by Serguei Diaz on 23.06.2024.
//

import Foundation
import SwiParse
import SwiLex

enum Terminal: String, SwiLexable {
    
    static var separators: Set<Character> = [" "]
    
    case number = "[0-9]+"
    case string = #"\"([^"\\]|\\.)*\""#
    case identifier = #"(?!var|fmt|Println|Print|Scanln|func|struct|type|if|else|for|int|string|nil|\(|\)|\{|\}|\[|\]|,|;|>|>=|<|<=|=|==|!|!=|&|\||\+|-|\*|/|\.|\:)\b[a-zA-Z_][a-zA-Z0-9_]*\b"#
    
    case structAttribute = #"(?!var|fmt|Println|Scanln|func|struct|type|if|else|for|int|string|nil|\(|\)|\{|\}|\[|\]|,|;|>|>=|<|<=|=|==|!|!=|&|\||\+|-|\*|/|\.|\:)\b[a-zA-Z_][a-zA-Z0-9_]*\.[a-zA-Z_][a-zA-Z0-9_]*\b"#
    case lParenthesis = #"\("#
    case rParenthesis = #"\)"#
    case lCurlyParenthesis = #"\{"#
    case rCurlyParenthesis = #"\}"#
    case lSquareParenthesis = #"\["#
    case rSquareParenthesis = #"\]"#
    case colon = #","#
    case semicolon = #";"#
    case varKeyword = #"var"#
    case funcKeyword = #"func"#
    case structKeyword = #"struct"#
    case typeKeyword = #"type"#
    case ifKeyword = #"if"#
    case elseKeyword = #"else"#
    case forKeyword = #"for"#
    case more = #">"#
    case moreEquals = #">="#
    case less = #"<"#
    case lessEquals = #"<="#
    case equals = #"="#
    case equalsEquals = #"=="#
    case exclamation = #"!"#
    case exclamationEquals = #"!="#
    case andSymbol = #"&"#
    case orSymbol = #"\|"#
    case plus = #"\+"#
    case minus = #"-"#
    case star = #"\*"#
    case slash = #"/"#
    case dot = #"\."#
    case doubleDot = #"\:"#
    case valueType = #"int|string"#
    case nilKeyword = #"nil"#
    case nextLine = #"\n"#
    
    case fmt = "fmt"
    case printLn = "Println"
    case print = "Print"
    case scanln = "Scanln"
    
    case eof
    case none
}

enum NonTerminal: SwiParsable {
    
    case start  // starting token
    
    case program
    case function
    case parametersList
    case type
    case arrayValueType
    case parameter
    case block
    case statementsList
    case statement
    case value
    case valueScalar
    case valueArray
    case numberList
    case stringList
    case oneTypeValueList
    case valueList
    case assignationStatement
    case declarationStatement
    case functionCallStatement
    
    case arithmeticOperator1
    case arithmeticOperator2
    case arithmeticOperationTerm
    case arithmeticOperationFactor
    case booleanOperator
    case booleanOperation
    case booleanOperationFactor
    case booleanOperationTerm
    case arithmeticOperation
    case forStatement
    case ifStatement
    case printStatement
    case scanStatement
    
    case identifierMinusMinus
    
    case arrayPositionValue
    
    case valueScalarNumber
    
    case pointerValue
    
    case structDefinition
    case structDefinitionBlock
    
    case defList
    
    case declarationStatementList
    case structInit
    
    case valueListSpecific
    case ifElseStatement
    
    case forCondition
    
}


let parser = try? SwiParse<Terminal, NonTerminal>(rules: [
    
    .start => [Word(.program)],
    
    .program => [Word(.defList)] >>>> programFunc,
    
    .defList => [Word(.function), Word(.defList)] >>>> defListFunc1,
    .defList => [Word(.structDefinition), Word(.defList)] >>>> defListFunc2,
    .defList => [Word(.function)] >>>> defListFunc3,
    .defList => [Word(.structDefinition)] >>>> defListFunc4,
    
    .function => [Word(.funcKeyword), Word(.identifier), Word(.lParenthesis), Word(.parametersList), Word(.rParenthesis), Word(.block)] >>>> functionFunc1,
    .function => [Word(.funcKeyword), Word(.identifier), Word(.lParenthesis), Word(.rParenthesis), Word(.block)] >>>> functionFunc2,
    
    .structDefinition => [Word(.typeKeyword), Word(.identifier), Word(.structKeyword), Word(.structDefinitionBlock)] >>>> structDefinitionFunc,
    
    .structInit => [Word(.identifier), Word(.lCurlyParenthesis), Word(.valueListSpecific), Word(.rCurlyParenthesis)] >>>> structInitFunc1,
    .structInit => [Word(.andSymbol), Word(.identifier), Word(.lCurlyParenthesis), Word(.valueListSpecific), Word(.rCurlyParenthesis)] >>>> structInitFunc2,
    .structInit => [Word(.identifier), Word(.lCurlyParenthesis), Word(.rCurlyParenthesis)] >>>> structInitFunc3,
    .structInit => [Word(.andSymbol), Word(.identifier), Word(.lCurlyParenthesis), Word(.rCurlyParenthesis)] >>>> structInitFunc4,
    
    .parametersList => [Word(.parameter)] >>>> parametersListFunc1,
    .parametersList => [Word(.parameter), Word(.colon), Word(.parametersList)] >>>> parametersListFunc2,
    
    .type => [Word(.arrayValueType)] >>>> typeFunc1,
    .type => [Word(.valueType)] >>>> typeFunc2,
    .type => [Word(.identifier)] >>>> typeFunc2,
    .type => [Word(.star), Word(.identifier)] >>>> typeFunc3,
    .type => [Word(.star), Word(.valueType)] >>>> typeFunc3,
    
    .arrayValueType => [Word(.lSquareParenthesis), Word(.rSquareParenthesis), Word(.valueType)] >>>> arrayValueTypeFunction,
    
    .parameter => [Word(.identifier), Word(.type)] >>>> parameterFunc,
    
    .block => [Word(.lCurlyParenthesis), Word(.statementsList), Word(.rCurlyParenthesis)] >>>> blockFunc,
    
    .structDefinitionBlock => [Word(.lCurlyParenthesis), Word(.declarationStatementList), Word(.rCurlyParenthesis)] >>>> structDefinitionBlockFunc,
    
    .declarationStatementList => [Word(.identifier), Word(.type), Word(.semicolon)] >>>> declarationStatementListFunc1,
    .declarationStatementList => [Word(.identifier), Word(.type), Word(.semicolon), Word(.declarationStatementList)] >>>> declarationStatementListFunc2,
    
    .statementsList => [Word(.statement), Word(.semicolon)] >>>> statementsList1,
    .statementsList => [Word(.statement), Word(.semicolon), Word(.statementsList)] >>>> statementsList2,
    
    .statement => [Word(.assignationStatement)] >>>> statementFunc1,
    .statement => [Word(.declarationStatement)] >>>> statementFunc2,
    .statement => [Word(.functionCallStatement)] >>>> statementFunc3,
    .statement => [Word(.forStatement)] >>>> statementFunc4,
    .statement => [Word(.ifStatement)] >>>> statementFunc5,
    .statement => [Word(.ifElseStatement)] >>>> statementFunc5,
    .statement => [Word(.printStatement)] >>>> statementFunc6,
    .statement => [Word(.scanStatement)] >>>> statementFunc7,
    
    .printStatement => [Word(.fmt), Word(.dot), Word(.printLn), Word(.lParenthesis), Word(.valueList), Word(.rParenthesis)] >>>> printStatementFunc1,
    .printStatement => [Word(.fmt), Word(.dot), Word(.print), Word(.lParenthesis), Word(.valueList), Word(.rParenthesis)] >>>> printStatementFunc2,
    
    .scanStatement => [Word(.fmt), Word(.dot), Word(.scanln), Word(.lParenthesis), Word(.pointerValue), Word(.rParenthesis)] >>>> scanStatementFunc,
    
    .value => [Word(.valueScalar)] >>>> valueFunction,
    .value => [Word(.valueArray)] >>>> valueFunction2,
    
    .pointerValue => [Word(.andSymbol), Word(.identifier)] >>>> pointerValueFunction1,
    .pointerValue => [Word(.andSymbol), Word(.arrayPositionValue)] >>>> pointerValueFunction2,
    
    .arrayPositionValue => [Word(.identifier), Word(.lSquareParenthesis), Word(.number), Word(.rSquareParenthesis)] >>>> arrayPositionValueFunc,
    .arrayPositionValue => [Word(.identifier), Word(.lSquareParenthesis), Word(.identifier), Word(.rSquareParenthesis)] >>>> arrayPositionValueFunc,
    
    .booleanOperator => [Word(.more)] >>>> booleanOperatorFunc,
    .booleanOperator => [Word(.less)] >>>> booleanOperatorFunc,
    .booleanOperator => [Word(.moreEquals)] >>>> booleanOperatorFunc,
    .booleanOperator => [Word(.lessEquals)] >>>> booleanOperatorFunc,
    .booleanOperator => [Word(.equalsEquals)] >>>> booleanOperatorFunc,
    .booleanOperator => [Word(.exclamationEquals)] >>>> booleanOperatorFunc,
    
    .valueScalar => [Word(.number)] >>>> valueScalarFunc,
    .valueScalar => [Word(.nilKeyword)] >>>> valueScalarFunc,
    .valueScalar => [Word(.string)] >>>> valueScalarFunc,
    
    .valueArray => [Word(.lSquareParenthesis), Word(.oneTypeValueList), Word(.rSquareParenthesis)] >>>> valueArrayFunction,
    
    .numberList => [Word(.number), Word(.colon), Word(.numberList)] >>>> numberListFunction2,
    .numberList => [Word(.number)] >>>> numberListFunction1,
    
    .stringList => [Word(.string), Word(.colon), Word(.numberList)] >>>> numberListFunction2,
    .stringList => [Word(.string)] >>>> numberListFunction1,
    
    .oneTypeValueList => [Word(.numberList)] >>>> oneTypeValueListFunction,
    .oneTypeValueList => [Word(.stringList)] >>>> oneTypeValueListFunction,
    
    .valueList => [Word(.value), Word(.colon), Word(.valueList)] >>>> valueListFunction1,
    .valueList => [Word(.identifier), Word(.colon), Word(.valueList)] >>>> valueListFunction2,
    .valueList => [Word(.arrayValueType), Word(.colon), Word(.valueList)] >>>> valueListFunction1,
    .valueList => [Word(.value)] >>>> valueListFunction3,
    .valueList => [Word(.identifier)] >>>> valueListFunction4,
    .valueList => [Word(.arrayValueType)] >>>> valueListFunction3,
    
    .valueListSpecific => [Word(.identifier), Word(.doubleDot), Word(.value), Word(.colon), Word(.valueList)] >>>> valueListSpecificFunction1,
    .valueListSpecific => [Word(.identifier), Word(.doubleDot), Word(.identifier), Word(.colon), Word(.valueList)] >>>> valueListSpecificFunction2,
    .valueListSpecific => [Word(.identifier), Word(.doubleDot), Word(.arrayValueType), Word(.colon), Word(.valueList)] >>>> valueListSpecificFunction1,
    .valueListSpecific => [Word(.identifier), Word(.doubleDot), Word(.value)] >>>> valueListSpecificFunction3,
    .valueListSpecific => [Word(.identifier), Word(.doubleDot), Word(.identifier)] >>>> valueListSpecificFunction4,
    .valueListSpecific => [Word(.identifier), Word(.doubleDot), Word(.arrayValueType)] >>>> valueListSpecificFunction3,
    
    .arithmeticOperation => [Word(.arithmeticOperation), Word(.plus), Word(.arithmeticOperationTerm)] >>>> arithmeticOperationFunc1,
    .arithmeticOperation => [Word(.arithmeticOperation), Word(.minus), Word(.arithmeticOperationTerm)] >>>> arithmeticOperationFunc1,
    .arithmeticOperation => [Word(.arithmeticOperationTerm)] >>>> arithmeticOperationFunc2,
    .arithmeticOperationTerm => [Word(.arithmeticOperationTerm), Word(.star), Word(.arithmeticOperationFactor)] >>>> arithmeticOperationFunc1,
    .arithmeticOperationTerm => [Word(.arithmeticOperationTerm), Word(.slash), Word(.arithmeticOperationFactor)] >>>> arithmeticOperationFunc1,
    .arithmeticOperationTerm => [Word(.arithmeticOperationFactor)] >>>> arithmeticOperationFunc2,
    .arithmeticOperationFactor => [Word(.lParenthesis), Word(.arithmeticOperation), Word(.rParenthesis)] >>>> arithmeticOperationFunc3,
    .arithmeticOperationFactor => [Word(.number)] >>>> arithmeticOperationFunc4,
    .arithmeticOperationFactor => [Word(.identifier)] >>>> arithmeticOperationFunc5,
    .arithmeticOperationFactor => [Word(.arrayPositionValue)] >>>> arithmeticOperationFunc7,
    
    .booleanOperation => [Word(.booleanOperation), Word(.booleanOperator), Word(.booleanOperationTerm)] >>>> booleanOperationFunc1,
    .booleanOperation => [Word(.booleanOperationTerm)] >>>> booleanOperationFunc2,
    .booleanOperationTerm => [Word(.identifier)] >>>> booleanOperationTerm1,
    .booleanOperationTerm => [Word(.valueScalar)] >>>> booleanOperationTerm2,
    
    .assignationStatement => [Word(.identifier), Word(.equals), Word(.value)] >>>> assignationStatementFunc1,
    .assignationStatement => [Word(.identifier), Word(.equals), Word(.functionCallStatement)] >>>> assignationStatementFunc2,
    .assignationStatement => [Word(.identifier), Word(.equals), Word(.arithmeticOperation)] >>>> assignationStatementFunc3,
    .assignationStatement => [Word(.identifier), Word(.equals), Word(.arrayPositionValue)] >>>> assignationStatementFunc4,
    .assignationStatement => [Word(.identifier), Word(.equals), Word(.structInit)] >>>> assignationStatementFunc5,
    .assignationStatement => [Word(.identifier), Word(.equals), Word(.structAttribute)] >>>> assignationStatementFunc6,
    .assignationStatement => [Word(.structAttribute), Word(.equals), Word(.identifier)] >>>> assignationStatementFunc7,
    .assignationStatement => [Word(.arrayPositionValue), Word(.equals), Word(.value)] >>>> assignationStatementFunc8,
    .assignationStatement => [Word(.arrayPositionValue), Word(.equals), Word(.functionCallStatement)] >>>> assignationStatementFunc9,
    .assignationStatement => [Word(.arrayPositionValue), Word(.equals), Word(.arithmeticOperation)] >>>> assignationStatementFunc10,
    .assignationStatement => [Word(.arrayPositionValue), Word(.equals), Word(.arrayPositionValue)] >>>> assignationStatementFunc11,
    
    .declarationStatement => [Word(.varKeyword), Word(.identifier), Word(.type)] >>>> declarationStatementFunc2,
    
    .functionCallStatement => [Word(.identifier), Word(.lParenthesis), Word(.valueList), Word(.rParenthesis)] >>>> functionCallStatementFunc,
    
    .forStatement => [Word(.forKeyword), Word(.booleanOperation), Word(.block)] >>>> forStatementFunc,
    
    .ifStatement => [Word(.ifKeyword), Word(.booleanOperation), Word(.block)] >>>> ifStatementFunc1,
    .ifElseStatement => [Word(.ifStatement), Word(.elseKeyword), Word(.block)] >>>> ifStatementFunc2,
    
    
    
],verbose: false)


/*
 program : functionList
 functionList : function | function functionList
 function : FUNC IDENTIFIER L_PARENTESIS parametersList R_PARENTESIS block
 parametersList : parameter | parameter COLON parametersList
 type : ARRAY_VALUE_TYPE | VALUE_TYPE
 arrayValueType : L_SQUARE_PARENTESIS R_SQUARE_PARENTESIS VALUE_TYPE
 parameter : IDENTIFIER type
 block : L_CUR_PARENTESIS statementsList R_CUR_PARENTESIS
 statementsList : statement | statement statementsList
 statement : assignationStatement | declarationStatement | functionCallStatement //| forStatement | ifStatement | functionCallStatement
 value : valueScalar | valueArray
 valueScalar : NUMBER | STRING
 valueArray : L_SQUARE_PARENTESIS oneTypeValueList R_SQUARE_PARENTESIS
 numberList : NUMBER COLON numberList | NUMBER
 stringList : STRING COLON numberList | STRING
 oneTypeValueList : numberList | stringList
 valueList : value COLON valueList | value
 assignationStatement : IDENTIFIER EQUALS value
 declarationStatement : VAR assignationStatement | VAR IDENTIFIER type
 functionCallStatement : IDENTIFIER L_PARENTESIS valueList R_PARENTESIS
 */




