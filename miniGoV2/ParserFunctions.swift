//
//  ParserFunctions.swift
//  miniGoV2
//
//  Created by Serguei Diaz on 23.06.2024.
//

import Foundation

func test() -> Substring {
    print("Test function")
    return ""
}


func booleanOperatorFunc(a: Substring) -> booleanOperator {
    switch a {
    case "<":
        return .less
    case ">":
        return .more
    case "==":
        return .equalsEquals
    case "<=":
        return .lessEquals
    case ">=":
        return .moreEquals
    case "!=":
        return .notEquals
    default:
        return .unknown
    }
}

func valueScalarFunc(a: Substring) -> valueScalar {
    if let number: Int = Int(a) {
        return .number(value: number)
    }
    else if String(a) == "nil" {
        return .null
    }
    
    return .string(value: String(a))
}

func arrayPositionValueFunc(a: Substring, b: Substring, c: Substring, d: Substring) -> LLVMVariable {
    
    return .init(identifier: String(a), isPointer: false, position: String(c), isArray: true)
}

func pointerValueFunction1(a: Substring, b: Substring) -> LLVMVariable {
    
    return .init(identifier: String(b), isPointer: true, position: nil, isArray: nil)
}

func pointerValueFunction2(a: Substring, b: LLVMVariable) -> LLVMVariable {
    
    return .init(identifier: b.identifier, isPointer: true, position: b.position, isArray: b.isArray)
}

func numberListFunction1(a: Substring) -> arrayListValue {
    if let number: Int = Int(a) {
        return .init(intValues: [number], stringValues: [])
    }
    else {
        return .init(intValues: [], stringValues: [String(a)])
    }
}

func numberListFunction2(a: Substring, b: Substring, c: arrayListValue) -> arrayListValue {
    var array = c
    if let number: Int = Int(a) {
        array.intValues.append(number)
    }
    else {
        array.stringValues.append(String(a))
    }
    
    return array
}

func oneTypeValueListFunction(a: arrayListValue) -> arrayListValue {    
    return a
}

func valueArrayFunction(a: Substring, b: arrayListValue, c: Substring) -> arrayListValue {
    return b
}

func valueFunction(a: valueScalar) -> LLVMvalue {
    switch a {
    case .number(_):
        return .init(array: false, type: .number, valueArray: nil, valueScalar: a)
    case .string(_):
        return .init(array: false, type: .string, valueArray: nil, valueScalar: a)
    case .null:
        return .init(array: false, type: .null, valueArray: nil, valueScalar: a)
    case .identifier(value: _):
        return .init(array: false, type: .identifier, valueArray: nil, valueScalar: a)
    }
}

func valueFunction2(a: arrayListValue) -> LLVMvalue {
    return .init(array: true, type: a.intValues.isEmpty ? .string : .number, valueArray: a, valueScalar: nil)
}

func arrayValueTypeFunction(a: Substring, b: Substring, c: Substring) -> LLVMvalue {
    return .init(array: true, type: .type(value: String(c)), valueArray: nil, valueScalar: nil)
}

func valueListFunction1(a: LLVMvalue, b: Substring, c: LLVMvalueList) -> LLVMvalueList {
    var response = c
    var temp: [LLVMvalue] = [a]
    temp.append(contentsOf: response.values)
    response.values = temp

    return response
}

func valueListFunction2(a: Substring, b: Substring, c: LLVMvalueList) -> LLVMvalueList {
    var response = c
    var temp: [LLVMvalue] = [.init(array: false, type: .identifier, valueArray: nil, valueScalar: .identifier(value: String(a)))]
    temp.append(contentsOf: response.values)
    response.values = temp

    return response
}

func valueListFunction3(a: LLVMvalue) -> LLVMvalueList {
    return .init(values: [a])
}

func valueListFunction4(a: Substring) -> LLVMvalueList {
    return .init(values: [.init(array: false, type: .identifier, valueArray: nil, valueScalar: .identifier(value: String(a)))])
}

func valueListSpecificFunction1(x: Substring, y: Substring, a: LLVMvalue, b: Substring, c: LLVMvalueList) -> LLVMvalueListSpecific {
    var response: LLVMvalueList = .init(values: [a])
    response.values.append(contentsOf: c.values)
    return .init(leftIdentifier: String(x), rightValue: response)
}

