/**
   XCTestManifests.swift
   ShellKitTests

   Created by Tibor Bödecs on 2018.12.31.
   Copyright Binary Birds. All rights reserved.
*/

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ShellKitTests.allTests),
    ]
}
#endif
