//
//  main.swift
//  miniGoV2
//
//  Created by Serguei Diaz on 23.06.2024.
//

import Foundation
import SwiLex
import SwiParse

var lexer = SwiLex<Terminal>()

print("Enter source code filename:")
guard let inputFileName = readLine() else {
    print("No filename provided")
    exit(1)
}

print("Enter output LLVM code filename:")
guard let outputFileName = readLine() else {
    print("No filename provided")
    exit(1)
}
var fileContent: String = readFilePath(fileName: inputFileName).replacingOccurrences(of: "\t", with: "").replacingOccurrences(of: "\n", with: "")

if !fileContent.isEmpty {
    executeCompiler(code: fileContent)
}

GlobalLogManager.shared.printLog()

func printArrayOfStrings(_ array: [String]) {
    array.forEach { element in
        print(element)
    }
}

func readFilePath(fileName: String) -> String {
    var fileContent: String = ""
    
    let fileManager = FileManager.default
    let filePath = "\(fileName)"
    print(filePath)
    do {
        fileContent = try String(contentsOfFile: filePath, encoding: .utf8)
    } catch {
        print("Error reading file: \(error.localizedDescription)")
    }
    
    return fileContent
}

func writeToFile(content: [String], fileName: String) {
    
    let fileURL = URL(fileURLWithPath: fileName)
    
    do {
        try content.joined(separator: "\n").write(to: fileURL, atomically: true, encoding: .utf8)
        print("File written successfully at: \(fileURL)")
    } catch {
        print("Error writing to file: \(error)")
    }
}

func executeCompiler(code: String) {
    print("Executing...")
    
    do {
        guard parser != nil else {
            print("No parser")
            return
        }
        let node = try parser?.parse(input: fileContent)
        
        if let result: LLVMProgram = node as? LLVMProgram {
            let code = result.toLLVMCode()
            print("==================== LLVM CODE START ====================")
            printArrayOfStrings(code)
            print("==================== LLVM CODE END ====================")
            writeToFile(content: code, fileName: outputFileName)
        }
        else {
            print("Error")
            print(node)
        }
    } catch(let err) {
        print(err)
    }
}


