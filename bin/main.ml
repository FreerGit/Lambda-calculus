module Context = Map.Make (String)

type expr =
  | Variable of string
  | Abstraction of
      { param : string
      ; body : expr
      }
  | Application of
      { func : expr
      ; argument : expr
      }

type value =
  | Closure of
      { context : value Context.t
      ; param : string
      ; body : expr
      }
  | Native of (value -> value)

let rec interpret context expr =
  match expr with
  | Variable name -> Context.find name context
  | Abstraction { param; body } -> Closure { context; param; body }
  | Application { func; argument } ->
    let arg = interpret context argument in
    (match interpret context func with
     | Closure { context; param; body } -> interpret (Context.add param arg context) body
     | Native f -> f arg)
;;

let f =
  Abstraction
    { param = "f"
    ; body = Application { func = Variable "print_hello_world"; argument = Variable "f" }
    }
;;

let initial_context =
  Context.empty
  |> Context.add
       "print_hello_world"
       (Native
          (fun v ->
            print_endline "Hello world";
            v))
;;

let code = Application { func = f; argument = f }
let _ = interpret initial_context code
