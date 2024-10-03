//
//  LLVMTree.swift
//  miniGoV2
//
//  Created by Serguei Diaz on 18.08.2024.
//

import Foundation

struct LLVMStrings {
    var size: Int
    var value: String
    var id: Int
}

struct LLVMArray {
    var size: Int
    var values: [Int] = []
    var id: Int
}

struct LLVMVariable {
    let identifier: String
    let isPointer: Bool
    let position: String?
    let isArray: Bool?
}

struct arrayListValue {
    var intValues: [Int]
    var stringValues: [String]
}

struct LLVMvalue {
    let array: Bool
    var pointer: Bool = false
    let type: LLVMType
    let valueArray: arrayListValue?
    let valueScalar: valueScalar?
    var variable: LLVMVariable? = nil
}

struct LLVMvalueList {
    var values: [LLVMvalue]
}

struct LLVMvalueListSpecific {
    let leftIdentifier: String
    let rightValue: LLVMvalueList
}

struct LLVMbooleanOperation {
    var operation: [(left: LLVMvalue?, operator: booleanOperator, right: LLVMvalue)]
    
    func toLLVMCode() -> (code: LLVMCode, varName: String) {
        var code = LLVMCode(functions: ["This" : ["This" : []]], structs: [:])
        var varName = ""
        
        if let leftVal = operation.first?.left, let rightVal = operation.first?.right, let op = operation.first?.operator {
            let numId = GlobalIdGenerator.shared.getIntValueId()
            let numId2 = GlobalIdGenerator.shared.getIntValueId()
            let numId3 = GlobalIdGenerator.shared.getIntValueId()
            
            var left = ""
            
            var valueTypesComp = "i32"
            var leftComparator = ""
            var rightComparator = ""
            
            varName = "temp\(numId)"
            
            switch leftVal.valueScalar {
            case .number(_):
                fatalError("ERROR: Not implemented yet")
            case .string(_):
                fatalError("ERROR: Not implemented yet")
            case .identifier(let value):
                
                left = value
                leftComparator = "%temp\(numId2)"
                if GlobalStructManager.shared.isStructObject(identifier: left) {
                    if GlobalStructManager.shared.isObjectPointer(identifier: left) {
                        code.functions["This"]?["This"]?.append("%temp\(numId2) = load %Node*, %Node** %\(left) ")
                    }
                    else {
                        fatalError("ERROR: Not implemented yet")
                    }
                }
                else {
                    code.functions["This"]?["This"]?.append("%temp\(numId2) = load i32, i32* %\(value), align 4")
                    
                }
            case .null:
                fatalError("ERROR: Not implemented yet")
            case .none:
                fatalError("ERROR: Not implemented yet")
            }
            
            switch rightVal.valueScalar {
            case .number(_):
                fatalError("ERROR: Not implemented yet")
            case .string(_):
                fatalError("ERROR: Not implemented yet")
            case .identifier(let value):
                code.functions["This"]?["This"]?.append("%temp\(numId3) = load i32, i32* %\(value), align 4")
                rightComparator = "%temp\(numId3)"
            case .null:
                if GlobalStructManager.shared.isStructObject(identifier: left) {
                    let structType = GlobalStructManager.shared.getObjectType(identifier: left)
                    if GlobalStructManager.shared.isObjectPointer(identifier: left) {
                        valueTypesComp = "%\(structType)*"
                    }
                    else {
                        fatalError("ERROR: Not implemented yet")
                    }
                    
                    rightComparator = "null"
                }
                else {
                    fatalError("ERROR: Not implemented yet")
                }
            case .none:
                fatalError("ERROR: Not implemented yet")
            }
            
            switch op {
            case .more:
                code.functions["This"]?["This"]?.append("%temp\(numId) = icmp sgt \(valueTypesComp) \(leftComparator), \(rightComparator)")
            case .less:
                code.functions["This"]?["This"]?.append("%temp\(numId) = icmp slt \(valueTypesComp) \(leftComparator), \(rightComparator)")
            case .equalsEquals:
                code.functions["This"]?["This"]?.append("%temp\(numId) = icmp eq \(valueTypesComp) \(leftComparator), \(rightComparator)")
            case .moreEquals:
                code.functions["This"]?["This"]?.append("%temp\(numId) = icmp sge \(valueTypesComp) \(leftComparator), \(rightComparator)")
            case .lessEquals:
                code.functions["This"]?["This"]?.append("%temp\(numId) = icmp sle \(valueTypesComp) \(leftComparator), \(rightComparator)")
            case .notEquals:
                code.functions["This"]?["This"]?.append("%temp\(numId) = icmp ne \(valueTypesComp) \(leftComparator), \(rightComparator)")
            case .unknown:
                break
            }
        }
        
        
        return (code, varName)
    }
}

class LLVMArithmeticOperation {
    
    init(number: LLVMvalue?, operation: arithmeticOperator, left: LLVMArithmeticOperation? = nil, right: LLVMArithmeticOperation? = nil) {
        self.number = number
        self.operation = operation
        self.left = left
        self.right = right
    }
    
    let number: LLVMvalue?
    var operation: arithmeticOperator
    var left: LLVMArithmeticOperation?
    var right: LLVMArithmeticOperation?
    
    func toLLVM() -> (code: LLVMCode, varName: String) {
        var code = LLVMCode(functions: ["This" : ["This" : []]], structs: [:])
        var varName = ""
        if let num = number {
            if let value = num.valueScalar {
                switch value {
                case .number(let v):
                    let numId = GlobalIdGenerator.shared.getIntValueId()
                    varName = "temp\(numId)"
                    code.functions["This"]?["This"]?.append("%temp\(numId) = alloca i32, align 4")
                    code.functions["This"]?["This"]?.append("store i32 \(v), i32* %temp\(numId)")
                default:
                    fatalError("ERROR in LLVMArithmeticOperation toLLVM()")
                }
            }
            else if let identifier = num.variable {
                if identifier.isArray ?? false {
                    if let position = identifier.position {
                        let numberId2 = GlobalIdGenerator.shared.getIntValueId()
                        let numberId = GlobalIdGenerator.shared.getIntValueId()
                        let numberId3 = GlobalIdGenerator.shared.getIntValueId()
                        let tempSize = GlobalArrayManager.shared.getArraySize(identifier: identifier.identifier)
                        var arraySize = ""
                        if tempSize < 0 {
                            arraySize = "0"
                        }
                        else {
                            arraySize = "\(tempSize)"
                        }
                        var p = ""
                        
                        if let positionInt = Int(position) {
                            p = "\(positionInt)"
                        }
                        else {
                            let numberId4 = GlobalIdGenerator.shared.getIntValueId()
                            let numberId3 = GlobalIdGenerator.shared.getIntValueId()
                            code.functions["This"]?["This"]?.append("%loadedInt\(numberId4) = alloca i32, align 4")
                            code.functions["This"]?["This"]?.append("%loadedInt\(numberId3) = load i32, i32* %\(position)")
                            code.functions["This"]?["This"]?.append("store i32 %loadedInt\(numberId3), i32* %loadedInt\(numberId4)")
                            
                            p = "%loadedInt\(numberId3)"
                            
                        }
                        
                        code.functions["This"]?["This"]?.append("%\(identifier.identifier)\("ptr")\(numberId2) = getelementptr inbounds [\(arraySize) x i32], [\(arraySize) x i32]* %\(identifier.identifier), i32 0, i32 \(p)")
                        code.functions["This"]?["This"]?.append("%tempNumber\(numberId) = load i32, i32* %\(identifier.identifier)\("ptr")\(numberId2)")
                        
                        code.functions["This"]?["This"]?.append("%temp\(numberId3) = alloca i32, align 4")
                        code.functions["This"]?["This"]?.append("store i32 %tempNumber\(numberId), i32* %temp\(numberId3)")
                        
                        varName = "temp\(numberId3)"
                    }
                    else {
                        fatalError("ERROR: Full array assignation is not implemented yet")
                    }
                }
                else if GlobalStructManager.shared.isStructObject(identifier: identifier.identifier) {
                    varName = identifier.identifier
                }
                else {
                    let identifierName = identifier.identifier
                    varName = identifierName
                }
                GlobalLogManager.shared.addlog("ArithmeticOperation - \(identifier) - \(number)")
            }
            else {
                fatalError("ERROR in LLVMArithmeticOperation toLLVM()")
            }
        }
        else {
            if let leftResult = left?.toLLVM(), let rightResult = right?.toLLVM() {
                code.functions["This"]?["This"]?.append(contentsOf: leftResult.code.functions["This"]?["This"] ?? [])
                code.functions["This"]?["This"]?.append(contentsOf: rightResult.code.functions["This"]?["This"] ?? [])
                let numId = GlobalIdGenerator.shared.getIntValueId()
                let numId2 = GlobalIdGenerator.shared.getIntValueId()
                let numId3 = GlobalIdGenerator.shared.getIntValueId()
                let numId4 = GlobalIdGenerator.shared.getIntValueId()
                varName = "temp\(numId4)"
                code.functions["This"]?["This"]?.append("%temp\(numId2) = load i32, i32* %\(leftResult.varName), align 4")
                code.functions["This"]?["This"]?.append("%temp\(numId3) = load i32, i32* %\(rightResult.varName), align 4")
                switch operation {
                case .plus:
                    code.functions["This"]?["This"]?.append("%temp\(numId) = add i32 %temp\(numId2), %temp\(numId3)")
                case .minus:
                    code.functions["This"]?["This"]?.append("%temp\(numId) = sub i32 %temp\(numId2), %temp\(numId3)")
                case .star:
                    code.functions["This"]?["This"]?.append("%temp\(numId) = mul i32 %temp\(numId2), %temp\(numId3)")
                case .slash:
                    code.functions["This"]?["This"]?.append("%temp\(numId) = sdiv i32 %temp\(numId2), %temp\(numId3)")
                case .unknown:
                    fatalError("ERROR in LLVMArithmeticOperation toLLVM()")
                }
                code.functions["This"]?["This"]?.append("%temp\(numId4) = alloca i32, align 4")
                code.functions["This"]?["This"]?.append("store i32 %temp\(numId), i32* %temp\(numId4)")
            }
            else {
                fatalError("ERROR in LLVMArithmeticOperation toLLVM()")
            }
        }
        return (code: code, varName: varName)
    }
}

