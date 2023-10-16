open Lib
module Context = Map.Make (String)

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
