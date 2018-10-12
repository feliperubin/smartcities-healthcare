# Swift



## Variables

var ``variable name``: ``type``= ``expression``

```swift
var variable_example: Bool = false //Can change vallue
let x: Int = 32 //Always this value

// Cannot be nil
var x: Int = 1

// The type here is not "Int", it's "Optional Int"
var y: Int? = 2

// The type here is "Implicitly Unwrapped Optional Int"
var z: Int! = 3

```

## Functions

```swift
func factorial(n: Int) -> Int {
    if n == 1 return n
    else return n * factorial(n-1)
}
```









