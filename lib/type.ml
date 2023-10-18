type t =
  | TInt
  | TVar of string
  | TArrow of
      { param_t : t
      ; body_t : t
      }
  | TForall of
      { param : string
      ; return_t : t
      }

let rec pp fmt t =
  let open Format in
  match t with
  | TInt -> fprintf fmt "int"
  | TVar str -> fprintf fmt "%s" str
  | TArrow { param_t = TArrow _ as param_t; body_t } ->
    fprintf fmt "(%a) -> %a" pp param_t pp body_t
  | TArrow { param_t; body_t } -> fprintf fmt "%a -> %a" pp param_t pp body_t
  | TForall { param; return_t } -> fprintf fmt "∀%s.%a" param pp return_t
;;

let rec equal a b =
  match a, b with
  | TInt, TInt -> true
  | TArrow { param_t = pa; body_t = ba }, TArrow { param_t = pb; body_t = bb } ->
    equal pa ba && equal pb bb
  | _ -> false
;;

let rec type_subst t ~a ~b =
  match t with
  | TArrow { param_t; body_t } ->
    TArrow { param_t = type_subst param_t ~a ~b; body_t = type_subst body_t ~a ~b }
  | TInt -> TInt
  | TVar name when name = a -> b
  | TVar name -> TVar name
  | TForall { param; return_t } when param = a -> TForall { param; return_t }
  | TForall { param; return_t } -> TForall { param; return_t = type_subst return_t ~a ~b }
;;
