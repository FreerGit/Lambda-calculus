open Type
open Expr
module Context = Map.Make (String)

let rec infer context expr =
  match expr with
  | Int _ -> TInt
  | Variable name ->
    (match Context.find_opt name context with
     | Some t -> t
     | None -> raise Interp.Type_error)
  | Abstraction { param; param_t; body } ->
    let context = Context.add param param_t context in
    let body_t = infer context body in
    TArrow { param_t; body_t }
  | Application { func; argument } ->
    let func_t = infer context func in
    let argument_t = infer context argument in
    (match func_t with
     | TInt -> raise Interp.Type_error
     | TArrow { param_t; body_t } when Type.equal param_t argument_t -> body_t
     | _ -> raise Interp.Type_error)
;;
