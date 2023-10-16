open Value
open Expr
module Context = Map.Make (String)

exception Type_error

let rec interpret context expr =
  match expr with
  | Int n -> VInt n
  | Variable name -> Context.find name context
  | Abstraction { param; param_t = _; body } -> VClosure { context; param; body }
  | Application { func; argument } ->
    let arg = interpret context argument in
    (match interpret context func with
     | VClosure { context; param; body } -> interpret (Context.add param arg context) body
     | VNative f -> f arg
     | VInt _ -> raise Type_error)
;;
