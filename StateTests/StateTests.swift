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


    // MARK: State operations

    func testGetReadsTheCurrentState() {
        XCTAssert([1] == get().eval([1]))
    }

    func testPutReplacesTheCurrentState() {
        XCTAssert([3,2,1] == put([3,2,1]).exec([]))
        XCTAssert([3,2,1] == put([3,2,1]).exec([4,5,6]))
        XCTAssert([3,2,1] == put([3,2,1]).exec(Array(1...100)))
    }

    func testGetAndPutAllowReadingStateAtDifferentPointsInTime() {
        let wrapString = get().flatMap { str in
                         put("foo").then(get()).flatMap { foo in
                         put("bar").then(get()).flatMap { bar in
                             put("\(foo), \(str), \(bar)")
                         }}}

        XCTAssert("foo, hello, bar" == wrapString.exec("hello"))
    }
}
