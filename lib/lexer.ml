open Sedlexing
open Parser

exception Invalid_token

let whitespace = [%sedlex.regexp? Plus (' ' | '\n' | '\t')]
let alpha = [%sedlex.regexp? 'a' .. 'z']
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
  | '(' -> LPARENS
  | ')' -> RPARENS
  | any -> if Utf8.lexeme buf = "λ" then LAMBDA else raise Invalid_token
  | eof -> EOF
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
