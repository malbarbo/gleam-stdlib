//// The numbers of WebAssembly, for the functions of the environment, which
//// a program on the WebAssembly target declares with a module of a plain
//// name, like `@external(webassembly, "wasi_snapshot_preview1", "proc_exit")`,
//// and which take and return them as they are.
////
//// The operations of `I32` and `I64` wrap at 32 and 64 bits, whatever the
//// width of `Int` and the `int_overflow` of the project are, as a hash or a
//// random number generator needs.
////
//// Only the WebAssembly target has these functions.

import gleam/int

/// A 32 bits integer of WebAssembly, an `i32`.
pub type I32

/// A 64 bits integer of WebAssembly, an `i64`.
pub type I64

/// A 32 bits float of WebAssembly, an `f32`.
pub type F32

/// A 64 bits float of WebAssembly, an `f64`.
pub type F64

/// The `I32` of `n`, read as signed or unsigned, so from -2^31 to 2^32 - 1.
/// Returns an error if `n` is out of this range.
///
/// ## Examples
///
/// ```gleam
/// assert wasm.i32_from_int(-1) |> result.map(wasm.i32_to_int) == Ok(-1)
/// ```
///
pub fn i32_from_int(n: Int) -> Result(I32, Nil) {
  let i = i32_wrap(n)
  let signed = i32_to_int(i)
  case signed == n || unsigned(signed) == n {
    True -> Ok(i)
    False -> Error(Nil)
  }
}

/// The `I32` of the low 32 bits of `n`, like the `i32.wrap_i64` of
/// WebAssembly.
///
/// ## Examples
///
/// ```gleam
/// assert wasm.i32_to_int(wasm.i32_wrap(-1)) == -1
/// ```
///
@external(webassembly, "builtins", "_int_to_i32")
pub fn i32_wrap(_n: Int) -> I32 {
  panic as "only on the WebAssembly target"
}

/// The `Int` of `n`, read as signed.
///
@external(webassembly, "builtins", "_i32_to_int")
pub fn i32_to_int(_n: I32) -> Int {
  panic as "only on the WebAssembly target"
}

/// The `I64` of `n`.
///
@external(webassembly, "builtins", "_int_to_i64")
pub fn i64_from_int(_n: Int) -> I64 {
  panic as "only on the WebAssembly target"
}

/// The `Int` of `n`. Returns an error if `Int` has 32 bits and `n` does not
/// fit in them.
///
pub fn i64_to_int(n: I64) -> Result(Int, Nil) {
  let i = i64_wrap(n)
  case i64_from_int(i) == n {
    True -> Ok(i)
    False -> Error(Nil)
  }
}

/// The `F32` of `x`, rounded when `Float` has 64 bits.
///
@external(webassembly, "builtins", "_float_to_f32")
pub fn f32_from_float(_x: Float) -> F32 {
  panic as "only on the WebAssembly target"
}

/// The `Float` of `x`.
///
@external(webassembly, "builtins", "_f32_to_float")
pub fn f32_to_float(_x: F32) -> Float {
  panic as "only on the WebAssembly target"
}

/// The `F64` of `x`.
///
@external(webassembly, "builtins", "_float_to_f64")
pub fn f64_from_float(_x: Float) -> F64 {
  panic as "only on the WebAssembly target"
}

/// The `Float` of `x`, rounded when `Float` has 32 bits.
///
@external(webassembly, "builtins", "_f64_to_float")
pub fn f64_to_float(_x: F64) -> Float {
  panic as "only on the WebAssembly target"
}

/// Adds `a` and `b`, modulo 2^32.
///
/// ## Examples
///
/// ```gleam
/// let max = wasm.i32_wrap(2_147_483_647)
/// assert wasm.i32_to_int(wasm.i32_add(max, wasm.i32_wrap(1))) == -2_147_483_648
/// ```
///
@external(webassembly, "builtins", "_i32_add")
pub fn i32_add(_a: I32, _b: I32) -> I32 {
  panic as "only on the WebAssembly target"
}

/// Subtracts `b` from `a`, modulo 2^32.
///
@external(webassembly, "builtins", "_i32_sub")
pub fn i32_sub(_a: I32, _b: I32) -> I32 {
  panic as "only on the WebAssembly target"
}

