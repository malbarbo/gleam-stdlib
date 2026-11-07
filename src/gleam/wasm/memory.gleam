//// The linear memory of a program on the WebAssembly target, for the
//// functions of the environment that read and write it, like those of
//// WASI.
////
//// An address and a size are an `Int`. The memory is an arena: `alloc`
//// takes the bytes after the last ones taken, and `scope` gives back what
//// a function took. The functions read and write only the bytes of the
//// arena, and return an error for any other address. An address of a
//// `scope` that ended is valid again as soon as another `alloc` takes its
//// bytes, and then it reads the bytes of the new owner.
////
//// The values are little endian, as in WebAssembly. The ones of 32 bits are
//// unsigned, as in WASI they are addresses and sizes.
////
//// Only the WebAssembly target has these functions.
////
//// ## Examples
////
//// ```gleam
//// use <- memory.scope
//// use address <- result.try(memory.alloc(8))
//// use _ <- result.try(memory.store_u32(address, 42))
//// memory.load_u32(address)
//// // -> Ok(42)
//// ```

import gleam/bit_array
import gleam/wasm.{type I32, type I64}

/// Takes `size` bytes of the arena, aligned to 8, and returns their address.
/// Returns an error if `size` is negative or does not fit in 32 bits, or if
/// the memory does not grow.
///
pub fn alloc(size: Int) -> Result(Int, Nil) {
  case size >= 0 && wasm.unsigned(size) == size {
    False -> Error(Nil)
    True ->
      case unsigned(arena_alloc(wasm.i32_wrap(size))) {
        0 -> Error(Nil)
        address -> Ok(address)
      }
  }
}

/// Runs `f`, and gives back to the arena what was taken while `f` ran.
///
/// A scope inside another works. A panic inside `f` keeps what was taken,
/// until a `failure.catch` around the scope catches it, which gives back
/// what was taken after it started. An `alloc` outside any scope keeps its
/// bytes until the program ends, unless it runs inside a call of a builtin,
/// like a function given to `list.map`, which gives back what the call took.
///
pub fn scope(f: fn() -> a) -> a {
  let mark = arena_mark()
  let result = f()
  let _ = arena_release(mark)
  result
}

/// The unsigned 32 bits integer at `address`. Returns an error if its bytes
/// are not in the arena, or if `Int` has 32 bits and the integer does not
/// fit in them.
///
pub fn load_u32(address: Int) -> Result(Int, Nil) {
  case in_arena(address, 4) {
    False -> Error(Nil)
    True ->
      case unsigned(memory_load_u32(wasm.i32_wrap(address))) {
        n if n < 0 -> Error(Nil)
        n -> Ok(n)
      }
  }
}

/// The 64 bits integer at `address`. Returns an error if its bytes are not
/// in the arena, or if `Int` has 32 bits and the integer does not fit in
/// them.
///
pub fn load_i64(address: Int) -> Result(Int, Nil) {
  case in_arena(address, 8) {
    False -> Error(Nil)
    True -> wasm.i64_to_int(memory_load_i64(wasm.i32_wrap(address)))
  }
}

/// Writes `value` at `address` as an unsigned 32 bits integer. Returns an
/// error if its bytes are not in the arena, or if `value` is not from 0 to
/// 2^32 - 1.
///
pub fn store_u32(address: Int, value: Int) -> Result(Nil, Nil) {
  case in_arena(address, 4) && value >= 0 && wasm.unsigned(value) == value {
    False -> Error(Nil)
    True -> {
      let _ = memory_store_u32(wasm.i32_wrap(address), wasm.i32_wrap(value))
      Ok(Nil)
    }
  }
}

/// Writes `value` at `address` as a 64 bits integer. Returns an error if its
/// bytes are not in the arena.
///
pub fn store_i64(address: Int, value: Int) -> Result(Nil, Nil) {
  case in_arena(address, 8) {
    False -> Error(Nil)
    True -> {
      let _ = memory_store_i64(wasm.i32_wrap(address), wasm.i64_from_int(value))
      Ok(Nil)
    }
  }
}

/// Takes bytes of the arena for the bytes of `bytes`, copies them there, and
/// returns their address and their size. Returns an error if `bytes` is not
/// a whole number of bytes, or if the memory does not grow.
///
/// ## Examples
///
/// ```gleam
/// use <- memory.scope
/// use #(address, size) <- result.try(memory.write(<<"hi":utf8>>))
/// memory.read(address, size)
/// // -> Ok(<<"hi":utf8>>)
/// ```
///
pub fn write(bytes: BitArray) -> Result(#(Int, Int), Nil) {
  let bits = bit_array.bit_size(bytes)
  case bits % 8 {
    0 -> {
      let size = bits / 8
      case alloc(size) {
        Ok(address) -> {
          memory_write_bits(bytes, address)
          Ok(#(address, size))
        }
        Error(Nil) -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

/// The `size` bytes at `address`. Returns an error if `size` is negative or
/// the bytes are not in the arena.
///
pub fn read(address: Int, size: Int) -> Result(BitArray, Nil) {
  case size >= 0 && in_arena(address, size) {
    False -> Error(Nil)
    True -> Ok(memory_read_bits(address, size))
  }
}

/// Returns `True` if the `size` bytes at `address` are in the arena,
/// `False` otherwise.
fn in_arena(address: Int, size: Int) -> Bool {
  address >= unsigned(arena_base()) && address + size <= unsigned(arena_mark())
}

fn unsigned(n: I32) -> Int {
  wasm.unsigned(wasm.i32_to_int(n))
}

@external(webassembly, "builtins", "_arena_base")
fn arena_base() -> I32 {
  panic as "only on the WebAssembly target"
}

@external(webassembly, "builtins", "_arena_mark")
fn arena_mark() -> I32 {
  panic as "only on the WebAssembly target"
}

@external(webassembly, "builtins", "_memory_release")
fn arena_release(_mark: I32) -> I32 {
  panic as "only on the WebAssembly target"
}

@external(webassembly, "builtins", "_arena_alloc")
fn arena_alloc(_size: I32) -> I32 {
  panic as "only on the WebAssembly target"
}

@external(webassembly, "builtins", "_memory_load_u32")
fn memory_load_u32(_address: I32) -> I32 {
  panic as "only on the WebAssembly target"
}

@external(webassembly, "builtins", "_memory_load_i64")
fn memory_load_i64(_address: I32) -> I64 {
  panic as "only on the WebAssembly target"
}

@external(webassembly, "builtins", "_memory_store_u32")
fn memory_store_u32(_address: I32, _value: I32) -> I32 {
  panic as "only on the WebAssembly target"
}

@external(webassembly, "builtins", "_memory_store_i64")
fn memory_store_i64(_address: I32, _value: I64) -> I32 {
  panic as "only on the WebAssembly target"
}

@external(webassembly, "builtins", "memory_write_bits")
fn memory_write_bits(_bytes: BitArray, _address: Int) -> Nil {
  panic as "only on the WebAssembly target"
}

@external(webassembly, "builtins", "memory_read_bits")
fn memory_read_bits(_address: Int, _size: Int) -> BitArray {
  panic as "only on the WebAssembly target"
}