func valueListSpecificFunction2(x: Substring, y: Substring, a: Substring, b: Substring, c: LLVMvalueList) -> LLVMvalueListSpecific {
    var response: LLVMvalueList = .init(values: [.init(array: false, type: .identifier, valueArray: nil, valueScalar: .identifier(value: String(a)))])
    response.values.append(contentsOf: c.values)
    return .init(leftIdentifier: String(x), rightValue: response)
}

func valueListSpecificFunction3(x: Substring, y: Substring, a: LLVMvalue) -> LLVMvalueListSpecific {
    return.init(leftIdentifier: String(x), rightValue: .init(values: [a]))
}

func valueListSpecificFunction4(x: Substring, y: Substring, a: Substring) -> LLVMvalueListSpecific {
    return .init(leftIdentifier: String(x), rightValue: .init(values: [.init(array: false, type: .identifier, valueArray: nil, valueScalar: .identifier(value: String(a)))]))
}

func booleanOperationTerm1(a: Substring) -> valueScalar {
    return .identifier(value: String(a))
}

func booleanOperationTerm2(a: valueScalar) -> valueScalar {
    return a
}

func booleanOperationFunc1(a: LLVMbooleanOperation, b: booleanOperator, c: valueScalar) -> LLVMbooleanOperation {
    var response = a
    var rightValue: LLVMvalue
    
    switch c {
    case .number(_):
        rightValue = LLVMvalue(array: false, type: .number, valueArray: nil, valueScalar: c)
    case .string(_):
        rightValue = LLVMvalue(array: false, type: .string, valueArray: nil, valueScalar: c)
    case .identifier(_):
        rightValue = LLVMvalue(array: false, type: .identifier, valueArray: nil, valueScalar: c)
    case .null:
        rightValue = LLVMvalue(array: false, type: .null, valueArray: nil, valueScalar: c)
    }
    
    if response.operation.first?.operator == .unknown {
        var temp = response.operation
        temp[0] = (left: temp[0].right, operator: b, right: rightValue)
        response.operation = temp
    }
    else {
        response.operation.append((left: nil, operator: b, right: rightValue))
    }
    
    return response
}

func booleanOperationFunc2(c: valueScalar) -> LLVMbooleanOperation {
    var rightValue: LLVMvalue
    
    switch c {
    case .number(_):
        rightValue = LLVMvalue(array: false, type: .number, valueArray: nil, valueScalar: c)
    case .string(_):
        rightValue = LLVMvalue(array: false, type: .string, valueArray: nil, valueScalar: c)
    case .identifier(_):
        rightValue = LLVMvalue(array: false, type: .identifier, valueArray: nil, valueScalar: c)
    case .null:
        rightValue = LLVMvalue(array: false, type: .null, valueArray: nil, valueScalar: c)
    }
    
    return .init(operation: [(left: nil, operator: .unknown, right: rightValue)])
}

func typeFunc1(a: LLVMvalue) -> LLVMvalue {
    return a
}

func typeFunc2(a: Substring) -> LLVMvalue {
    if a == "int" {
        return .init(array: false, pointer: false, type: .number, valueArray: nil, valueScalar: nil)
    }
    else if a == "string" {
        return .init(array: false, pointer: false, type: .string, valueArray: nil, valueScalar: nil)
    }
    else {
        return .init(array: false, pointer: false, type: .structType(type: String(a)), valueArray: nil, valueScalar: nil)
    }
}

func typeFunc3(a: Substring, b: Substring) -> LLVMvalue {
    if a == "int" {
        return .init(array: false, pointer: true, type: .number, valueArray: nil, valueScalar: nil)
    }
    else if a == "string" {
        return .init(array: false, pointer: true, type: .string, valueArray: nil, valueScalar: nil)
    }
    else {
        return .init(array: false, pointer: true, type: .structType(type: String(b)), valueArray: nil, valueScalar: nil)
    }
}

func arithmeticOperationFunc1(a: LLVMArithmeticOperation, b: Substring, c: LLVMArithmeticOperation) -> LLVMArithmeticOperation {
    
    var operation: arithmeticOperator
    
    switch b {
    case "+":
        operation = .plus
    case "-":
        operation = .minus
    case "*":
        operation = .star
    case "/":
        operation = .slash
    default:
        operation = .unknown
    }
    
    return .init(number: nil, operation: operation, left: a, right: c)
}

func arithmeticOperationFunc2(a: LLVMArithmeticOperation) -> LLVMArithmeticOperation {
    return a
}

func arithmeticOperationFunc3(a: Substring, b: LLVMArithmeticOperation, c: Substring) -> LLVMArithmeticOperation {
    return b
}

