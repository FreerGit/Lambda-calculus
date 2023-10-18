open Sedlexing
open Parser

exception Invalid_token

let whitespace = [%sedlex.regexp? Plus (' ' | '\n' | '\t')]
let alpha = [%sedlex.regexp? Plus ('a' .. 'z' | 'A' .. 'Z')]
let number = [%sedlex.regexp? '0' .. '9']

(* let lambda = [%sedlex.regexp? 'λ'] *)
let ident = [%sedlex.regexp? alpha, Star (alpha | number | '_')]
let int = [%sedlex.regexp? Plus number]

let rec tokenizer buf =
  match%sedlex buf with
  | whitespace -> tokenizer buf
  | ident -> IDENT (Utf8.lexeme buf)
  | int -> INT (Utf8.lexeme buf |> int_of_string)
  | ':' -> COLON
  | '.' -> DOT
  | "->" -> ARROW
  | '[' -> LBRACKET
  | ']' -> RBRACKET
  | '(' -> LPARENS
  | ')' -> RPARENS
  | eof -> EOF
  | any ->
    let char = Utf8.lexeme buf in
    if char = "λ"
    then LAMBDA
    else if char = "Λ"
    then ULAMBDA
    else if char = "∀"
    then FORALL
    else raise Invalid_token
  | _ -> raise Invalid_token
;;

let provider buf () =
  let token = tokenizer buf in
  let start, stop = Sedlexing.lexing_positions buf in
  token, start, stop
;;

let from_string f str =
  provider (Utf8.from_string str) |> MenhirLib.Convert.Simplified.traditional2revised f
;;