struct LLVMParameter {
    let identifier: String
    let type: LLVMvalue
}

struct LLVMParameterList {
    var parameters: [LLVMParameter]
}

struct LLVMDeclarationStatementList {
    var declarations: [(identifier: String, type: LLVMvalue)]
}

struct LLVMStructDefinition {
    let typeIdentifier: String
    let attributes: LLVMDeclarationStatementList
    
    func toLLVMCode() -> LLVMCode {
        var code = LLVMCode(functions: [:], structs: [:])
        var att: [String] = []
        
        GlobalStructManager.shared.addStruct(identifier: typeIdentifier)
        
        attributes.declarations.enumerated().forEach { (i, attribute) in
            GlobalLogManager.shared.addlog("Struct Log Type - \(attribute.type)")
            switch attribute.type.type {
            case .number:
                GlobalStructManager.shared.addStructAttribute(identifier: typeIdentifier, attribute: attribute.identifier, pos: i, type: "i32", pointer: false)
                att.append("i32")
            case .string:
                fatalError("ERROR: Attribute type not implemented yet for a struct")
            case .null:
                fatalError("ERROR: Attribute type not implemented yet for a struct")
            case .identifier:
                fatalError("ERROR: Attribute type not implemented yet for a struct")
            case .type(_):
                fatalError("ERROR: Attribute type not implemented yet for a struct")
            case .structType(let type):
                if attribute.type.pointer {
                    GlobalStructManager.shared.addStructAttribute(identifier: typeIdentifier, attribute: attribute.identifier, pos: i, type: "\(type)", pointer: true)
                    att.append("%\(type)*")
                }
                else {
                    fatalError("ERROR: Attribute type not implemented yet for a struct")
                }
            }
        }
        
        code.globalVariables.append("%\(typeIdentifier) = type { \(att.joined(separator: ", ")) }")
        
        return code
    }
}

struct LLVMStructValue {
    let isPointer: Bool
    let type: String
    let attributes: LLVMvalueListSpecific?
}

struct LLVMFunctionCallStatement {
    let name: String
    let parametersList: LLVMvalueList
    
    func toLLVMCode() -> LLVMCode {
        var code = LLVMCode(functions: ["This" : ["This" : []]], structs: [:])
        var list: [String] = []
        
        parametersList.values.enumerated().forEach { (index, val) in
            
            switch val.valueScalar {
            case .number(let value):
                if val.array {
                    list.append("i32* %\(value)")
                }
                else if GlobalFuncManager.shared.isParameterPointer(funcName: name, pos: index) {
                    list.append("i32* %\(value)")
                }
                else {
                    list.append("i32 \(value)")
                }
            case .string(_):
                fatalError("ERROR: Not implemented yet")
            case .identifier(let value):
                if GlobalStructManager.shared.isStructObject(identifier: value) {
                    if GlobalStructManager.shared.isObjectPointer(identifier: value) {
                        let type = GlobalStructManager.shared.getObjectType(identifier: value)
                        list.append("%\(type)* %\(value)")
                    }
                    else {
                        fatalError("ERROR: Not implemented yet")
                    }
                }
                else {
                    let isArray = GlobalArrayManager.shared.isArray(identifier: value)
                    if isArray {
                        list.append("i32* %\(value)")
                    }
                    else if GlobalFuncManager.shared.isParameterPointer(funcName: name, pos: index) {
                        list.append("i32* %\(value)")
                    }
                    else {
                        let numberId = GlobalIdGenerator.shared.getIntValueId()
                        code.functions["This"]?["This"]?.append("%\(value)\(numberId) = load i32, i32* %\(value), align 4")
                        list.append("i32 %\(value)\(numberId)")
                    }
                }
                
            case .null:
                fatalError("ERROR: Not implemented yet")
            case .none:
                fatalError("ERROR: Not implemented yet")
            }
        }
        
        code.functions["This"]?["This"]?.append("call void @\(name)(\(list.joined(separator: ", ")))")
        
        return code
    }
}

struct LLVMAssignationStatement {
    let leftIdentifier: String?
    let leftSubIdentifier: String?
    let arrayPosition: LLVMVariable?
    
    let rightValue: LLVMvalue?
    let rightFunction: LLVMFunctionCallStatement?
    let rightArithmeticOperation: LLVMArithmeticOperation?
    let rightArrayPosition: LLVMVariable?
    let rightStruct: LLVMStructValue?
    let rightStructAttribute: String?
    let rightIdentifier: String?
    
