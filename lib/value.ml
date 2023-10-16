module Context = Map.Make (String)

type t =
  | VInt of int
  | VClosure of
      { context : t Context.t
      ; param : string
      ; body : Expr.t
      }
  | VNative of (t -> t)
