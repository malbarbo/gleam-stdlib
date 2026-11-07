//// The failures of a program on the WebAssembly target: a `panic`, a
//// `todo`, a `let assert` that does not match and a false `assert`.
////
//// A failure only raises an exception that `catch` catches when the root
//// package has `failure = "exception"` in the `[webassembly]` section of
//// its `gleam.toml`. Without it, the program does not compile when it
//// calls `catch`. A failure that nothing catches is printed, and the
//// program exits with 1.
////
//// Only the WebAssembly target has these functions.
////
//// ## Examples
////
//// ```gleam
//// let assert Error(failure) = failure.catch(fn() { panic as "boom" })
//// assert failure.message == Some("boom")
//// ```

import gleam/dynamic.{type Dynamic}
import gleam/int
import gleam/option.{type Option, None, Some}

/// A failure, at the expression that raised it. `file` is the path of the
/// module from the root of its package, like `src/app.gleam`. `function` is
/// the function at the top level of the module that has the expression,
/// also when the expression is in an anonymous function. `line` is the line
/// where the expression starts, and `message` is the message after `as`, or
/// `None` when the program gave none.
pub type Failure {
  Failure(
    kind: Kind,
    file: String,
    module: String,
    function: String,
    line: Int,
    message: Option(String),
  )
}

/// The expression that raised a failure.
pub type Kind {
  Panic
  Todo
  LetAssert
  Assert
}

/// The message of the JavaScript target for a failure without one.
///
/// ## Examples
///
/// ```gleam
/// assert failure.default_message(failure.Assert) == "Assertion failed."
/// ```
///
pub fn default_message(kind: Kind) -> String {
  case kind {
    Panic -> "`panic` expression evaluated."
    Todo ->
      "`todo` expression evaluated. This code has not yet been implemented."
    LetAssert -> "Pattern match failed, no pattern matched the value."
    Assert -> "Assertion failed."
  }
}

/// Calls `run`, and returns its result, or the failure that it raised. The
/// memory that `gleam/wasm/memory` took while `run` ran goes back to where
/// it was when `catch` started, when `run` fails.
///
/// A failure inside a `catch` that is inside another goes to the innermost
/// one.
///
pub fn catch(run: fn() -> a) -> Result(a, Failure) {
  catch_with(
    run,
    Ok,
    fn(kind, file, module, function, line, message, has_message, _) {
      let assert Ok(line) = int.parse(line) as "the line of a failure"
      let message = case has_message {
        True -> Some(message)
        False -> None
      }
      Error(Failure(
        kind: kind_of(kind),
        file:,
        module:,
        function:,
        line:,
        message:,
      ))
    },
  )
}

fn kind_of(name: String) -> Kind {
  case name {
    "panic" -> Panic
    "todo" -> Todo
    "let_assert" -> LetAssert
    _ -> Assert
  }
}

@external(webassembly, "builtins", "_catch")
fn catch_with(
  _run: fn() -> a,
  _ok: fn(a) -> b,
  _error: fn(String, String, String, String, String, String, Bool, Dynamic) -> b,
) -> b {
  panic as "only on the WebAssembly target"
}
