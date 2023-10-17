module Context = Map.Make (String)
open Lib

let parse_expr = Lexer.from_string Parser.expr_opt

(* let parse_typ = Lexer.from_string Parser.typ_opt *)
let _ = parse_expr "abc" |> Option.get |> Format.printf "%a\n%!" Expr.pp