    func toLLVMCode() -> LLVMCode {
        var code = LLVMCode(functions: ["This" : ["This" : []]], structs: [:])
        if let name = leftIdentifier {
            if let attribute = leftSubIdentifier {
                //TODO
                if let value = rightIdentifier {
                    if GlobalStructManager.shared.isStructObject(identifier: value) {
                        if GlobalStructManager.shared.isObjectPointer(identifier: value) {
                            let numberId = GlobalIdGenerator.shared.getIntValueId()
                            let numberId2 = GlobalIdGenerator.shared.getIntValueId()
                            let numberId3 = GlobalIdGenerator.shared.getIntValueId()
                            let type = GlobalStructManager.shared.getObjectType(identifier: name)
                            let attType = GlobalStructManager.shared.getStructAttributeType(identifier: type, attribute: attribute)
                            let attPos = GlobalStructManager.shared.getStructAttributePos(identifier: type, attribute: attribute)
                            code.functions["This"]?["This"]?.append("%objectPtr\(numberId2) = load %\(type)*, %\(type)** %\(name)")
                            code.functions["This"]?["This"]?.append("%objectVal\(numberId3) = load %\(attType)*, %\(attType)** %\(value)")
                            
                            code.functions["This"]?["This"]?.append("%attributePtr\(numberId) = getelementptr %\(type), %\(type)* %objectPtr\(numberId2), i32 0, i32 \(attPos)")
                            code.functions["This"]?["This"]?.append("store %\(attType)* %objectVal\(numberId3), %\(attType)** %attributePtr\(numberId)")
                            
                        }
                        else {
                            fatalError("ERROR: Assignation error")
                        }
                    }
                    else {
                        fatalError("ERROR: Assignation error")
                    }
                }
                else {
                    fatalError("ERROR: Assignation error")
                }
            }
            else {
                if let value = rightValue {
                    guard let val = value.valueScalar else {
                        fatalError("ERROR: No value finded to assign to \(name) variable")
                    }
                    
                    switch value.type {
                    case .number:
                        
                        switch val {
                        case .number(let v):
                            code.functions["This"]?["This"]?.append("store i32 \(v), i32* %\(name)")
                            GlobalLogManager.shared.addlog("\(name) = \(v)")
                        default:
                            fatalError("ERROR: Unconsistent type on assign value to \(name) variable")
                        }
                        
                    case .string:
                        switch val {
                        case .string(var v):
                            let stringId = GlobalIdGenerator.shared.getStringValueId()
                            v = v.replacingOccurrences(of: "\"", with: "")
                            code.globalVariables.append("@.\(name)\("Id")\(stringId) = private unnamed_addr constant [\(v.count + 1) x i8] c\"\(v)\\00\", align 1")
                            GlobalStringManager.shared.updateString(identifier: name, newVariable: "\(name)\("Id")\(stringId)")
                            GlobalLogManager.shared.addlog("\(name) = \(v)")
                        default:
                            fatalError("ERROR: Unconsistent type on assign value to \(name) variable")
                        }
                    case .null:
                        fatalError("ERROR: Assignation error")
                    case .identifier:
                        fatalError("ERROR: Assignation error")
                    case .type(_):
                        fatalError("ERROR: Assignation error")
                    case .structType(_):
                        fatalError("ERROR: Assignation error")
                    }
                }
                else if let functionCall = rightFunction {
                    if functionCall.name == "make" {
                        let secondParameter = functionCall.parametersList.values[1]
                        
                        if secondParameter.type == .identifier || secondParameter.type == .number {
                            if let value = secondParameter.valueScalar {
                                switch value {
                                case .number(let value):
                                    GlobalArrayManager.shared.changeArraySize(identifier: name, size: value)
                                    code.functions["This"]?["This"]?.append("%\(name) = alloca [\(value) x i32], align 16")
                                case .string(_):
                                    fatalError("ERROR: Assignation error")
                                    
                                case .identifier(let value):
                                    let numberId = GlobalIdGenerator.shared.getIntValueId()
                                    
                                    let numberId2 = GlobalIdGenerator.shared.getIntValueId()
                                    let numberId3 = GlobalIdGenerator.shared.getIntValueId()
                                    let numberId4 = GlobalIdGenerator.shared.getIntValueId()
                                    
                                    GlobalArrayManager.shared.changeArraySize(identifier: name, sizeIdentifier: "\(value)")
                                    code.functions["This"]?["This"]?.append("%\(value)\(numberId) = load i32, i32* %\(value), align 4")
                                    code.functions["This"]?["This"]?.append("%arraySize\(numberId2) = mul i32 %\(value)\(numberId), 4")
                                    code.functions["This"]?["This"]?.append("%arraySize\(numberId3) = sext i32 %arraySize\(numberId2) to i64")
                                    code.functions["This"]?["This"]?.append("%arrRaw\(numberId4) = call i8* @malloc(i64 %arraySize\(numberId3))")
                                    code.functions["This"]?["This"]?.append("%\(name) = bitcast i8* %arrRaw\(numberId4) to i32* ")
                                    
                                case .null:
                                    fatalError("ERROR: Assignation error")
                                    
                                }
                            }
                        }
                        else {
                            switch secondParameter.type {
                                
                            case .number:
                                fatalError("ERROR: Assignation error")
                            case .string:
                                fatalError("ERROR: Assignation error")
                            case .null:
                                fatalError("ERROR: Assignation error")
                            case .identifier:
                                fatalError("ERROR: Assignation error")
                            case .type(value: _):
                                
                                if let value = secondParameter.valueScalar {
                                    switch value {
                                    case .number(let value):
                                        GlobalArrayManager.shared.changeArraySize(identifier: name, size: value)
                                        code.functions["This"]?["This"]?.append("%\(name) = alloca [\(value) x i32], align 16")
                                    case .string(_):
                                        fatalError("ERROR: Assignation error")
                                        
                                    case .identifier(let value):
                                        let numberId = GlobalIdGenerator.shared.getIntValueId()
                                        
                                        let numberId2 = GlobalIdGenerator.shared.getIntValueId()
                                        let numberId3 = GlobalIdGenerator.shared.getIntValueId()
                                        let numberId4 = GlobalIdGenerator.shared.getIntValueId()
                                        
                                        GlobalArrayManager.shared.changeArraySize(identifier: name, sizeIdentifier: "\(value)")
                                        code.functions["This"]?["This"]?.append("%\(value)\(numberId) = load i32, i32* %\(value), align 4")
                                        
                                        code.functions["This"]?["This"]?.append("%arraySize\(numberId2) = mul i32 %\(value)\(numberId), 4")
                                        code.functions["This"]?["This"]?.append("%arraySize\(numberId3) = sext i32 %arraySize\(numberId2) to i64")
                                        code.functions["This"]?["This"]?.append("%arrRaw\(numberId4) = call i8* @malloc(i64 %arraySize\(numberId3))")
                                        code.functions["This"]?["This"]?.append("%\(name) = bitcast i8* %arrRaw\(numberId4) to i32* ")
                                        
                                    case .null:
                                        fatalError("ERROR: Assignation error")
                                        
                                    }
                                }
                                
                            case .structType(type: _):
                                fatalError("ERROR: Assignation error")
                                
                            }
                        }
                    }
                    else if functionCall.name == "len" {
                        let firstParameter = functionCall.parametersList.values[0]
                        
                        if firstParameter.type == .identifier {
                            if let value = firstParameter.valueScalar {
                                switch value {
                                case .identifier(let value):
                                    let size = GlobalArrayManager.shared.getArraySize(identifier: value)
                                    if size < 0 {
                                        let numberId = GlobalIdGenerator.shared.getIntValueId()
                                        let sizeIdentifier = GlobalArrayManager.shared.getArraySizeIdentifier(identifier: value)
                                        code.functions["This"]?["This"]?.append("%\(value)\(numberId) = load i32, i32* %\(sizeIdentifier), align 4")
                                        code.functions["This"]?["This"]?.append("store i32 %\(value)\(numberId), i32* %\(name)")
                                    }
                                    else {
                                        code.functions["This"]?["This"]?.append("store i32 \(size), i32* %\(name)")
                                    }
                                default:
                                    fatalError("ERROR: Assignation error")
                                    
                                }
                            }
                        }
                    }
                    else {
                        fatalError("ERROR: Function assignation error")
                    }
                }
                else if let arithmeticOperation = rightArithmeticOperation {
                    let rightCode = arithmeticOperation.toLLVM()
                    let numberId = GlobalIdGenerator.shared.getIntValueId()
                    
                    if GlobalStructManager.shared.isStructObject(identifier: rightCode.varName) {
                        let type = GlobalStructManager.shared.getObjectType(identifier: rightCode.varName)
                        code.functions["This"]?["This"]?.append("%objectVal\(numberId) = load %\(type)*, %\(type)** %\(rightCode.varName)")
                        
                        code.functions["This"]?["This"]?.append("store %\(type)* %objectVal\(numberId), %\(type)** %\(name)")
                        
                        GlobalLogManager.shared.addlog("\(name) = Struct(\(rightCode.varName))")
                        GlobalLogManager.shared.addlog("special log* - \(arithmeticOperation.number)")
                    }
                    else {
                        code.functions["This"]?["This"]?.append(contentsOf: rightCode.code.functions["This"]?["This"] ?? [])
                        code.functions["This"]?["This"]?.append("%loadedInt\(numberId) = load i32, i32* %\(rightCode.varName)")
                        code.functions["This"]?["This"]?.append("store i32 %loadedInt\(numberId), i32* %\(name)")
                        GlobalLogManager.shared.addlog("\(name) = ArithmeticValue(loadedInt\(numberId))")
                        GlobalLogManager.shared.addlog("special log* - \(arithmeticOperation.number)")
                    }
                }
                else if let array = rightArrayPosition {
                    if let position = array.position {
                        let numberId2 = GlobalIdGenerator.shared.getIntValueId()
                        let numberId = GlobalIdGenerator.shared.getIntValueId()
                        let tempSize = GlobalArrayManager.shared.getArraySize(identifier: array.identifier)
                        var arraySize = ""
                        if tempSize < 0 {
                            arraySize = "0"
                        }
                        else {
                            arraySize = "\(tempSize)"
                        }
                        var p = ""
                        
                        if let positionInt = Int(position) {
                            p = "\(positionInt)"
                        }
                        else {
                            let numberId4 = GlobalIdGenerator.shared.getIntValueId()
                            let numberId3 = GlobalIdGenerator.shared.getIntValueId()
                            code.functions["This"]?["This"]?.append("%loadedInt\(numberId4) = alloca i32, align 4")
                            code.functions["This"]?["This"]?.append("%loadedInt\(numberId3) = load i32, i32* %\(position)")
                            code.functions["This"]?["This"]?.append("store i32 %loadedInt\(numberId3), i32* %loadedInt\(numberId4)")
                            
                            p = "%loadedInt\(numberId3)"
                            
                        }
                        code.functions["This"]?["This"]?.append("%\(array.identifier)\("ptr")\(numberId2) = getelementptr inbounds [\(arraySize) x i32], [\(arraySize) x i32]* %\(array.identifier), i32 0, i32 \(p)")
                        code.functions["This"]?["This"]?.append("%tempNumber\(numberId) = load i32, i32* %\(array.identifier)\("ptr")\(numberId2)")
                        code.functions["This"]?["This"]?.append("store i32 %tempNumber\(numberId), i32* %\(name)")
                        
                        GlobalLogManager.shared.addlog("\(name) = \(array.identifier)[\(array.position)]")
                        
                    }
                    else {
                        fatalError("ERROR: Full array assignation is not implemented yet")
                    }
                }
                else if let structInit = rightStruct {
                    if structInit.isPointer {
                        let numberId = GlobalIdGenerator.shared.getIntValueId()
                        let numberId2 = GlobalIdGenerator.shared.getIntValueId()
                        let numberId3 = GlobalIdGenerator.shared.getIntValueId()
                        let pointerId = GlobalIdGenerator.shared.getIntValueId()
                        
                        let structAttributes = GlobalStructManager.shared.getStructAttributes(identifier: structInit.type)
                        
                        let bytes = structAttributes.reduce(0, { partialResult, a in
                            a.value.1.pointer ? partialResult + 8 : 4
                        })
                        code.functions["This"]?["This"]?.append("%struct\(numberId3) = call i8* @malloc(i\(bytes * 8) \(bytes))")
                        code.functions["This"]?["This"]?.append("%stuctObject\(numberId) = bitcast i8* %struct\(numberId3) to %\(structInit.type)*")
                        
                        structAttributes.forEach { att in
                            if att.value.1.pointer {
                                code.functions["This"]?["This"]?.append("%fieldPtr\(pointerId) = getelementptr %\(structInit.type), %\(structInit.type)* %stuctObject\(numberId), i32 0, i32 \(att.value.0)")
                                code.functions["This"]?["This"]?.append("store %\(att.value.1.type)* null, %\(att.value.1.type)** %fieldPtr\(pointerId)")
                            }
                        }
                        
                        if let attribute = structInit.attributes, let attributeValue = attribute.rightValue.values.first {
                            let attributePos = GlobalStructManager.shared.getStructAttributePos(identifier: structInit.type, attribute: attribute.leftIdentifier)
                            
                            guard let val = attributeValue.valueScalar else {
                                fatalError("ERROR: No value finded to assign to \(name) variable")
                            }
                            switch attributeValue.type {
                            case .number:
                                
                                switch val {
                                case .number(let v):
                                    code.functions["This"]?["This"]?.append("%structAttPtr\(numberId2) = getelementptr %\(structInit.type), %\(structInit.type)* %stuctObject\(numberId), i32 0, i32 \(attributePos)")
                                    code.functions["This"]?["This"]?.append("store i32 \(v), i32* %structAttPtr\(numberId2)")
                                    GlobalLogManager.shared.addlog("\(name) = \(v)")
                                default:
                                    fatalError("ERROR: Unconsistent type on assign value to \(name) variable")
                                }
                                
                            case .string:
                                fatalError("ERROR: String assignation to struct attribute not implemented yet")
                            case .null:
                                fatalError("ERROR: Assignation error")
                            case .identifier:
                                if let ident = attributeValue.variable?.identifier {
                                    if GlobalStructManager.shared.isObjectPointer(identifier: ident) {
                                        fatalError("ERROR: Not Implemented Yet")
                                    }
                                    else {
                                        let numberId3 = GlobalIdGenerator.shared.getIntValueId()
                                        code.functions["This"]?["This"]?.append("%structAttPtr\(numberId2) = getelementptr %\(structInit.type), %\(structInit.type)* %stuctObject\(numberId), i32 0, i32 \(attributePos)")
                                        code.functions["This"]?["This"]?.append("%loadedInt\(numberId3) = load i32, i32* %\(ident)")
                                        code.functions["This"]?["This"]?.append("store i32 %loadedInt\(numberId3), i32* %structAttPtr\(numberId2)")
                                    }
                                }
                                else if let scalar = attributeValue.valueScalar {
                                    switch scalar {
                                    case .number(_):
                                        fatalError("ERROR: Assignation error")
                                    case .string(_):
                                        fatalError("ERROR: Assignation error")
                                    case .identifier(let value):
                                        let numberId3 = GlobalIdGenerator.shared.getIntValueId()
                                        code.functions["This"]?["This"]?.append("%structAttPtr\(numberId2) = getelementptr %\(structInit.type), %\(structInit.type)* %stuctObject\(numberId), i32 0, i32 \(attributePos)")
                                        code.functions["This"]?["This"]?.append("%loadedInt\(numberId3) = load i32, i32* %\(value)")
                                        code.functions["This"]?["This"]?.append("store i32 %loadedInt\(numberId3), i32* %structAttPtr\(numberId2)")
                                    case .null:
                                        fatalError("ERROR: Assignation error")
                                    }
                                }
                                else {
                                    fatalError("ERROR: Assignation error")
                                }
                            case .type(_):
                                fatalError("ERROR: Assignation error")
                            case .structType(_):
                                fatalError("ERROR: Assignation error")
                            }
                        }
                        
                        code.functions["This"]?["This"]?.append("store %\(structInit.type)* %stuctObject\(numberId), %\(structInit.type)** %\(name)")
                    }
                }
                else if let rightObject = rightIdentifier {
                    if let rightAttribute = rightStructAttribute {
                        if GlobalStructManager.shared.isStructObject(identifier: rightObject) {
                            if GlobalStructManager.shared.isObjectPointer(identifier: rightObject) {
                                let numberId = GlobalIdGenerator.shared.getIntValueId()
                                let numberId2 = GlobalIdGenerator.shared.getIntValueId()
                                let numberId3 = GlobalIdGenerator.shared.getIntValueId()
                                let type = GlobalStructManager.shared.getObjectType(identifier: rightObject)
                                let attPos = GlobalStructManager.shared.getStructAttributePos(identifier: type, attribute: rightAttribute)
                                
                                let attType = GlobalStructManager.shared.getStructAttributeType(identifier: type, attribute: rightAttribute)
                                
                                if attType == "i32" {
                                    code.functions["This"]?["This"]?.append("%loadedStruct\(numberId3) = load %\(type)*, %\(type)** %\(rightObject)")
                                    code.functions["This"]?["This"]?.append("%attributePtr\(numberId) = getelementptr %\(type), %\(type)* %loadedStruct\(numberId3), i32 0, i32 \(attPos)")
                                    code.functions["This"]?["This"]?.append("%loadedInt\(numberId2) = load i32, i32* %attributePtr\(numberId)")
                                    code.functions["This"]?["This"]?.append("store i32 %loadedInt\(numberId2), i32* %\(name)")
                                    
                                }
                                else {
                                    code.functions["This"]?["This"]?.append("%loadedStruct\(numberId3) = load %\(type)*, %\(type)** %\(rightObject)")
                                    code.functions["This"]?["This"]?.append("%attributePtr\(numberId) = getelementptr %\(type), %\(type)* %loadedStruct\(numberId3), i32 0, i32 \(attPos)")
                                    code.functions["This"]?["This"]?.append("%valPtr\(numberId2) = load %\(attType)*, %\(attType)** %attributePtr\(numberId)")
                                    code.functions["This"]?["This"]?.append("store %\(attType)* %valPtr\(numberId2), %\(attType)** %\(name)")
                                }
                            }
                            else {
                                fatalError("ERROR: Assignation error")
                            }
                        }
                        else {
                            fatalError("ERROR: Assignation error")
                        }
                    }
                    else {
                        fatalError("ERROR: Assignation error")
                    }
                }
                else {
                    fatalError("ERROR: Assignation error")
                }
            }
            
        }
        
        else if let array = arrayPosition {
            if let position = array.position {
                if let arithmeticOperation = rightArithmeticOperation {
                    if arithmeticOperation.operation == .unknown {
                        if arithmeticOperation.number?.type == .identifier {
                            if !(arithmeticOperation.number?.variable?.isPointer ?? false) && !(arithmeticOperation.number?.variable?.isArray ?? false) {
                                guard let identifier = arithmeticOperation.number?.variable?.identifier else {
                                    fatalError("ERROR: Unconsistent type on assign value to \(array.identifier) variable")
                                }
                                let isString: Bool = GlobalStringManager.shared.checkExistence(identifier: identifier)
                                if isString {
                                    fatalError("ERROR: Unconsistent type on assign value to \(array.identifier) variable")
                                }
                                else {
                                    let numberId = GlobalIdGenerator.shared.getIntValueId()
                                    let numberId2 = GlobalIdGenerator.shared.getIntValueId()
                                    let tempSize = GlobalArrayManager.shared.getArraySize(identifier: array.identifier)
                                    var arraySize = ""
                                    if tempSize < 0 {
                                        arraySize = "0"
                                    }
                                    else {
                                        arraySize = "\(tempSize)"
                                    }
                                    
                                    var p = ""
                                    
                                    if let positionInt = Int(position) {
                                        p = "\(positionInt)"
                                    }
                                    else {
                                        let numberId4 = GlobalIdGenerator.shared.getIntValueId()
                                        let numberId3 = GlobalIdGenerator.shared.getIntValueId()
                                        code.functions["This"]?["This"]?.append("%loadedInt\(numberId4) = alloca i32, align 4")
                                        code.functions["This"]?["This"]?.append("%loadedInt\(numberId3) = load i32, i32* %\(position)")
                                        code.functions["This"]?["This"]?.append("store i32 %loadedInt\(numberId3), i32* %loadedInt\(numberId4)")
                                        
                                        p = "%loadedInt\(numberId3)"
                                    }
                                    
                                    
                                    code.functions["This"]?["This"]?.append("%\(identifier)\(numberId) = load i32, i32* %\(identifier), align 4")
                                    
                                    code.functions["This"]?["This"]?.append("%\(array.identifier)\("ptr")\(numberId2) = getelementptr inbounds [\(arraySize) x i32], [\(arraySize) x i32]* %\(array.identifier), i32 0, i32 \(p)")
                                    code.functions["This"]?["This"]?.append("store i32 %\(identifier)\(numberId), i32* %\(array.identifier)\("ptr")\(numberId2)")
                                }
                            }
                            else {
                                fatalError("ERROR: Assignation error")
                            }
                        }
                        else if arithmeticOperation.number?.type == .number {
                            if !(arithmeticOperation.number?.variable?.isPointer ?? false) && !(arithmeticOperation.number?.variable?.isArray ?? false) {
                                switch arithmeticOperation.number?.valueScalar {
                                case .number(let v):
                                    let numberId2 = GlobalIdGenerator.shared.getIntValueId()
                                    let tempSize = GlobalArrayManager.shared.getArraySize(identifier: array.identifier)
                                    var arraySize = ""
                                    if tempSize < 0 {
                                        arraySize = "0"
                                    }
                                    else {
                                        arraySize = "\(tempSize)"
                                    }
                                    
                                    var p = ""
                                    
                                    if let positionInt = Int(position) {
                                        p = "\(positionInt)"
                                    }
                                    else {
                                        let numberId4 = GlobalIdGenerator.shared.getIntValueId()
                                        let numberId3 = GlobalIdGenerator.shared.getIntValueId()
                                        code.functions["This"]?["This"]?.append("%loadedInt\(numberId4) = alloca i32, align 4")
                                        code.functions["This"]?["This"]?.append("%loadedInt\(numberId3) = load i32, i32* %\(position)")
                                        code.functions["This"]?["This"]?.append("store i32 %loadedInt\(numberId3), i32* %loadedInt\(numberId4)")
                                        
                                        p = "%loadedInt\(numberId3)"
                                    }
                                    
                                    
                                    code.functions["This"]?["This"]?.append("%\(array.identifier)\("ptr")\(numberId2) = getelementptr inbounds [\(arraySize) x i32], [\(arraySize) x i32]* %\(array.identifier), i32 0, i32 \(p)")
                                    code.functions["This"]?["This"]?.append("store i32 \(v), i32* %\(array.identifier)\("ptr")\(numberId2)")
                                default:
                                    fatalError("ERROR: Assignation error")
                                }
                            }
                            else {
                                fatalError("ERROR: Assignation error")
                            }
                        }
                        else {
                            fatalError("ERROR: Assignation error")
                        }
                    }
                    else {
                        fatalError("ERROR: Assignation error")
                    }
                }
                else if let rValue = rightValue?.valueScalar {
                    switch rValue {
                    case .number(let v):
                        let numberId2 = GlobalIdGenerator.shared.getIntValueId()
                        let tempSize = GlobalArrayManager.shared.getArraySize(identifier: array.identifier)
                        var arraySize = ""
                        if tempSize < 0 {
                            arraySize = "0"
                        }
                        else {
                            arraySize = "\(tempSize)"
                        }
                        var p = ""
                        
                        if let positionInt = Int(position) {
                            p = "\(positionInt)"
                        }
                        else {
                            let numberId4 = GlobalIdGenerator.shared.getIntValueId()
                            let numberId3 = GlobalIdGenerator.shared.getIntValueId()
                            code.functions["This"]?["This"]?.append("%loadedInt\(numberId4) = alloca i32, align 4")
                            code.functions["This"]?["This"]?.append("%loadedInt\(numberId3) = load i32, i32* %\(position)")
                            code.functions["This"]?["This"]?.append("store i32 %loadedInt\(numberId3), i32* %loadedInt\(numberId4)")
                            
                            p = "%loadedInt\(numberId3)"
                        }
                        
                        
                        code.functions["This"]?["This"]?.append("%\(array.identifier)\("ptr")\(numberId2) = getelementptr inbounds [\(arraySize) x i32], [\(arraySize) x i32]* %\(array.identifier), i32 0, i32 \(p)")
                        code.functions["This"]?["This"]?.append("store i32 \(v), i32* %\(array.identifier)\("ptr")\(numberId2)")
                    case .string(_):
                        fatalError("ERROR: Function assignation call error")
                    case .identifier(_):
                        fatalError("ERROR: Function assignation call error")
                    case .null:
                        fatalError("ERROR: Function assignation call error")
                    }
                }
                else if let functionCall = rightFunction {
                    if functionCall.name == "make" {
                        let secondParameter = functionCall.parametersList.values[1]
                        
                        if secondParameter.type == .identifier || secondParameter.type == .number {
                            if let value = secondParameter.valueScalar {
                                switch value {
                                case .number(let value):
                                    let numberId2 = GlobalIdGenerator.shared.getIntValueId()
                                    GlobalArrayManager.shared.changeArraySize(identifier: array.identifier, size: value)
                                    code.functions["This"]?["This"]?.append("%\(array.identifier)\("ptr")\(numberId2) = alloca [\(value) x i32], align 16")
                                case .string(_):
                                    fatalError("ERROR: Assignation error")
                                case .identifier(let value):
                                    let numberId = GlobalIdGenerator.shared.getIntValueId()
                                    let numberId2 = GlobalIdGenerator.shared.getIntValueId()
                                    GlobalArrayManager.shared.changeArraySize(identifier: array.identifier, size: 0)
                                    code.functions["This"]?["This"]?.append("%\(value)\(numberId) = load i32, i32* %\(value), align 4")
                                    code.functions["This"]?["This"]?.append("%\(array.identifier)\("ptr")\(numberId2) = alloca [\(value)\(numberId) x i32], align 16")
                                case .null:
                                    fatalError("ERROR: Assignation error")
                                }
                            }
                        }
                        else {
                            fatalError("ERROR: Assignation error")
                        }
                    }
                    else {
                        fatalError("ERROR: Function \(functionCall.name) call error")
                    }
                }
                else {
                    fatalError("ERROR: Function assignation call error")
                }
            }
            else {
                fatalError("ERROR: Assignation error")
            }
        }
        print("LLVM Global:--------------------------------------")
        code.globalVariables.forEach { item in
            print(item)
        }
        print("LLVM:--------------------------------------")
        code.functions["This"]?["This"]?.forEach { item in
            print(item)
        }
        return code
    }
}

