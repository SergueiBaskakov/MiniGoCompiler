//
//  Tree.swift
//  miniGoV2
//
//  Created by Serguei Diaz on 23.06.2024.
//

import Foundation

struct BasicTree: TreeProtocol {
    var firstNode: (any NodeProtocol)?
    
    init(firstNode: (any NodeProtocol)?) {
        self.firstNode = firstNode
    }
    
    func toStringByLevels() -> [String] {
        guard let node = firstNode else { return [] }
        var tempNodes: [NodeProtocol] = []
        tempNodes.append(node)
        
        var response: [String] = []
        
        var level: Int = 1
        
        var continueWhile: Bool = true
        
        while continueWhile {
            continueWhile = tempNodes.contains { node in
                !node.childs.isEmpty
            }
            
            let levelString = tempNodes.reduce("Level \(level):") { partialResult, node in
                "\(partialResult) \(node.getString())"
            }
            
            response.append(levelString)
            
            level = level + 1
            
            tempNodes = tempNodes.reduce([], { partialResult, node in
                var result = partialResult
                if node.childs.isEmpty {
                    result.append(node)
                }
                else {
                    result.append(contentsOf: node.childs)
                }
                return result
            })
            
            
        }
        
        return response
    }
    
    func toStringGraph() -> [String] {
        firstNode?.toStringGraph() ?? []
    }
}

struct Node: NodeProtocol {
    let type: NodeType
    
    var childs: [NodeProtocol]
    
    private let id: String
    
    init(type: NodeType, childs: [any NodeProtocol]) {
        self.type = type
        self.childs = childs
        self.id = "Node-\(IdGenerator.shared.getId())"
    }
    
    func getString() -> String {
        switch type {
        case .terminal(_, let value):
            return value
        case .nonTerminal(let subType):
            return String(describing: subType)
        }
    }
    
    func getId() -> String {
        return self.id
    }
    
    func toStringGraph() -> [String] {
        var typeRawValue: String = ""
        switch type {
        case .terminal(_, let value):
            typeRawValue = value
        case .nonTerminal(let subType):
            typeRawValue = String(describing: subType)
        }
        
        let childsString: String = childs.reduce("\(id)_\(typeRawValue):") { partialResult, child in
            "\(partialResult) \(child.getId())"
        }
        
        return childs.reduce([childsString]) { partialResult, child in
            var result = partialResult
            result.append(contentsOf: child.toStringGraph())
            
            return result
        }
    }
}

protocol TreeProtocol {
    
    var firstNode: NodeProtocol? { get set }
    
    func toStringByLevels() -> [String]
    
    func toStringGraph() -> [String]
}

extension TreeProtocol {
    func toStringByLevels() -> [String] {
        guard let node = firstNode else { return [] }
        var tempNodes: [NodeProtocol] = []
        tempNodes.append(node)
        
        var response: [String] = []
        
        var level: Int = 1
        
        var continueWhile: Bool = true
        
        while continueWhile {
            continueWhile = tempNodes.contains { node in
                !node.childs.isEmpty
            }
            
            let levelString = tempNodes.reduce("Level \(level):") { partialResult, node in
                "\(partialResult) \(node.getString())"
            }
            
            response.append(levelString)
            
            level = level + 1
            
            tempNodes = tempNodes.reduce([], { partialResult, node in
                var result = partialResult
                if node.childs.isEmpty {
                    result.append(node)
                }
                else {
                    result.append(contentsOf: node.childs)
                }
                return result
            })
        }
        
        return response
    }
    
    func toStringGraph() -> [String] {
        firstNode?.toStringGraph() ?? []
    }
}

protocol NodeProtocol {
    
    var type: NodeType { get }
    
    var childs: [NodeProtocol] { get set }
    
    func getString() -> String
    
    func getId() -> String
    
    func toStringGraph() -> [String]
    
}

struct IdGenerator {

    static var shared: IdGenerator = IdGenerator()

    private var currentId: Int = 0
    
    private init() { }
    
    mutating func getId() -> Int {
        currentId = currentId + 1
        return currentId
    }
}

enum NodeType: Equatable {
    case terminal(subType: Terminal, value: String)
    case nonTerminal(subType: NonTerminal)
}
