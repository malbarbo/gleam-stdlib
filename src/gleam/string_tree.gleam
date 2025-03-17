import gleam/list

/// `StringTree` is a type used for efficiently building text content to be
/// written to a file or a socket. Internally it is represented as tree so to
/// append or prepend to a string tree is a constant time operation that
/// allocates a new node in the tree without copying any of the content. When
/// writing to an output stream the tree is traversed and the content is sent
/// directly rather than copying it into a single buffer beforehand.
///
/// On Erlang this type is compatible with Erlang's iodata. On JavaScript this
/// type is compatible with normal strings.
///
/// The BEAM virtual machine has an optimisation for appending strings, where it
/// will mutate the string buffer when safe to do so, so if you are looking to
/// build a string through appending many small strings then you may get better
/// performance by not using a string tree. Always benchmark your performance
/// sensitive code.
///
pub type StringTree

/// Create an empty `StringTree`. Useful as the start of a pipe chaining many
/// trees together.
///
pub fn new() -> StringTree {
  from_strings([])
}

/// Prepends a `String` onto the start of some `StringTree`.
///
/// Runs in constant time.
///
pub fn prepend(to tree: StringTree, prefix prefix: String) -> StringTree {
  append_tree(from_string(prefix), tree)
}

/// Appends a `String` onto the end of some `StringTree`.
///
/// Runs in constant time.
///
pub fn append(to tree: StringTree, suffix second: String) -> StringTree {
  append_tree(tree, from_string(second))
}

/// Prepends some `StringTree` onto the start of another.
///
/// Runs in constant time.
///
pub fn prepend_tree(
  to tree: StringTree,
  prefix prefix: StringTree,
) -> StringTree {
  append_tree(prefix, tree)
}

/// Appends some `StringTree` onto the end of another.
///
/// Runs in constant time.
///
@external(erlang, "gleam_stdlib", "iodata_append")
pub fn append_tree(to tree: StringTree, suffix suffix: StringTree) -> StringTree {
  add(tree, suffix)
}

@external(javascript, "../gleam_stdlib.mjs", "add")
fn add(to tree: StringTree, suffix suffix: StringTree) -> StringTree

/// Converts a list of strings into a `StringTree`.
///
/// Runs in constant time.
///
@external(erlang, "gleam_stdlib", "identity")
pub fn from_strings(strings: List(String)) -> StringTree {
  string_tree_from_strings(strings)
}

@external(javascript, "../gleam_stdlib.mjs", "string_tree_concat")
fn string_tree_from_strings(trees: List(String)) -> StringTree

/// Joins a list of trees into a single tree.
///
/// Runs in constant time.
///
@external(erlang, "gleam_stdlib", "identity")
pub fn concat(trees: List(StringTree)) -> StringTree {
  string_tree_concat(trees)
}

@external(javascript, "../gleam_stdlib.mjs", "string_tree_concat")
fn string_tree_concat(trees: List(StringTree)) -> StringTree

/// Converts a string into a `StringTree`.
///
/// Runs in constant time.
///
@external(erlang, "gleam_stdlib", "identity")
pub fn from_string(string: String) -> StringTree {
  javascript_from_string(string)
}

@external(javascript, "../gleam_stdlib.mjs", "identity")
fn javascript_from_string(string: String) -> StringTree

/// Turns a `StringTree` into a `String`
///
/// This function is implemented natively by the virtual machine and is highly
/// optimised.
///
@external(erlang, "unicode", "characters_to_binary")
pub fn to_string(tree: StringTree) -> String {
  javascript_to_string(tree)
}

@external(javascript, "../gleam_stdlib.mjs", "identity")
fn javascript_to_string(tree: StringTree) -> String

/// Returns the size of the `StringTree` in bytes.
///
@external(erlang, "erlang", "iolist_size")
pub fn byte_size(tree: StringTree) -> Int {
  length(tree)
}

@external(javascript, "../gleam_stdlib.mjs", "length")
fn length(tree: StringTree) -> Int

/// Joins the given trees into a new tree separated with the given string.
///
pub fn join(trees: List(StringTree), with sep: String) -> StringTree {
  trees
  |> list.intersperse(from_string(sep))
  |> concat
}

/// Converts a `StringTree` to a new one where the contents have been
/// lowercased.
///
@external(erlang, "string", "lowercase")
pub fn lowercase(tree: StringTree) -> StringTree {
  string_lowercase(tree)
}

@external(javascript, "../gleam_stdlib.mjs", "string_lowercase")
fn string_lowercase(tree: StringTree) -> StringTree

/// Converts a `StringTree` to a new one where the contents have been
/// uppercased.
///
@external(erlang, "string", "uppercase")
pub fn uppercase(tree: StringTree) -> StringTree {
  string_uppercase(tree)
}

@external(javascript, "../gleam_stdlib.mjs", "string_uppercase")
fn string_uppercase(tree: StringTree) -> StringTree

/// Converts a `StringTree` to a new one with the contents reversed.
///
@external(erlang, "string", "reverse")
pub fn reverse(tree: StringTree) -> StringTree {
  tree
  |> to_string
  |> do_to_graphemes
  |> list.reverse
  |> from_strings
}

@external(javascript, "../gleam_stdlib.mjs", "graphemes")
fn do_to_graphemes(string: String) -> List(String)

type Direction {
  All
}

/// Splits a `StringTree` on a given pattern into a list of trees.
///
pub fn split(tree: StringTree, on pattern: String) -> List(StringTree) {
  do_split(tree, pattern)
}

@external(javascript, "../gleam_stdlib.mjs", "split")
fn do_split(tree: StringTree, on pattern: String) -> List(StringTree) {
  erl_split(tree, pattern, All)
}

@external(erlang, "string", "split")
fn erl_split(a: StringTree, b: String, c: Direction) -> List(StringTree)

/// Replaces all instances of a pattern with a given string substitute.
///
@external(erlang, "gleam_stdlib", "string_replace")
pub fn replace(
  in tree: StringTree,
  each pattern: String,
  with substitute: String,
) -> StringTree {
  string_replace(tree, pattern, substitute)
}

@external(javascript, "../gleam_stdlib.mjs", "string_replace")
fn string_replace(
  in tree: StringTree,
  each pattern: String,
  with substitute: String,
) -> StringTree

/// Compares two string trees to determine if they have the same textual
/// content.
///
/// Comparing two string trees using the `==` operator may return `False` even
/// if they have the same content as they may have been build in different ways,
/// so using this function is often preferred.
///
/// ## Examples
///
/// ```gleam
/// from_strings(["a", "b"]) == from_string("ab")
/// // -> False
/// ```
///
/// ```gleam
/// is_equal(from_strings(["a", "b"]), from_string("ab"))
/// // -> True
/// ```
///
@external(erlang, "string", "equal")
pub fn is_equal(a: StringTree, b: StringTree) -> Bool {
  a == b
}

/// Inspects a `StringTree` to determine if it is equivalent to an empty string.
///
/// ## Examples
///
/// ```gleam
/// from_string("ok") |> is_empty
/// // -> False
/// ```
///
/// ```gleam
/// from_string("") |> is_empty
/// // -> True
/// ```
///
/// ```gleam
/// from_strings([]) |> is_empty
/// // -> True
/// ```
///
@external(erlang, "string", "is_empty")
pub fn is_empty(tree: StringTree) -> Bool {
  from_string("") == tree
}