func arithmeticOperationFunc4(a: Substring) -> LLVMArithmeticOperation {
    return .init(
        number: LLVMvalue(
            array: false,
            type: .number, 
            valueArray: nil,
            valueScalar: .number(value: Int(String(a)) ?? 0),
            variable: nil),
        operation: .unknown)
}

func arithmeticOperationFunc5(a: Substring) -> LLVMArithmeticOperation {
    return .init(
        number: .init(
            array: false,
            type: .identifier,
            valueArray: nil,
            valueScalar: nil,
            variable: .init(
                identifier: String(a),
                isPointer: false,
                position: nil,
                isArray: nil
            )
        ),
        operation: .unknown
    )
}

func arithmeticOperationFunc6(a: LLVMVariable) -> LLVMArithmeticOperation {
    return .init(
        number: .init(
            array: false,
            type: .identifier,
            valueArray: nil,
            valueScalar: nil,
            variable: a
        ),
        operation: .unknown
    )
}

func arithmeticOperationFunc7(a: LLVMVariable) -> LLVMArithmeticOperation {
    return .init(
        number: LLVMvalue(
            array: false,
            type: .null,
            valueArray: nil,
            valueScalar: nil,
            variable: a),
        operation: .unknown)
}

func parameterFunc(a: Substring, b: LLVMvalue) -> LLVMParameter {
    return .init(identifier: String(a), type: b)
}

func parametersListFunc1(a: LLVMParameter) -> LLVMParameterList {
    return .init(parameters: [a])
}

func parametersListFunc2(a: LLVMParameter, b: Substring, c: LLVMParameterList) -> LLVMParameterList {
    var response = LLVMParameterList(parameters: [a])
    response.parameters.append(contentsOf: c.parameters)
    
    return response
}

func declarationStatementListFunc1(a: Substring, b: LLVMvalue, c: Substring) -> LLVMDeclarationStatementList {
    return .init(declarations: [(identifier: String(a), type: b)])
}

func declarationStatementListFunc2(a: Substring, b: LLVMvalue, c: Substring, d: LLVMDeclarationStatementList) -> LLVMDeclarationStatementList {
    var response: LLVMDeclarationStatementList = .init(declarations: [(identifier: String(a), type: b)])
    
    response.declarations.append(contentsOf: d.declarations)
    
    return response
}

func structDefinitionBlockFunc(a: Substring, b: LLVMDeclarationStatementList, c: Substring) -> LLVMDeclarationStatementList {
    return b
}

func structDefinitionFunc(a: Substring, b: Substring, c: Substring, d: LLVMDeclarationStatementList) -> LLVMStructDefinition {
    return .init(typeIdentifier: String(b), attributes: d)
}

func structInitFunc1(a: Substring, b: Substring, c: LLVMvalueListSpecific, d: Substring) -> LLVMStructValue {
    return .init(isPointer: false, type: String(a), attributes: c)
}

func structInitFunc2(a: Substring, b: Substring, c: Substring, d: LLVMvalueListSpecific, e: Substring) -> LLVMStructValue {
    return .init(isPointer: true, type: String(b), attributes: d)
}

func structInitFunc3(a: Substring, b: Substring, c: Substring) -> LLVMStructValue {
    return .init(isPointer: false, type: String(a), attributes: nil)
}

func structInitFunc4(a: Substring, b: Substring, c: Substring, d: Substring) -> LLVMStructValue {
    return .init(isPointer: true, type: String(b), attributes: nil)
}

func functionCallStatementFunc(a: Substring, b: Substring, c: LLVMvalueList, d: Substring) -> LLVMFunctionCallStatement {
    return .init(name: String(a), parametersList: c)
}

func assignationStatementFunc1(a: Substring, b: Substring, c: LLVMvalue) -> LLVMAssignationStatement {
    let response: LLVMAssignationStatement = .init(leftIdentifier: String(a), leftSubIdentifier: nil, arrayPosition: nil, rightValue: c, rightFunction: nil, rightArithmeticOperation: nil, rightArrayPosition: nil, rightStruct: nil, rightStructAttribute: nil, rightIdentifier: nil)

    return response
}

func assignationStatementFunc2(a: Substring, b: Substring, c: LLVMFunctionCallStatement) -> LLVMAssignationStatement {
    let response: LLVMAssignationStatement = .init(leftIdentifier: String(a), leftSubIdentifier: nil, arrayPosition: nil, rightValue: nil, rightFunction: c, rightArithmeticOperation: nil, rightArrayPosition: nil, rightStruct: nil, rightStructAttribute: nil, rightIdentifier: nil)

    return response
}