struct LLVMDeclarationStatement {
    let identifier: String?
    let type: LLVMvalue?
    
    let assignation: LLVMAssignationStatement?
    
    func toLLVMCode() -> LLVMCode {
        var code = LLVMCode(functions: ["This" : ["This" : []]], structs: [:])
        guard let t = type else {
            fatalError("ERROR: Assignation on declaration are not implemented yet")
        }
        switch t.type {
        case .number:
            if let name = identifier {
                code.functions["This"]?["This"]?.append("%\(name) = alloca i32, align 4")
                code.functions["This"]?["This"]?.append("store i32 0, i32* %\(name)")
            }
            else {
                fatalError("ERROR: Assignation on declaration are not implemented yet")
            }
        case .string:
            let stringId = GlobalIdGenerator.shared.getStringValueId()
            if let name = identifier {
                if t.array {
                    fatalError("ERROR: Array of strings are not implemented yet")
                }
                else {
                    code.globalVariables.append("@.\(name)\("Id")\(stringId) = private unnamed_addr constant [1 x i8] c\"\\00\", align 1")
                    GlobalStringManager.shared.defineString(identifier: name, currentVariable: "\(name)\("Id")\(stringId)")
                }
            }
            else {
                fatalError("ERROR: Assignation on declaration are not implemented yet")
            }
        case .null:
            break
        case .identifier:
            break
        case .type(_):
            if let name = identifier, t.array {
                GlobalArrayManager.shared.defineArray(identifier: name)
            }
            else {
                fatalError("ERROR: Error on create array")
            }
        case .structType(let type):
            if let name = identifier {
                GlobalStructManager.shared.addObject(identifier: name, type: type, pointer: t.pointer)
                
                if t.pointer {
                    
                    let structAttributes = GlobalStructManager.shared.getStructAttributes(identifier: type)
                    
                    let bytes = structAttributes.reduce(0, { partialResult, a in
                        a.value.1.pointer ? partialResult + 8 : 4
                    })
                    
                    code.functions["This"]?["This"]?.append("%\(name) = call i8* @malloc(i\(bytes * 8) \(bytes))")
                    code.functions["This"]?["This"]?.append("store %\(type)* null, %\(type)** %\(name)")
                    
                }
                else {
                    code.functions["This"]?["This"]?.append("%\(name) = alloca %\(type)")
                }
            }
            else {
                fatalError("ERROR: Error on create array")
            }
        }
        print("LLVM Global:--------------------------------------")
        code.globalVariables.forEach { item in
            print(item)
        }
        print("LLVM:--------------------------------------")
        code.functions["This"]?["This"]?.forEach { item in
            print(item)
        }
        return code
    }
}

