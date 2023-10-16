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
     | VInt _ | VForall _ -> raise Type_error)
  | Type_abstraction { param = _; body } -> VForall { context; body }
  | Type_application { func; argument = _ } ->
    (match interpret context func with
     | VForall { context; body } -> interpret context body
     | VInt _ | VClosure _ | VNative _ -> raise Type_error)
;;
