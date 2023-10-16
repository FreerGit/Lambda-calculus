module Context = Map.Make (String)

(* let f =
  Abstraction
    { param = "f"
    ; body = Application { func = Variable "print_hello_world"; argument = Variable "f" }
    }
;;

let initial_context =
  Context.empty
  |> Context.add
       "print_hello_world"
       (VNative
          (fun v ->
            print_endline "Hello world";
            v))
;;

let code = Application { func = f; argument = f }
let _ = interpret initial_context code *)
