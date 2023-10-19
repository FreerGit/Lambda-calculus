open Lib
module Context = Map.Make (String)

(* Basic Expr *)
let%expect_test _ =
  let x = Expr.Abstraction { param = "x"; param_t = TInt; body = Variable "x" } in
  let x_type = Infer.infer Context.empty x in
  Format.printf "%a\n%!" Type.pp x_type;
  [%expect {| int -> int |}]
;;

let%expect_test _ =
  let x = Expr.Abstraction { param = "x"; param_t = TInt; body = Variable "x" } in
  let a = Expr.Application { func = x; argument = Int 1 } in
  let a_t = Infer.infer Context.empty a in
  Format.printf "%a\n%!" Type.pp a_t;
  [%expect {| int |}]
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
  print_expr "(λx:int.x) 1";
  [%expect {| Application {func = (Variable "f"); argument = (Variable "abc")} |}]
;;

let%expect_test _ =
  print_expr "((λx:int.λy:int.x)y)z";
  [%expect {| Application {func = (Variable "f"); argument = (Variable "abc")} |}]
;;

let%expect_test _ =
  print_expr "(λx:int.x)";
  print_expr "λx:int.x";
  [%expect
    {|
Abstraction {param = "x"; param_t = int; body = (Variable "x")}
Abstraction {param = "x"; param_t = int; body = (Variable "x")} |}]
;;

let%expect_test _ =
  print_expr "(λx:int.x) (λx:int.x)";
  [%expect
    {|
    Application {
      func = Abstraction {param = "x"; param_t = int; body = (Variable "x")};
      argument = Abstraction {param = "x"; param_t = int; body = (Variable "x")}} |}]
;;

let%expect_test _ =
  print_type "(λx:int.x)";
  print_type "λx:int.x";
  print_type "(λx:int.x) 1";
  [%expect {|
int -> int
int -> int
int |}]
;;

let%expect_test _ =
  print_type "(λx:int -> int.x)";
  [%expect {|
(int -> int) -> int -> int |}]
;;

(* Polymorphism *)

let%expect_test _ =
  print_type "(λx:a -> a.x)";
  [%expect {|
(a -> a) -> a -> a |}]
;;

let%expect_test _ =
  print_type "(λx:T -> T.x)";
  [%expect {|
    (T -> T) -> T -> T |}]
;;

let%expect_test _ =
  print_type "(λx:POLY_TYPE -> POLY_TYPE.x)";
  [%expect {|
    (POLY_TYPE -> POLY_TYPE) -> POLY_TYPE -> POLY_TYPE |}]
;;

let%expect_test _ =
  print_type "(λid:∀x.x -> x.id)";
  [%expect {|
    ∀x.x -> x -> ∀x.x -> x |}]
;;

(* Narrowing the type! o.o *)

let%expect_test _ =
  print_type "(λid:∀x.x -> x.id [int])";
  [%expect {|
    ∀x.x -> x -> int -> int |}]
;;

let%expect_test _ =
  print_type "(Λa.λx:a -> a.x) [int]";
  [%expect {|
    (int -> int) -> int -> int |}]
;;
