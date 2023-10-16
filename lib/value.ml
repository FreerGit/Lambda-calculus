module Context = Map.Make (String)

type t =
  | VInt of int
  | VClosure of
      { context : t Context.t
      ; param : string
      ; body : Expr.t
      }
  | VNative of (t -> t)
  | VForall of
      { context : t Context.t
      ; body : Expr.t
      }

let pp fmt t =
  match t with
  | VInt n -> Format.fprintf fmt "VInt %d" n
  | VClosure _ -> Format.fprintf fmt "VClosure"
  | VNative _ -> Format.fprintf fmt "VNative"
  | VForall _ -> Format.fprintf fmt "VForall"
;;