func assignationStatementFunc3(a: Substring, b: Substring, c: LLVMArithmeticOperation) -> LLVMAssignationStatement {
    let response: LLVMAssignationStatement = .init(leftIdentifier: String(a), leftSubIdentifier: nil, arrayPosition: nil, rightValue: nil, rightFunction: nil, rightArithmeticOperation: c, rightArrayPosition: nil, rightStruct: nil, rightStructAttribute: nil, rightIdentifier: nil)

    return response
}

func assignationStatementFunc4(a: Substring, b: Substring, c: LLVMVariable) -> LLVMAssignationStatement {
    let response: LLVMAssignationStatement = .init(leftIdentifier: String(a), leftSubIdentifier: nil, arrayPosition: nil, rightValue: nil, rightFunction: nil, rightArithmeticOperation: nil, rightArrayPosition: c, rightStruct: nil, rightStructAttribute: nil, rightIdentifier: nil)

    return response
}

func assignationStatementFunc5(a: Substring, b: Substring, c: LLVMStructValue) -> LLVMAssignationStatement {
    let response: LLVMAssignationStatement = .init(leftIdentifier: String(a), leftSubIdentifier: nil, arrayPosition: nil, rightValue: nil, rightFunction: nil, rightArithmeticOperation: nil, rightArrayPosition: nil, rightStruct: c, rightStructAttribute: nil, rightIdentifier: nil)

    return response
}

func assignationStatementFunc6(a: Substring, b: Substring, c: Substring) -> LLVMAssignationStatement {
    let temp: [String] = String(c).split(separator: ".").map { item in
        String(item)
    }
    let response: LLVMAssignationStatement = .init(leftIdentifier: String(a), leftSubIdentifier: nil, arrayPosition: nil, rightValue: nil, rightFunction: nil, rightArithmeticOperation: nil, rightArrayPosition: nil, rightStruct: nil, rightStructAttribute: temp[1], rightIdentifier: temp[0])

    return response
}

func assignationStatementFunc7(a: Substring, b: Substring, c: Substring) -> LLVMAssignationStatement {
    let temp: [String] = String(a).split(separator: ".").map { item in
        String(item)
    }
    let response: LLVMAssignationStatement = .init(leftIdentifier: temp[0], leftSubIdentifier: temp[1], arrayPosition: nil, rightValue: nil, rightFunction: nil, rightArithmeticOperation: nil, rightArrayPosition: nil, rightStruct: nil, rightStructAttribute: nil, rightIdentifier: String(c))

    return response
}

func assignationStatementFunc8(a: LLVMVariable, b: Substring, c: LLVMvalue) -> LLVMAssignationStatement {
    let response: LLVMAssignationStatement = .init(leftIdentifier: nil, leftSubIdentifier: nil, arrayPosition: a, rightValue: c, rightFunction: nil, rightArithmeticOperation: nil, rightArrayPosition: nil, rightStruct: nil, rightStructAttribute: nil, rightIdentifier: nil)

    return response
}

func assignationStatementFunc9(a: LLVMVariable, b: Substring, c: LLVMFunctionCallStatement) -> LLVMAssignationStatement {
    let response: LLVMAssignationStatement = .init(leftIdentifier: nil, leftSubIdentifier: nil, arrayPosition: a, rightValue: nil, rightFunction: c, rightArithmeticOperation: nil, rightArrayPosition: nil, rightStruct: nil, rightStructAttribute: nil, rightIdentifier: nil)

    return response
}

func assignationStatementFunc10(a: LLVMVariable, b: Substring, c: LLVMArithmeticOperation) -> LLVMAssignationStatement {
    let response: LLVMAssignationStatement = .init(leftIdentifier: nil, leftSubIdentifier: nil, arrayPosition: a, rightValue: nil, rightFunction: nil, rightArithmeticOperation: c, rightArrayPosition: nil, rightStruct: nil, rightStructAttribute: nil, rightIdentifier: nil)

    return response
}

func assignationStatementFunc11(a: LLVMVariable, b: Substring, c: LLVMVariable) -> LLVMAssignationStatement {
    let response: LLVMAssignationStatement = .init(leftIdentifier: nil, leftSubIdentifier: nil, arrayPosition: a, rightValue: nil, rightFunction: nil, rightArithmeticOperation: nil, rightArrayPosition: c, rightStruct: nil, rightStructAttribute: nil, rightIdentifier: nil)

    return response
}

