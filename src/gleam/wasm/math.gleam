//// Functions of `Float` that the other targets take from the C library or
//// from `Math`. A package calls them in the body that the WebAssembly target
//// uses in place of an external.
////
//// Only the WebAssembly target has these functions.
////
//// ## Examples
////
//// ```gleam
//// import gleam/wasm/math
////
//// @external(javascript, "./my_ffi.mjs", "sin")
//// pub fn sin(x: Float) -> Float {
////   math.sin(x)
//// }
//// ```

/// Returns the square root of `x`, which must not be negative.
///
@external(webassembly, "builtins", "float_sqrt")
pub fn sqrt(x: Float) -> Float

/// Returns the sine of `x`, in radians.
///
@external(webassembly, "builtins", "float_sin")
pub fn sin(x: Float) -> Float

/// Returns the cosine of `x`, in radians.
///
@external(webassembly, "builtins", "float_cos")
pub fn cos(x: Float) -> Float

/// Returns the angle of the point `(x, y)`, in radians between -pi and pi.
///
@external(webassembly, "builtins", "float_atan2")
pub fn atan2(y: Float, x: Float) -> Float

/// Returns the square root of `a * a + b * b`, without overflow when `a * a`
/// does not fit in a `Float`.
///
@external(webassembly, "builtins", "float_hypot")
pub fn hypot(a: Float, b: Float) -> Float