/// Multiplies `a` and `b`, modulo 2^32.
///
@external(webassembly, "builtins", "_i32_mul")
pub fn i32_mul(_a: I32, _b: I32) -> I32 {
  panic as "only on the WebAssembly target"
}

/// The bitwise and of `a` and `b`.
///
@external(webassembly, "builtins", "_i32_and")
pub fn i32_and(_a: I32, _b: I32) -> I32 {
  panic as "only on the WebAssembly target"
}

/// The bitwise or of `a` and `b`.
///
@external(webassembly, "builtins", "_i32_or")
pub fn i32_or(_a: I32, _b: I32) -> I32 {
  panic as "only on the WebAssembly target"
}

/// The bitwise exclusive or of `a` and `b`.
///
@external(webassembly, "builtins", "_i32_xor")
pub fn i32_xor(_a: I32, _b: I32) -> I32 {
  panic as "only on the WebAssembly target"
}

/// Shifts `a` left by `bits` modulo 32.
///
@external(webassembly, "builtins", "_i32_shift_left")
pub fn i32_shift_left(_a: I32, _bits: Int) -> I32 {
  panic as "only on the WebAssembly target"
}

/// Shifts `a` right by `bits` modulo 32, keeping its sign.
///
@external(webassembly, "builtins", "_i32_shift_right")
pub fn i32_shift_right(_a: I32, _bits: Int) -> I32 {
  panic as "only on the WebAssembly target"
}

/// Shifts `a` right by `bits` modulo 32, filling with zeros.
///
@external(webassembly, "builtins", "_i32_shift_right_unsigned")
pub fn i32_shift_right_unsigned(_a: I32, _bits: Int) -> I32 {
  panic as "only on the WebAssembly target"
}

/// Adds `a` and `b`, modulo 2^64.
///
@external(webassembly, "builtins", "_i64_add")
pub fn i64_add(_a: I64, _b: I64) -> I64 {
  panic as "only on the WebAssembly target"
}

/// Subtracts `b` from `a`, modulo 2^64.
///
@external(webassembly, "builtins", "_i64_sub")
pub fn i64_sub(_a: I64, _b: I64) -> I64 {
  panic as "only on the WebAssembly target"
}

/// Multiplies `a` and `b`, modulo 2^64.
///
@external(webassembly, "builtins", "_i64_mul")
pub fn i64_mul(_a: I64, _b: I64) -> I64 {
  panic as "only on the WebAssembly target"
}

/// The bitwise and of `a` and `b`.
///
@external(webassembly, "builtins", "_i64_and")
pub fn i64_and(_a: I64, _b: I64) -> I64 {
  panic as "only on the WebAssembly target"
}

/// The bitwise or of `a` and `b`.
///
@external(webassembly, "builtins", "_i64_or")
pub fn i64_or(_a: I64, _b: I64) -> I64 {
  panic as "only on the WebAssembly target"
}

/// The bitwise exclusive or of `a` and `b`.
///
@external(webassembly, "builtins", "_i64_xor")
pub fn i64_xor(_a: I64, _b: I64) -> I64 {
  panic as "only on the WebAssembly target"
}

/// Shifts `a` left by `bits` modulo 64.
///
@external(webassembly, "builtins", "_i64_shift_left")
pub fn i64_shift_left(_a: I64, _bits: Int) -> I64 {
  panic as "only on the WebAssembly target"
}

/// Shifts `a` right by `bits` modulo 64, keeping its sign.
///
@external(webassembly, "builtins", "_i64_shift_right")
pub fn i64_shift_right(_a: I64, _bits: Int) -> I64 {
  panic as "only on the WebAssembly target"
}

/// Shifts `a` right by `bits` modulo 64, filling with zeros.
///
@external(webassembly, "builtins", "_i64_shift_right_unsigned")
pub fn i64_shift_right_unsigned(_a: I64, _bits: Int) -> I64 {
  panic as "only on the WebAssembly target"
}

@external(webassembly, "builtins", "_i64_to_int")
fn i64_wrap(_n: I64) -> Int {
  panic as "only on the WebAssembly target"
}

/// The unsigned value of the 32 bits of `signed`. With an `Int` of 32 bits,
/// whose shift by 32 is 0, it is `signed` itself.
@internal
pub fn unsigned(signed: Int) -> Int {
  int.bitwise_and(signed, int.bitwise_shift_left(1, 32) - 1)
}
