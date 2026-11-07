//// The global state of a program on the WebAssembly target: a value for
//// each key, which any function can set and get. A library uses it for what
//// it cannot pass as an argument, like the count of the tests that passed.
////
//// A value that a function sets inside `failure.catch` stays when the
//// function fails.
////
//// Only the WebAssembly target has these functions.
////
//// ## Examples
////
//// ```gleam
//// global.set("my_package/count", dynamic.int(1))
//// assert global.get("my_package/count") == Ok(dynamic.int(1))
//// ```

import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}

/// Sets the value of `key`. A package names its keys after itself, like
/// `"my_package/count"`, so that they are not the keys of another package.
///
pub fn set(key: String, value: Dynamic) -> Nil {
  values()
  |> dict.insert(dynamic.string(key), value)
  |> from_dict
  |> global_set
}

/// Returns the value of `key`, or `Error(Nil)` before the first `set` of
/// `key`.
///
pub fn get(key: String) -> Result(Dynamic, Nil) {
  dict.get(values(), dynamic.string(key))
}

fn values() -> Dict(Dynamic, Dynamic) {
  case to_dict(global_get()) {
    Ok(values) -> values
    // The global is `Nil` before the first `set`.
    Error(Nil) -> dict.new()
  }
}

@external(webassembly, "builtins", "_global_get")
fn global_get() -> Dynamic {
  panic as "only on the WebAssembly target"
}

@external(webassembly, "builtins", "_global_set")
fn global_set(_value: Dynamic) -> Nil {
  panic as "only on the WebAssembly target"
}

@external(webassembly, "builtins", "dynamic_dict")
fn from_dict(_values: Dict(Dynamic, Dynamic)) -> Dynamic {
  panic as "only on the WebAssembly target"
}

@external(webassembly, "builtins", "dynamic_decode_dict")
fn to_dict(_data: Dynamic) -> Result(Dict(Dynamic, Dynamic), Nil) {
  panic as "only on the WebAssembly target"
}
