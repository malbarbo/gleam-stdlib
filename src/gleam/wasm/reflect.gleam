//// One level of a `Dynamic` value on the WebAssembly target: its kind, and
//// the values inside it as `Dynamic`. A library uses it to show a value in
//// its own way, at any depth.
////
//// `view` also opens the records of an opaque type, as `string.inspect`
//// shows them.
////
//// Only the WebAssembly target has these functions.
////
//// ## Examples
////
//// ```gleam
//// let assert reflect.Cons(first:, rest:) =
////   reflect.view(dynamic.list([dynamic.int(1)]))
//// assert reflect.view(first) == reflect.Int(1)
//// assert reflect.view(rest) == reflect.Empty
//// ```

import gleam/dynamic.{type Dynamic}
import gleam/list
import gleam/option.{type Option, None, Some}

/// The kind of a value, with the values inside it.
pub type Value {
  Int(Int)
  Float(Float)
  String(String)
  Bool(Bool)
  Nil
  BitArray(BitArray)
  UtfCodepoint(UtfCodepoint)
  Tuple(List(Dynamic))
  /// The empty list.
  Empty
  /// A list that is not empty, with its first item and the rest.
  Cons(first: Dynamic, rest: Dynamic)
  /// The empty dict.
  EmptyDict
  /// A dict that is not empty, with one of its entries and the dict of the
  /// others. The entries come in the order of their hashes.
  Entry(key: Dynamic, value: Dynamic, rest: Dynamic)
  /// A value of a custom type. `is_opaque` is `True` when the type is
  /// opaque.
  Record(type_: Type, constructor: String, fields: List(Field), is_opaque: Bool)
  Function(arity: Int)
  /// A value of a type without constructors, like a value of the host.
  External(type_: Type)
}

/// A type, by the module that defines it and its name.
pub type Type {
  Type(module: String, name: String)
}

/// A field of a record, with its label, when it has one.
pub type Field {
  Field(label: Option(String), value: Dynamic)
}

/// Opens one level of `value`.
///
pub fn view(value: Dynamic) -> Value {
  dynamic_view(
    value,
    Int,
    Float,
    String,
    Bool,
    Nil,
    BitArray,
    UtfCodepoint,
    Tuple,
    Empty,
    Cons,
    EmptyDict,
    Entry,
    record,
    Function,
    fn(module, name) { External(Type(module, name)) },
  )
}

fn record(
  module: String,
  name: String,
  constructor: String,
  labels: List(String),
  fields: List(Dynamic),
  is_opaque: Bool,
) -> Value {
  let fields =
    list.map2(labels, fields, fn(label, value) {
      case label {
        "" -> Field(None, value)
        _ -> Field(Some(label), value)
      }
    })
  Record(Type(module, name), constructor, fields, is_opaque)
}

@external(webassembly, "builtins", "dynamic_view")
fn dynamic_view(
  _data: Dynamic,
  _int: fn(Int) -> v,
  _float: fn(Float) -> v,
  _string: fn(String) -> v,
  _bool: fn(Bool) -> v,
  _nil: v,
  _bit_array: fn(BitArray) -> v,
  _utf_codepoint: fn(UtfCodepoint) -> v,
  _tuple: fn(List(Dynamic)) -> v,
  _empty: v,
  _cons: fn(Dynamic, Dynamic) -> v,
  _empty_dict: v,
  _entry: fn(Dynamic, Dynamic, Dynamic) -> v,
  _record: fn(String, String, String, List(String), List(Dynamic), Bool) -> v,
  _function: fn(Int) -> v,
  _external: fn(String, String) -> v,
) -> v {
  panic as "only on the WebAssembly target"
}
