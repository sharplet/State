/// The state monad. Wraps a stateful function S -> (A, S).
public struct State<S, A> {
    // MARK: Initialisers

    /// Wrap a stateful computation.
    public init(f: S -> (A, S)) {
        fn = f
    }

    /// Lift a value into stateful computation that returns the value and the state unchanged.
    public init(_ a: A) {
        fn = { s in (a, s) }
    }


    // MARK: Running stateful computations

    /// Run the computation with a starting state, returning a tuple of the value and the final state.
    public func run(s: S) -> (A, S) {
        return fn(s)
    }

    /// Run the computation and return on the resulting value, discarding the final state.
    public func eval(s: S) -> A {
        return run(s).0
    }

    /// Run the computation and return the final state, discarding the resulting value.
    public func exec(s: S) -> S {
        return run(s).1
    }


    // MARK: Sequencing stateful computations

    /// Run this computation, discarding its result, then run the next computation.
    public func then<B>(next: State<S, B>) -> State<S, B> {
        return flatMap { _ in next }
    }


    // MARK: Higher order functions

    /// Return a new stateful computation which is the result of applying `f` to the result of this computation.
    public func map<B>(f: A -> B) -> State<S, B> {
        return flatMap { yield(f($0)) }
    }

    /// Sequence this computation with computation, using the value of this computation as input to the second.
    public func flatMap<B>(f: A -> State<S, B>) -> State<S, B> {
        return State<S, B> { s1 in
            let (a, s2) = self.run(s1)
            return f(a).run(s2)
        }
    }


    // MARK: Private

    private let fn: S -> (A, S)
}


// MARK: Operations

/// A computation that yields the current state as its result.
public func get<S>() -> State<S, S> {
    return State { s in (s, s) }
}

/// A computation that replaces the current state.
public func put<S>(s: S) -> State<S, ()> {
    return State { _ in ((), s) }
}

/// Lift a value into the State monad.
public func yield<S, A>(a: A) -> State<S, A> {
    return State(a)
}
