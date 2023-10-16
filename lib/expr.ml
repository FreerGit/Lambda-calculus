type t =
  | Int of int
  | Variable of string
  | Abstraction of
      { param : string
      ; param_t : Type.t
      ; body : t
      }
  | Application of
      { func : t
      ; argument : t
      }
