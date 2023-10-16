type t =
  | TArrow of
      { param_t : t
      ; body_t : t
      }
  | TInt

let rec equal a b =
  match a, b with
  | TInt, TInt -> true
  | TArrow { param_t = pa; body_t = ba }, TArrow { param_t = pb; body_t = bb } ->
    equal pa ba && equal pb bb
  | _ -> false
;;
