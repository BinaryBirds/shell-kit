/**
    LinuxMain.swift
    ShellKitTests
 
    Created by Tibor Bödecs on 2018.12.31.
    Copyright Binary Birds. All rights reserved.
 */

import XCTest
@testable import ShellKit

final class ShellTests: XCTestCase {

    static var allTests = [
        ("testOutput", testOutput),
        ("testError", testError),
        ("testEnvironment", testEnvironment),
    ]

    // MARK: - helpers
    
    private func invalid(error type: Error, expected: String) {
        XCTFail("Invalid error type `\(type)`, expected `\(expected)`.")
    }

    private func assert<T: Equatable>(type: String, result: T, expected: T) {
        XCTAssertEqual(result, expected, "Invalid \(type) `\(result)`, expected `\(expected)`.")
    }

    // MARK: - test functions
    
    func testOutput() throws {
        let expectedOutput = "Hello world!"
        let output = try Shell().run("echo \(expectedOutput)")
        self.assert(type: "output", result: output, expected: expectedOutput)
    }

    func testError() {
        do {
            try Shell().run("cd /invalid-directory")
            XCTFail("This command should throw a `Shell.Error.generic(Int, String)` error.")
        }
        catch let error as Shell.Error {
            self.assert(type: "output",
                        result: error.localizedDescription,
                        expected: "/bin/sh: line 0: cd: /invalid-directory: No such file or directory (code: 1)")

            switch error {
            case .generic(let code, _):
                XCTAssertNotEqual(code, 0, "Exit code should not be zero.")
            case .outputData:
                self.invalid(error: error, expected: "Shell.Error.generic(Int, String)")
            }
        }
        catch {
            self.invalid(error: error, expected: "Shell.Error")
        }
    }
    
    func testEnvironment() throws {
        let key = "ENV_SAMPLE_KEY"
        let expectedOutput = "Custom env variable"
        let shell = Shell()
        shell.env[key] = expectedOutput
        let output = try shell.run("echo $\(key)")
        self.assert(type: "output", result: output, expected: expectedOutput)
    }
    
    #if os(macOS)
    func testOutputHandler() throws {
        let expectedOutput = "Hello world!"
        let pipe = Pipe()
        let shell = Shell()
        shell.outputHandler = pipe.fileHandleForWriting
        let output = try shell.run("echo \(expectedOutput)")
        let handlerData = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let handlerOutput = String(data: handlerData, encoding: .utf8)?.trimmingCharacters(in: .newlines) else {
            return XCTFail("Empty handler output, expected `\(expectedOutput)`.")
        }
        self.assert(type: "output", result: output, expected: expectedOutput)
        self.assert(type: "handler output", result: handlerOutput, expected: expectedOutput)
    }

    func testErrorHandler() throws {
        let pipe = Pipe()
        let shell = Shell()
        shell.errorHandler = pipe.fileHandleForWriting

        do {
            try shell.run("cd /invalid-directory")
        }
        catch let error as Shell.Error {
            switch error {
            case .generic(let code, let message):
                let handlerData = pipe.fileHandleForReading.readDataToEndOfFile()
                guard let handlerError = String(data: handlerData, encoding: .utf8) else {
                    return XCTFail("Empty handler output, expected valid error message.")
                }
                XCTAssertNotEqual(code, 0, "Exit code should not be zero.")
                self.assert(type: "message", result: handlerError.trimmingCharacters(in: .newlines), expected: message)
            case .outputData:
                self.invalid(error: error, expected: "Shell.Error.generic(Int, String)")
            }
        }
        catch {
            self.invalid(error: error, expected: "Shell.Error")
        }
    }

    func testAsyncRun() {
        
        let expectedOutput = "Hello world!"
        let command = "sleep 2 && echo \(expectedOutput)"
        let expectation = XCTestExpectation(description: "Shell command finished.")
        
        Shell().run(command) { result, error in
            if let error = error {
                return XCTFail("There should be no errors. (error: `\(error.localizedDescription)`)")
            }
            guard let output = result else {
                return XCTFail("Empty result, expected `\(expectedOutput)`.")
            }
            self.assert(type: "output", result: output, expected: expectedOutput)
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 5)
    }
    #endif
}