struct LLVMPrintStatement {
    let values: LLVMvalueList
    let printNewLine: Bool
    
    func toLLVMCode() -> LLVMCode {
        var code = LLVMCode(functions: ["This" : ["This" : []]], structs: [:])
        
        for (index, item) in values.values.enumerated() {
            switch item.type {
            case .number:
                let numberId = GlobalIdGenerator.shared.getIntValueId()
                switch item.valueScalar {
                case .number(let value):
                    code.functions["This"]?["This"]?.append("%intVal\(numberId) = alloca i32, align 4")
                    code.functions["This"]?["This"]?.append("store i32 \(value), i32* %intVal\(numberId)")
                    code.functions["This"]?["This"]?.append("%loadedInt\(numberId) = load i32, i32* %intVal\(numberId)")
                    if index == values.values.count - 1 && printNewLine {
                        code.functions["This"]?["This"]?.append("call void @println_int(i32 %loadedInt\(numberId))")
                    }
                    else {
                        code.functions["This"]?["This"]?.append("call void @print_int(i32 %loadedInt\(numberId))")
                    }
                default:
                    break
                }
            case .string:
                let stringId = GlobalIdGenerator.shared.getStringValueId()
                switch item.valueScalar {
                case .string(var value):
                    value = value.replacingOccurrences(of: "\"", with: "")
                    code.globalVariables.append("@.strConst\(stringId) = private unnamed_addr constant [\(value.count + 1) x i8] c\"\(value)\\00\", align 1")
                    code.functions["This"]?["This"]?.append("%strConstPtr\(stringId) = getelementptr [\(value.count + 1) x i8], [\(value.count + 1) x i8]* @.strConst\(stringId), i32 0, i32 0")
                    if index == values.values.count - 1 && printNewLine {
                        code.functions["This"]?["This"]?.append("call void @println_str(i8* %strConstPtr\(stringId))")
                    }
                    else {
                        code.functions["This"]?["This"]?.append("call void @print_str(i8* %strConstPtr\(stringId))")
                    }
                default:
                    break
                }
            case .null:
                fatalError("ERROR: Null case is not implemented on print")
            case .identifier:
                switch item.valueScalar {
                case .identifier(var value):
                    value = value.replacingOccurrences(of: "\"", with: "")
                    let isString: Bool = GlobalStringManager.shared.checkExistence(identifier: value)
                    if isString {
                        let stringId = GlobalIdGenerator.shared.getStringValueId()
                        let stringName = GlobalStringManager.shared.getStringCurrentVariable(identifier: value)
                        code.functions["This"]?["This"]?.append("%strConstPtr\(stringId) = getelementptr [\(value.count + 1) x i8], [\(value.count + 1) x i8]* @.\(stringName), i32 0, i32 0")
                        
                        if index == values.values.count - 1 && printNewLine {
                            code.functions["This"]?["This"]?.append("call void @println_str(i8* %strConstPtr\(stringId))")
                        }
                        else {
                            code.functions["This"]?["This"]?.append("call void @print_str(i8* %strConstPtr\(stringId))")
                        }
                    }
                    else {
                        let numberId = GlobalIdGenerator.shared.getIntValueId()
                        code.functions["This"]?["This"]?.append("%loadedInt\(numberId) = load i32, i32* %\(value)")
                        
                        if index == values.values.count - 1 && printNewLine {
                            code.functions["This"]?["This"]?.append("call void @println_int(i32 %loadedInt\(numberId))")
                        }
                        else {
                            code.functions["This"]?["This"]?.append("call void @print_int(i32 %loadedInt\(numberId))")
                        }
                    }
                default:
                    fatalError("ERROR: Unconsistent types on print")
                }
            case .type(_):
                fatalError("ERROR: Custom type case is not implemented on print")
            case .structType(_):
                break
            }
        }
        print("LLVM Global:--------------------------------------")
        code.globalVariables.forEach { item in
            print(item)
        }
        print("LLVM:--------------------------------------")
        code.functions["This"]?["This"]?.forEach { item in
            print(item)
        }
        return code
    }
}