func declarationStatementFunc1(a: Substring, b: LLVMAssignationStatement) -> LLVMDeclarationStatement {
    let response: LLVMDeclarationStatement = .init(identifier: nil, type: nil, assignation: b)

    return response
}

func declarationStatementFunc2(a: Substring, b: Substring, c: LLVMvalue) -> LLVMDeclarationStatement {
    let response: LLVMDeclarationStatement = .init(identifier: String(b), type: c, assignation: nil)

    return response
}

func printStatementFunc1(a: Substring, b: Substring, c: Substring, d: Substring, e: LLVMvalueList, f: Substring) -> LLVMPrintStatement {
    let response: LLVMPrintStatement = .init(values: e, printNewLine: true)

    return response
}

func printStatementFunc2(a: Substring, b: Substring, c: Substring, d: Substring, e: LLVMvalueList, f: Substring) -> LLVMPrintStatement {
    let response: LLVMPrintStatement = .init(values: e, printNewLine: false)

    return response
}

func scanStatementFunc(a: Substring, b: Substring, c: Substring, d: Substring, e: LLVMVariable, f: Substring) -> LLVMScanStatement {
    let response: LLVMScanStatement = .init(variable: e)

    return response
}

func forStatementFunc(a: Substring, b: LLVMbooleanOperation, c: LLVMStatementList) -> LLVMForStatement {
    return .init(booleanOperation: b, block: c)
}

func ifStatementFunc1(a: Substring, b: LLVMbooleanOperation, c: LLVMStatementList) -> LLVMIfStatement {
    let response: LLVMIfStatement = .init(booleanOperation: b, block: c)

    return response
}

func ifStatementFunc2(a: LLVMIfStatement, b: Substring, c: LLVMStatementList) -> LLVMIfStatement {
    var response = a
    response.elseBlock = c

    return response
}

func statementFunc1(a: LLVMAssignationStatement) -> LLVMStatement {
    return .init(assignationStatement: a)
}

func statementFunc2(a: LLVMDeclarationStatement) -> LLVMStatement {
    return .init(declarationStatement: a)
}

func statementFunc3(a: LLVMFunctionCallStatement) -> LLVMStatement {
    return .init(functionCallStatement: a)
}

func statementFunc4(a: LLVMForStatement) -> LLVMStatement {
    return .init(forStatement: a)
}

func statementFunc5(a: LLVMIfStatement) -> LLVMStatement {
    return .init(ifStatement: a)
}

func statementFunc6(a: LLVMPrintStatement) -> LLVMStatement {
    return .init(printStatement: a)
}

func statementFunc7(a: LLVMScanStatement) -> LLVMStatement {
    return .init(scanStatement: a)
}

func statementsList1(a: LLVMStatement, b: Substring) -> LLVMStatementList {
    var response = LLVMStatementList(list: [])
    response.list.append(a)
    
    return response
}

func statementsList2(a: LLVMStatement, b: Substring, c: LLVMStatementList) -> LLVMStatementList {
    var response = LLVMStatementList(list: [])
    response.list.append(a)
    response.list.append(contentsOf: c.list)

    return response
}

func blockFunc(a: Substring, b: LLVMStatementList, c: Substring) -> LLVMStatementList {
    return b
}

func functionFunc1(a: Substring, b: Substring, c: Substring, d: LLVMParameterList, e: Substring, f: LLVMStatementList) -> LLVMFunction {
    return .init(name: String(b), parameters: d, block: f)
}

func functionFunc2(a: Substring, b: Substring, c: Substring, d: Substring, e: LLVMStatementList) -> LLVMFunction {
    return .init(name: String(b), parameters: nil, block: e)
}

func defListFunc1(a: LLVMFunction, b: LLVMDefList) -> LLVMDefList {
    var response = b
    response.functionList.append(a)
    
    return response
}

func defListFunc2(a: LLVMStructDefinition, b: LLVMDefList) -> LLVMDefList {
    var response = b
    response.structList.append(a)
    
    return response
}

func defListFunc3(a: LLVMFunction) -> LLVMDefList {
    return .init(functionList: [a], structList: [])
}

func defListFunc4(a: LLVMStructDefinition) -> LLVMDefList {
    return .init(functionList: [], structList: [a])
}

func programFunc(a: LLVMDefList) -> LLVMProgram {
    return .init(defList: a)
}
