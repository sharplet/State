/// The state monad.
public struct State<S, A> {

    public init(f: S -> (A, S)) {
        fn = f
    }

    public init(_ a: A) {
        fn = { s in (a, s) }
    }

    public func run(s: S) -> (A, S) {
        return fn(s)
    }

    public func eval(s: S) -> A {
        return run(s).0
    }

    public func exec(s: S) -> S {
        return run(s).1
    }

    public func map<B>(f: A -> B) -> State<S, B> {
        return self >>- { yield(f($0)) }
    }

    public func flatMap<B>(f: A -> State<S, B>) -> State<S, B> {
        return State<S, B> { s1 in
            let (a, s2) = self.run(s1)
            return f(a).run(s2)
        }
    }

    private let fn: S -> (A, S)

}

public func yield<S, A>(a: A) -> State<S, A> {
    return State(a)
}

infix operator >>- { associativity left }
public func >>-<S, A, B>(s: State<S, A>, f: A -> State<S, B>) -> State<S, B> {
    return s.flatMap(f)
}

infix operator >>> { associativity left }
public func >>><S, A, B>(a: State<S, A>, b: State<S, B>) -> State<S, B> {
    return a >>- { _ in b }
}

infix operator <| { precedence 0 associativity right }
func <| <S, A> (state: State<S, A>, start: S) -> (A, S) {
    return state.run(start)
}

infix operator |> { precedence 0 associativity left }
func |> <S, A> (start: S, state: State<S, A>) -> (A, S) {
    return state.run(start)
}

public func get<S>() -> State<S, S> {
    return State { s in (s, s) }
}

public func put<S>(s: S) -> State<S, ()> {
    return State { _ in ((), s) }
}

private func unwrap<A, B, R>(t: (A, B), f: (A, B) -> R) -> R {
    return f(t)
}