struct LLVMScanStatement {
    let variable: LLVMVariable
    
    func toLLVMCode() -> LLVMCode {
        var code = LLVMCode(functions: ["This" : ["This" : []]], structs: [:])
        code.functions["This"]?["This"]?.append("call i32 (i8*, ...) @scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.strIntFormat, i64 0, i64 0), i32* %\(variable.identifier))")
        
        print("LLVM Global:--------------------------------------")
        code.globalVariables.forEach { item in
            print(item)
        }
        print("LLVM:--------------------------------------")
        code.functions["This"]?["This"]?.forEach { item in
            print(item)
        }
        
        return code
        
    }
}

struct LLVMStatement {
    var assignationStatement: LLVMAssignationStatement?
    var declarationStatement: LLVMDeclarationStatement?
    var functionCallStatement: LLVMFunctionCallStatement?
    var forStatement: LLVMForStatement?
    var ifStatement: LLVMIfStatement?
    var printStatement: LLVMPrintStatement?
    var scanStatement: LLVMScanStatement?
    
    func toLLVMCode() -> (code: LLVMCode, blockName: String) {
        var code = LLVMCode(functions: ["This" : ["This" : []]], structs: [:])
        var blockName = ""
        
        if let statement = assignationStatement {
            code = statement.toLLVMCode()
        }
        else if let statement = declarationStatement {
            code = statement.toLLVMCode()
        }
        else if let statement = functionCallStatement {
            code = statement.toLLVMCode()
        }
        else if let statement = forStatement {
            let temp = statement.toLLVMCode()
            code = temp.code
            blockName = temp.blockName
        }
        else if let statement = ifStatement {
            let temp = statement.toLLVMCode()
            code = temp.code
            blockName = temp.blockName
        }
        else if let statement = printStatement {
            code = statement.toLLVMCode()
        }
        else if let statement = scanStatement {
            code = statement.toLLVMCode()
        }
        
        return (code, blockName)
    }
}

struct LLVMStatementList {
    var list: [LLVMStatement]
    
    func toLLVMCode() -> (code: LLVMCode, blockName: [String]) {
        var code = LLVMCode(functions: ["This" : ["This" : []]], structs: [:])
        var currentBlock = ""
        var blocks: [String] = []
        list.forEach { statement in
            let temp = statement.toLLVMCode()
            if currentBlock == "" {
                code.append(otherCode: temp.code)
                print("")
            }
            else {
                var tempCode = temp.code
                let tempBlock = tempCode.functions["This"]?["This"]
                tempCode.functions["This"]?["\(currentBlock)"] = tempBlock
                tempCode.functions["This"]?["This"] = []
                
                code.append(otherCode: tempCode)
            }
            if currentBlock != temp.blockName {
                if temp.blockName != "" {
                    blocks.append(temp.blockName)
                }
            }
            if temp.blockName != "" {
                currentBlock = temp.blockName
            }
            
        }
        return (code, blocks)
    }
}

struct LLVMForStatement {
    let booleanOperation: LLVMbooleanOperation
    var block: LLVMStatementList
    
    func toLLVMCode() -> (code: LLVMCode, blockName: String) {
        var code = LLVMCode(functions: ["This" : ["This" : []]], structs: [:])
        
        var booleanLLVMCode = booleanOperation.toLLVMCode()
        var block = block.toLLVMCode()
        
        let condBlockId = GlobalIdGenerator.shared.getIntValueId()
        let loopBlockId = GlobalIdGenerator.shared.getIntValueId()
        let endBlockId = GlobalIdGenerator.shared.getIntValueId()
        
        let blockName = "endBlock\(endBlockId)"
        
        let boolTemp = booleanLLVMCode.code.functions["This"]?["This"]
        let blockTemp = block.code.functions["This"]?["This"]
        booleanLLVMCode.code.functions["This"]?["condBlock\(condBlockId)"] = boolTemp
        block.code.functions["This"]?["loopBlock\(loopBlockId)"] = blockTemp
        
        booleanLLVMCode.code.functions["This"]?["This"] = []
        block.code.functions["This"]?["This"] = []
        
        code.functions["This"]?["This"]?.append("br label %condBlock\(condBlockId)")
        code.append(otherCode: booleanLLVMCode.code)
        code.functions["This"]?["condBlock\(condBlockId)"]?.append("br i1 %\(booleanLLVMCode.varName), label %loopBlock\(loopBlockId), label %endBlock\(endBlockId)")
        code.append(otherCode: block.code)
        code.functions["This"]?["loopBlock\(loopBlockId)"]?.append("br label %condBlock\(condBlockId)")
        
        block.blockName.forEach { b in
            code.functions["This"]?["\(b)"]?.append("br label %condBlock\(condBlockId)")
        }
        
        return (code, blockName)
        
    }
}

struct LLVMIfStatement {
    let booleanOperation: LLVMbooleanOperation
    var block: LLVMStatementList
    var elseBlock: LLVMStatementList?
    
    func toLLVMCode() -> (code: LLVMCode, blockName: String){
        var code = LLVMCode(functions: ["This" : ["This" : []]], structs: [:])
        let booleanLLVMCode = booleanOperation.toLLVMCode()
        let thenBlockId = GlobalIdGenerator.shared.getIntValueId()
        let elseBlockId = GlobalIdGenerator.shared.getIntValueId()
        
        var blockName = ""
        
        code.append(otherCode: booleanLLVMCode.code)
        code.functions["This"]?["This"]?.append("br i1 %\(booleanLLVMCode.varName), label %block\(thenBlockId), label %block\(elseBlockId)")
        
        var thenBlockCode = block.toLLVMCode()
        var temp = thenBlockCode.code.functions["This"]?["This"]
        thenBlockCode.code.functions["This"]?["block\(thenBlockId)"] = temp
        thenBlockCode.code.functions["This"]?["This"] = []
        
        code.append(otherCode: thenBlockCode.code)
        
        if var elseBlockCode = elseBlock?.toLLVMCode() {
            let finalBlockId = GlobalIdGenerator.shared.getIntValueId()
            blockName = "block\(finalBlockId)"
            
            temp = elseBlockCode.code.functions["This"]?["This"]
            elseBlockCode.code.functions["This"]?["block\(elseBlockId)"] = temp
            elseBlockCode.code.functions["This"]?["This"] = []
            
            code.append(otherCode: elseBlockCode.code)
            
            code.functions["This"]?["block\(elseBlockId)"]?.append("br label %\(blockName)")
            code.functions["This"]?["block\(thenBlockId)"]?.append("br label %\(blockName)")
            
            if !elseBlockCode.blockName.isEmpty {
                elseBlockCode.blockName.forEach { b in
                    code.functions["This"]?["\(b)"]?.append("br label %\(blockName)")
                }
            }
            
        }
        else {
            blockName = "block\(elseBlockId)"
            code.functions["This"]?["block\(thenBlockId)"]?.append("br label %\(blockName)")
        }
        
        if !thenBlockCode.blockName.isEmpty {
            thenBlockCode.blockName.forEach { b in
                code.functions["This"]?["\(b)"]?.append("br label %\(blockName)")
            }
        }
        return (code, blockName)
    }
}

struct LLVMFunction {
    let name: String
    let parameters: LLVMParameterList?
    let block: LLVMStatementList
    
