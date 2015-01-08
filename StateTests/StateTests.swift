//
//  Copyright (c) 2015 Adam Sharp. All rights reserved.
//

import State
import XCTest

class StateTests: XCTestCase {
    // MARK: Running stateful computations

    func testRun() {
        XCTAssert(((), [1]) == push(1).run([]))
    }

    func testExec() {
        XCTAssert([] == pop().exec([1]))
    }

    func testEval() {
        XCTAssert(1 == pop().eval([1]))
    }


    // MARK: Sequencing stateful computations

    func testThen() {
        XCTAssert([2, 1] == push(1).then(push(2)).exec([]))
    }


    // MARK: Higher order functions

    func testMapTransformsTheComputationResult() {
        XCTAssert("1" == pop().map(toString).eval([1]))
    }

    func testFlatMapUsesTheResultAsInputToTheNextComputation() {
        let add = pop().flatMap { a in
                  pop().flatMap { b in
                      push(a + b)
                  }}

        XCTAssert([3] == add.exec([2,1]))
    }
}
