# Haskell's State monad in Swift

State is a µframework providing a Swift port of Haskell's State monad.
It is an exploration of how Haskell-style monadic APIs might work in Swift.

Currently, State is more of a curiosity intended for educational purposes.
I don't recommend it's use in production code.


## Background

Haskell's data types are immutable, and its functions *pure*.
Functions can't modify their arguments, nor mutate any global state.
This kind of code is impossible:

```objc
NSMutableArray *stack = @[].mutableCopy;

[stack addObject:@1];     // => @[@1]
[stack addObject:@2];     // => @[@1, @2]
[stack lastObject];       // => @2
[stack removeLastObject]; // => @[@1]
```

This example uses an `NSMutableArray` as a kind of stack, using `addObject:` to push new elements, `lastObject` to see the top element, and `removeLastObject` to pop the top element from the stack.

Remember that functions in Haskell can't modify their arguments, but can only return a value.
If you have a `pop` function that returns the top of the stack, it must also return a new stack that has the top element removed.

```haskell
type Stack = [Int]

-- take a stack, and return a tuple containing the top of the stack and a new
-- stack with the element removed
pop :: Stack -> (Int, Stack)
```

However, sequencing multiple stateful functions like this becomes rather tedious:

```haskell
let stack = [1,2,3]
let (top, stack2) = pop stack
let (top2, stack3) = pop stack2
```

Haskell provides the `State` monad, which allows much more natural sequencing of stateful computations:

```haskell
import Control.Monad.State

type Stack = [Int]

-- a function that accepts an int and a stack and returns a new stack with the
-- int on top
push :: Int -> State Stack ()
push x = state $ \xs -> ((), x:xs)

-- a function that accepts a stack and returns the top and a new stack with
-- the item removed
pop :: State Stack Int
pop = state $ \(x:xs) -> (x,xs)

-- stateful computation which pops two elements from a stack and collects them into a list
popTwice :: State Stack [Int]
popTwice = do
    a <- pop
    b <- pop
    return [a,b]
```

(These examples are adapted from Learn You A Haskell's [section on the State monad](http://learnyouahaskell.com/for-a-few-monads-more#state).)


## The State monad in Swift

How might this look in Swift?

```swift
typealias Stack = [Int]

func push(x: Int) -> State<Stack, ()> {
    return State { xs in ((), [x] + xs) }
}

func pop() -> State<Stack, Int> {
    return State { xs in (xs.first!, Array(dropFirst(xs))) }
}

// We don't have the convenience of `do`-notation here, but we can achieve the
// same result using `flatMap` (Haskell's `>>=`).
func popTwice() -> State<Stack, [Int]> {
    return pop().flatMap { a in
           pop().flatMap { b in
             yield([a, b])
           }}
}

// Run `pop()` twice, yielding the second item on the stack. The `then()`
// method chains a statefule computation onto the first.
func popSecond() -> State<Stack, Int> {
    return pop().then(pop)
}

let stack = [1, 2, 3]

// Use `eval()` to access the result of the stateful computation (e.g., the `Int` in `State<Stack, Int>`)
popSecond.eval(stack) // => 2

// Use `exec()` to run the stateful computation and return the mutated state
popTwice.exec(stack) // => [3]

// Use `run()` to get a tuple containing both the result and the final state
let (result, state) = pop().run(stack) // result = 1, state = [2, 3]
```


## What this *could* look like with some [useful operators](https://github.com/sharplet/State/issues/7)

The `|>` operator is an alias for `run()`, and `>>>` is an alias for `then()`.

```swift
let (second, _) = [1,2,3] |> pop >>> pop
// second = 2
```


## Why this is probably not all that useful in practice (or "Just use `var`")

That last example is semantically pretty much identical to this code:

```swift
struct Stack<T> {
    mutating func pop() -> T {
        return elements.removeLast()
    }

    mutating func push(element: T) {
        elements.append(element)
    }

    private var elements: [T]
}

func popTwice(var stack: Stack) -> [Int] {
    let a = stack.pop()
    let b = stack.pop()
    return [a, b]
}
```

So why wouldn't you just use `var`?

Turns out:

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/jspahrsummers">@jspahrsummers</a> &#39;&quot;var&quot; is the state monad&#39;</p>&mdash; Joe Groff (@jckarter) <a href="https://twitter.com/jckarter/status/510582940158291969">September 13, 2014</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

¯\\\_(ツ)\_/¯


## Installation

Using [Carthage](https://github.com/Carthage/Carthage):

  - Add this line to your `Cartfile`:

        github "sharplet/State"

  - Run `carthage update`

  - Add `State.framework` (located in the `Carthage/Build` directory) to your project (see [here](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) for more detailed instructions)