    func toLLVMCode() -> LLVMCode {
        var code = LLVMCode(functions: ["\(name)" : ["header" : []]], structs: [:])
        var line = name == "main" ? "define i32 @\(name)(" : "define void @\(name)("
        var preBody: [String] = []
        var par: [String] = []
        
        parameters?.parameters.enumerated().forEach({ (index, element) in
            let varId = GlobalIdGenerator.shared.getIntValueId()
            switch element.type.type {
            case .number:
                if element.type.array || element.type.pointer {
                    GlobalFuncManager.shared.addParameter(funcName: name, parameter: element.identifier, pointer: true, type: "i32")
                    GlobalFuncManager.shared.addParameter(funcName: name, pos: index, pointer: true, type: "i32")
                    par.append("i32* %\(element.identifier)\(varId)")
                    preBody.append("%\(element.identifier) = alloca i32*, align 8")
                    preBody.append("store i32* %\(element.identifier)\(varId), i32** %\(element.identifier), align 8")
                }
                else {
                    GlobalFuncManager.shared.addParameter(funcName: name, pos: index, pointer: false, type: "i32")
                    GlobalFuncManager.shared.addParameter(funcName: name, parameter: element.identifier, pointer: false, type: "i32")
                    par.append("i32 %\(element.identifier)\(varId)")
                    preBody.append("%\(element.identifier) = alloca i32, align 8")
                    preBody.append("store i32 %\(element.identifier)\(varId), i32* %\(element.identifier), align 8")
                }
            case .string:
                fatalError("ERROR: Function parameters of type \(element.type.type) are not implemented yer")
            case .null:
                fatalError("ERROR: Function parameters of type \(element.type.type) are not implemented yer")
            case .identifier:
                fatalError("ERROR: Function parameters of type \(element.type.type) are not implemented yer")
            case .type(let t):
                if t == "int" {
                    let varId2 = GlobalIdGenerator.shared.getIntValueId()
                    GlobalFuncManager.shared.addParameter(funcName: name, parameter: element.identifier, pointer: true, type: "i32")
                    GlobalFuncManager.shared.addParameter(funcName: name, pos: index, pointer: true, type: "i32")
                    par.append("i32* %\(element.identifier)\(varId)")
                    preBody.append("%\(element.identifier)\(varId2) = alloca i32*, align 8")
                    preBody.append("store i32* %\(element.identifier)\(varId), i32** %\(element.identifier)\(varId2), align 8")
                    preBody.append("%\(element.identifier) = load i32*, i32** %\(element.identifier)\(varId2), align 8")
                }
                else {
                    let varId2 = GlobalIdGenerator.shared.getIntValueId()
                    GlobalFuncManager.shared.addParameter(funcName: name, parameter: element.identifier, pointer: true, type: t)
                    GlobalFuncManager.shared.addParameter(funcName: name, pos: index, pointer: true, type: t)
                    GlobalStructManager.shared.addObject(identifier: element.identifier, type: t, pointer: true)
                    par.append("%\(t)* %\(element.identifier)\(varId)")
                    preBody.append("%\(element.identifier)\(varId2) = alloca %\(t)*")
                    preBody.append("store %\(t)* %\(element.identifier)\(varId), %\(t)** %\(element.identifier)\(varId2)")
                    preBody.append("%\(element.identifier) = load %\(t)*, %\(t)** %\(element.identifier)\(varId2)")
                }
            case .structType(let t):
                let varId2 = GlobalIdGenerator.shared.getIntValueId()
                GlobalFuncManager.shared.addParameter(funcName: name, parameter: element.identifier, pointer: true, type: t)
                GlobalFuncManager.shared.addParameter(funcName: name, pos: index, pointer: true, type: t)
                GlobalStructManager.shared.addObject(identifier: element.identifier, type: t, pointer: true)
                par.append("%\(t)* %\(element.identifier)\(varId)")
                preBody.append("%\(element.identifier)\(varId2) = alloca %\(t)*")
                preBody.append("store %\(t)* %\(element.identifier)\(varId), %\(t)** %\(element.identifier)\(varId2)")
                preBody.append("%\(element.identifier) = load %\(t)*, %\(t)** %\(element.identifier)\(varId2)")
            }
        })
        
        line.append(par.joined(separator: ","))
        line.append(") {")
        
        code.functions["\(name)"]?["header"]?.append(line)
        
        let blockCode = block.toLLVMCode()
        
        blockCode.code.functions["This"]?.forEach({ b in
            if b.key == "This" {
                code.functions["\(name)"]?["entry"] = preBody
                code.functions["\(name)"]?["entry"]?.append(contentsOf: b.value)
            }
            else {
                code.functions["\(name)"]?["\(b.key)"] = b.value
            }
        })
        
        if name == "main" {
            blockCode.blockName.forEach { b in
                if code.functions["\(name)"]?["\(b)"] != nil {
                    code.functions["\(name)"]?["\(b)"]?.append("ret i32 0")
                }
                else {
                    code.functions["\(name)"]?["\(b)"] = ["ret i32 0"]
                }
            }
            if blockCode.blockName.isEmpty {
                code.functions["\(name)"]?["entry"]?.append("ret i32 0")
            }
        }
        else {
            blockCode.blockName.forEach { b in
                if code.functions["\(name)"]?["\(b)"] != nil {
                    code.functions["\(name)"]?["\(b)"]?.append("ret void")
                }
                else {
                    code.functions["\(name)"]?["\(b)"] = ["ret void"]
                }
            }
            if blockCode.blockName.isEmpty {
                code.functions["\(name)"]?["entry"]?.append("ret void")
            }
        }
        
        code.functions["\(name)"]?["end"]?.append("}")
        
        code.globalVariables.append(contentsOf: blockCode.code.globalVariables)
        
        return code
    }
}

struct LLVMDefList {
    var functionList: [LLVMFunction]
    var structList: [LLVMStructDefinition]
    
    func toLLVMCode() -> LLVMCode {
        var code = LLVMCode(functions: ["main" : ["header" : []]], structs: [:])
        
        structList.forEach { s in
            code.append(otherCode: s.toLLVMCode())
            
        }
        
        functionList.forEach { f in
            code.append(otherCode: f.toLLVMCode())
        }
        
        return code
    }
}

struct LLVMProgram {
    var defList: LLVMDefList
    
    func toLLVMCode() -> [String] {
        var response: [String] = []
        let code = defList.toLLVMCode()
        
        response.append(code.alwaysPrintFunctions)
        response.append(contentsOf: code.alwaysPrintGlobalVariables)
        response.append(contentsOf: code.globalVariables)
        
        code.functions.forEach { f in
            response.append(contentsOf: f.value["header"] ?? [])
            response.append("entry:")
            response.append(contentsOf: f.value["entry"] ?? [])
            response.append("")
            
            f.value.forEach { b in
                if b.key != "header" && b.key != "entry" && b.key != "end" {
                    response.append("\(b.key):")
                    response.append(contentsOf: b.value)
                    response.append("")
                }
            }
            
            response.append("}")
        }
        
        return response
    }
}

struct LLVMCode {
    let alwaysPrintFunctions: String = """
  define void @print_str(i8* %str) {\nentry:\n    ; Print the string using printf\n    call i32 (i8*, ...) @printf(i8* %str)\n    ret void\n}\n\ndefine void @print_int(i32 %num) {\nentry:\n    ; Print the integer using printf\n    %strIntFormat = getelementptr [4 x i8], [4 x i8]* @.strIntFormat, i32 0, i32 0\n    call i32 (i8*, ...) @printf(i8* %strIntFormat, i32 %num)\n    ret void\n}\n\ndefine void @println_str(i8* %str) {\nentry:\n    ; Print the string\n    call void @print_str(i8* %str)\n\n    ; Print a newline character\n    %strNewlinePtr = getelementptr [2 x i8], [2 x i8]* @.strNewline, i32 0, i32 0\n    call i32 (i8*, ...) @printf(i8* %strNewlinePtr)\n    \n    ret void\n}\n\ndefine void @println_int(i32 %num) {\nentry:\n    ; Print the integer\n    call void @print_int(i32 %num)\n\n    ; Print a newline character\n    %strNewlinePtr = getelementptr [2 x i8], [2 x i8]* @.strNewline, i32 0, i32 0\n    call i32 (i8*, ...) @printf(i8* %strNewlinePtr)\n    \n    ret void\n}\n@.strIntFormatRead = private unnamed_addr constant [3 x i8] c\"%d\\00\", align 1
  
  ; External function declaration for malloc (memory allocation)
  declare i8* @malloc(i64)
  
  define i32* @expand_and_copy_array(i32* %srcArray, i32 %N) {
  entry:
      ; Calculate the size of the new array (10 x (N + 1))
      %newSize = add i32 %N, 1
      %totalElements = mul i32 %newSize, 10
  
      ; Calculate the total size in bytes (4 bytes per i32)
      %totalSizeInBytes = mul i32 %totalElements, 4
      %totalSizeInBytes64 = sext i32 %totalSizeInBytes to i64
  
      ; Allocate memory for the new array on the heap
      %newArray = call i8* @malloc(i64 %totalSizeInBytes64)
  
      ; Bitcast the allocated memory to an i32 pointer
      %newArrayPtr = bitcast i8* %newArray to i32*
  
      ; Loop counters
      %i = alloca i32, align 4
      %j = alloca i32, align 4
      store i32 0, i32* %i, align 4
      store i32 0, i32* %j, align 4
  
      br label %copy_outer_loop
  
  copy_outer_loop:                                        ; Outer loop for rows
      %i_val = load i32, i32* %i, align 4
      %N_cond = icmp slt i32 %i_val, %N
      br i1 %N_cond, label %copy_inner_loop, label %initialize_new_row
  
  copy_inner_loop:                                        ; Inner loop for columns
      %j_val = load i32, i32* %j, align 4
      %j_cond = icmp slt i32 %j_val, 10
      br i1 %j_cond, label %copy_elements, label %increment_row
  
  copy_elements:                                          ; Copy elements from srcArray to newArray
      %srcIdx = mul i32 %i_val, 10
      %srcOffset = add i32 %srcIdx, %j_val
      %srcElementPtr = getelementptr inbounds i32, i32* %srcArray, i32 %srcOffset
      %srcElement = load i32, i32* %srcElementPtr, align 4
  
      %newIdx = mul i32 %i_val, 10
      %newOffset = add i32 %newIdx, %j_val
      %newElementPtr = getelementptr inbounds i32, i32* %newArrayPtr, i32 %newOffset
      store i32 %srcElement, i32* %newElementPtr, align 4
  
      ; Increment inner loop counter
      %j_next = add i32 %j_val, 1
      store i32 %j_next, i32* %j, align 4
      br label %copy_inner_loop
  
  increment_row:                                          ; Increment outer loop counter
      %i_next = add i32 %i_val, 1
      store i32 %i_next, i32* %i, align 4
  
      ; Reset inner loop counter
      store i32 0, i32* %j, align 4
      br label %copy_outer_loop
  
  initialize_new_row:                                     ; Initialize the new row (N-th index)
      %i_newRow = load i32, i32* %i, align 4
      %j_new = load i32, i32* %j, align 4
      %j_newCond = icmp slt i32 %j_new, 10
      br i1 %j_newCond, label %init_elements, label %end_new_row
  
  init_elements:                                          ; Initialize elements in the new row
      %newRowIdx = mul i32 %N, 10
      %newRowOffset = add i32 %newRowIdx, %j_new
      %newRowElementPtr = getelementptr inbounds i32, i32* %newArrayPtr, i32 %newRowOffset
      store i32 0, i32* %newRowElementPtr, align 4  ; Example: initialize with 0
  
      %j_newNext = add i32 %j_new, 1
      store i32 %j_newNext, i32* %j, align 4
      br label %initialize_new_row
  
  end_new_row:
      ret i32* %newArrayPtr
  }
  """
    
