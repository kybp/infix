# infix

This is yet another Lisp macro for algebraic arithmetic notation. It uses the
shunting yard algorithm for handling operator precedence and provides the macro
`INFIX`, which lets you write things like `(infix 2 * 3 + 4 * 5)` and get `26`.
The function `INSTALL-SYNTAX` can be called to define read macros for `#\[` and
`#\]` so that the previous example could instead be written `[2 * 3 + 4 * 5]`.

Parenthesized forms are left unchanged as single values in the expansion, so
arbitrary Lisp forms can be included. Note in particular that this includes
recursive calls to `INFIX` (or through the `[...]` syntax if it is installed),
serving the purpose of parentheses in algebraic notation for explicit precedence
grouping.

Putting it all together:

    CL-USER> (flet ((triple (x) (* x 3)))
               (infix 3 / [1 + (triple 2) * #C(0 1) ^ 2 - [1 + 2]]))
    -3/8

The supported operators are `and`, `or`, `=`, `<`, `>`, `<=`, `>=`, `+`, `-`,
`*`, `/`, and `^`/`**`/`expt`, in that order of precedence.

## Limitations

- `NIL` cannot be included in an infix expression as a literal
- Unary `-` is not supported, but can be easily simulated with `(- x)`
