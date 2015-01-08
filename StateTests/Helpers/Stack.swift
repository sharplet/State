//
//  Copyright (c) 2015 Adam Sharp. All rights reserved.
//

import State

typealias Stack = [Int]

func push(x: Int) -> State<Stack, ()> {
    return State { xs in ((), [x] + xs) }
}

func pop() -> State<Stack, Int> {
    return State { xs in (xs.first!, Array(dropFirst(xs))) }
}

func == (lhs: ((), Stack), rhs: ((), Stack)) -> Bool {
    return lhs.1 == rhs.1
}

func == <A: Equatable> (lhs: Stack, rhs: Stack) -> Bool {
    for (i, j) in Zip2(lhs, rhs) {
        if i != j {
            return false
        }
    }
    return true
}