    var alwaysPrintGlobalVariables: [String] = ["@.strIntFormat = private unnamed_addr constant [3 x i8] c\"%d\\00\", align 1",
                                                "@.strNewline = private unnamed_addr constant [2 x i8] c\"\\0A\\00\", align 1",
                                                "declare i32 @scanf(i8*, ...)",
                                                "declare i32 @printf(i8*, ...)"
    ]
    
    var globalVariables: [String] = []
    var functions: [String: [String: [String]]]
    var structs: [String: [String]]
    
    mutating func append(otherCode: LLVMCode) {
        globalVariables.append(contentsOf: otherCode.globalVariables)
        
        for (functionName, functionData) in otherCode.functions {
            if functions[functionName] == nil {
                functions[functionName] = functionData
            } else {
                for (blockName, blockData) in functionData {
                    if functions[functionName]?[blockName] == nil {
                        functions[functionName]?[blockName] = blockData
                    } else {
                        functions[functionName]?[blockName]?.append(contentsOf: blockData)
                    }
                }
            }
        }
        
        for (structName, structData) in otherCode.structs {
            if structs[structName] == nil {
                structs[structName] = structData
            } else {
                structs[structName]?.append(contentsOf: structData)
            }
        }
    }
}

enum booleanOperator {
    case more;
    case less;
    case equalsEquals;
    case moreEquals;
    case lessEquals;
    case notEquals;
    
    case unknown;
}

enum arithmeticOperator {
    case plus;
    case minus;
    case star;
    case slash;
    
    case unknown;
}

enum statementType {
    case forType;
    case ifType;
    case other;
}

enum valueScalar {
    case number(value: Int)
    case string(value: String)
    case identifier(value: String)
    case null
}

enum LLVMType: Equatable {
    case number
    case string
    case null
    case identifier
    case type(value: String)
    case structType(type: String)
}


class GlobalIdGenerator {
    private var intValuesCurrentId = 0
    private var stringValuesCurrentId = 0
    private init() {}
    
    public static var shared = GlobalIdGenerator()
    
    public func getIntValueId() -> Int {
        intValuesCurrentId = intValuesCurrentId + 1
        return intValuesCurrentId
    }
    
    public func getStringValueId() -> Int {
        stringValuesCurrentId = stringValuesCurrentId + 1
        return stringValuesCurrentId
    }
}

class GlobalStringManager {
    private var strings: [String : String] = [:]
    
    private init() {}
    
    public static var shared = GlobalStringManager()
    
    public func defineString(identifier: String, currentVariable: String) {
        if strings[identifier] != nil {
            fatalError("ERROR: String variable \(identifier) is already defined")
        }
        else {
            strings[identifier] = currentVariable
        }
    }
    
    public func updateString(identifier: String, newVariable: String) {
        if strings[identifier] != nil {
            strings[identifier] = newVariable
        }
        else {
            fatalError("ERROR: String variable \(identifier) is not defined")
        }
    }
    
    public func getStringCurrentVariable(identifier: String) -> String {
        if let response = strings[identifier] {
            return response
        }
        else {
            fatalError("ERROR: String variable \(identifier) is not defined")
        }
    }
    
    public func checkExistence(identifier: String) -> Bool {
        return !(strings[identifier] == nil)
    }
}

class GlobalArrayManager {
    private var arrays: [String : Int] = [:]
    private var arraysIdentfier: [String : String] = [:]
    
    private init() {}
    
    public static var shared = GlobalArrayManager()
    
    public func defineArray(identifier: String) {
        if let response = arrays[identifier] {
            fatalError("ERROR: Array variable \(identifier) is already defined")
        }
        else {
            arrays[identifier] = 0
        }
    }
    
    public func changeArraySize(identifier: String, size: Int) {
        if arrays[identifier] != nil {
            arrays[identifier] = size
        }
        else {
            fatalError("ERROR: Array variable \(identifier) is not defined")
        }
    }
    
    public func changeArraySize(identifier: String, sizeIdentifier: String) {
        if arrays[identifier] != nil {
            arrays[identifier] = -1
            arraysIdentfier[identifier] = sizeIdentifier
        }
        else {
            fatalError("ERROR: Array variable \(identifier) is not defined")
        }
    }
    
    public func getArraySize(identifier: String) -> Int {
        if let response = arrays[identifier] {
            return response
        }
        else {
            fatalError("ERROR: Array variable \(identifier) is not defined")
        }
    }
    
    public func getArraySizeIdentifier(identifier: String) -> String {
        if let response = arraysIdentfier[identifier] {
            return response
        }
        else {
            fatalError("ERROR: Array variable \(identifier) is not defined")
        }
    }
    
    public func isArray(identifier: String) -> Bool {
        if arrays[identifier] != nil {
            return true
        }
        else {
            return false
        }
    }
}

class GlobalFuncManager {
    private var funPointers: [String : [String : Bool]] = [:]
    private var funPointersByPos: [String : [Int : Bool]] = [:]
    private var funParameterType: [String : [String : String]] = [:]
    private var funParameterTypeByPos: [String : [Int : String]] = [:]
    
    private init() {}
    
    public static var shared = GlobalFuncManager()
    
    public func addParameter(funcName: String, parameter: String, pointer: Bool, type: String) {
        if funPointers[funcName] == nil {
            funPointers[funcName] = [:]
            funParameterType[funcName] = [:]
        }
        funPointers[funcName]?[parameter] = pointer
        funParameterType[funcName]?[parameter] = type
        
    }
    
    public func addParameter(funcName: String, pos: Int, pointer: Bool, type: String) {
        if funPointersByPos[funcName] == nil {
            funPointersByPos[funcName] = [:]
            funParameterType[funcName] = [:]
        }
        funPointersByPos[funcName]?[pos] = pointer
        funParameterTypeByPos[funcName]?[pos] = type
    }
    
    public func isParameterPointer(funcName: String, parameter: String) -> Bool {
        return funPointers[funcName]?[parameter] ?? false
    }
    
    public func isParameterPointer(funcName: String, pos: Int) -> Bool {
        return funPointersByPos[funcName]?[pos] ?? false
    }
    
    public func getParameterType(funcName: String, parameter: String) -> String {
        return funParameterType[funcName]?[parameter] ?? ""
    }
    
    public func getParameterType(funcName: String, pos: Int) -> String {
        return funParameterTypeByPos[funcName]?[pos] ?? ""
    }
}

class GlobalStructManager {
    private var structsAtt: [String : [String : (Int, (type: String, pointer: Bool))]] = [:]
    private var structObjects: [String : (type: String, pointer: Bool)] = [:]
    
    private init() {}
    
    public static var shared = GlobalStructManager()
    
    func getStructAttributes(identifier: String) -> [String : (Int, (type: String, pointer: Bool))] {
        if let response = structsAtt[identifier] {
            return response
        }
        else {
            fatalError("ERROR: Struct type not defined")
        }
    }
    
    func addObject(identifier: String, type: String, pointer: Bool) {
        if structObjects[identifier] != nil {
            print("ERROR: Struct object \(identifier) is already defined")
        }
        else {
            structObjects[identifier] = (type: type, pointer: pointer)
        }
    }
    
    func getObjectType(identifier: String) -> String {
        if let s = structObjects[identifier] {
            return s.type
        }
        else {
            fatalError("ERROR: Struct object \(identifier) is not defined")
        }
    }
    
    func isObjectPointer(identifier: String) -> Bool {
        if let s = structObjects[identifier] {
            return s.pointer
        }
        else {
            fatalError("ERROR: Struct object \(identifier) is not defined")
        }
    }
    
    func addStruct(identifier: String) {
        if structsAtt[identifier] != nil {
            fatalError("ERROR: Struct \(identifier) is already defined")
        }
        else {
            structsAtt[identifier] = [:]
        }
    }
    
    func addStructAttribute(identifier: String, attribute: String, pos: Int, type: String, pointer: Bool) {
        if structsAtt[identifier] != nil {
            if (structsAtt[identifier]?[attribute]) != nil {
                fatalError("ERROR: Struct attribute \(identifier).\(attribute) is already defined")
            }
            else {
                structsAtt[identifier]?[attribute] = (pos, (type, pointer))
            }
        }
        else {
            fatalError("ERROR: Struct \(identifier) is not defined")
        }
    }
    
    func getStructAttributePos(identifier: String, attribute: String) -> Int {
        if let a = structsAtt[identifier]?[attribute] {
            return a.0
        }
        else {
            fatalError("ERROR: Struct attribute \(identifier).\(attribute) is not defined")
            
        }
    }
    
    func getStructAttributeType(identifier: String, attribute: String) -> String {
        if let a = structsAtt[identifier]?[attribute] {
            return a.1.type
        }
        else {
            fatalError("ERROR: Struct attribute \(identifier).\(attribute) is not defined")
            
        }
    }
    
    func isStructAttributeAPointer(identifier: String, attribute: String) -> Bool {
        if let a = structsAtt[identifier]?[attribute] {
            return a.1.pointer
        }
        else {
            fatalError("ERROR: Struct attribute \(identifier).\(attribute) is not defined")
            
        }
    }
    
    func isStructObject(identifier: String) -> Bool {
        if structObjects[identifier] != nil {
            return true
        }
        else {
            return false
        }
    }
}

class GlobalLogManager {
    private var log: [String] = []
    
    private init() {}
    
    public static var shared = GlobalLogManager()
    
    public func addlog(_ value: String) {
        log.append(value)
    }
    
    public func printLog() {
        print("===================================LOG START===================================")
        log.enumerated().forEach { (i, value) in
            print("log #\(i): ", value)
        }
        print("===================================LOG END===================================")
    }
}
