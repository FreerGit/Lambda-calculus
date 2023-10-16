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
  | Type_abstraction of
      { param : string
      ; body : t
      }
  | Type_application of
      { func : t
      ; argument : Type.t
      }
[@@deriving show { with_path = false }]
