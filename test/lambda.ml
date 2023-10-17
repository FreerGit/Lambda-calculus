open Lib
module Context = Map.Make (String)

(* Basic Expr *)
let%expect_test _ =
  let x = Expr.Abstraction { param = "x"; param_t = TInt; body = Variable "x" } in
  let x_type = Infer.infer Context.empty x in
  Format.printf "%a\n%!" Type.pp x_type;
  [%expect {| TArrow {param_t = TInt; body_t = TInt} |}]
;;

let%expect_test _ =
  let x = Expr.Abstraction { param = "x"; param_t = TInt; body = Variable "x" } in
  let a = Expr.Application { func = x; argument = Int 1 } in
  let a_t = Infer.infer Context.empty a in
  Format.printf "%a\n%!" Type.pp a_t;
  [%expect {| TInt |}]
;;

(* Parsing, both Expr and Type *)
let parse_expr = Lexer.from_string Parser.expr_opt
let print_expr code = parse_expr code |> Option.get |> Format.printf "%a\n%!" Expr.pp

let print_type code =
  parse_expr code
  |> Option.get
  |> Infer.infer Context.empty
  |> Format.printf "%a\n%!" Type.pp
;;

let%expect_test _ =
  print_expr "abc";
  [%expect {| (Variable "abc") |}]
;;

let%expect_test _ =
  print_expr "f abc";
  [%expect {| Application {func = (Variable "f"); argument = (Variable "abc")} |}]
;;

let%expect_test _ =
  print_expr "(λx:int.x)";
  print_expr "λx:int.x";
  [%expect
    {|
Abstraction {param = "x"; param_t = TInt; body = (Variable "x")}
Abstraction {param = "x"; param_t = TInt; body = (Variable "x")} |}]
;;

let%expect_test _ =
  print_expr "(λx:int.x) (λx:int.x)";
  [%expect
    {|
    Application {
      func = Abstraction {param = "x"; param_t = TInt; body = (Variable "x")};
      argument = Abstraction {param = "x"; param_t = TInt; body = (Variable "x")}} |}]
;;

let%expect_test _ =
  print_type "(λx:int.x)";
  print_type "λx:int.x";
  print_type "(λx:int.x) 1";
  [%expect
    {|
TArrow {param_t = TInt; body_t = TInt}
TArrow {param_t = TInt; body_t = TInt}
TInt |}]
;;

let%expect_test _ =
  print_type "(λx:int -> int.x)";
  [%expect
    {|
TArrow {param_t = TArrow {param_t = TInt; body_t = TInt};
  body_t = TArrow {param_t = TInt; body_t = TInt}} |}]
;;
