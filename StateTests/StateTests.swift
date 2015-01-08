//
//  Copyright (c) 2015 Adam Sharp. All rights reserved.
//

import State
import XCTest

class StateTests: XCTestCase {
    func testRun() {
        XCTAssert(((), [1]) == push(1).run([]))
    }

    func testExec() {
        XCTAssert([] == pop().exec([1]))
    }

    func testEval() {
        XCTAssert(1 == pop().eval([1]))
    }
}
