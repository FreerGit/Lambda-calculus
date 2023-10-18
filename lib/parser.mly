%{ open Type
   open Expr %}
%token <string> IDENT
%token <int> INT
%token ULAMBDA
%token LAMBDA
%token FORALL
%token COLON
%token DOT
%token ARROW

%token LBRACKET
%token RBRACKET
%token LPARENS
%token RPARENS
%token EOF

%start <Expr.t option> expr_opt
%start <Type.t option> typ_opt

%%

let typ_opt :=
  | EOF; { None }
  | t = typ; EOF; { Some t }

let sub_typ ==
  | i = IDENT;
    { match i with | "int" -> TInt | name -> TVar name }
  | LPARENS; t = typ; RPARENS; { t }

let typ :=
  | sub_typ
  | FORALL; p = IDENT; DOT; t = typ;
    { TForall { param = p; return_t = t } }
  | t1 = sub_typ; ARROW; t2 = typ;
    { TArrow { param_t = t1; body_t = t2 } }

let expr_opt :=
  | EOF; { None }
  | e = expr; EOF; { Some e }

let terminal ==
  | i = INT; { Int i }
  | i = IDENT; { Variable i }

let abstraction ==
  | LAMBDA; p = IDENT; COLON; t = typ; DOT; e = expr;
    { Abstraction { param = p; param_t = t; body = e } }
  | ULAMBDA; p = IDENT; DOT; e = expr;
    { Type_abstraction { param = p; body = e } }

let sub_expr :=
  | terminal
  | LPARENS; e = expr; RPARENS; { e }

let application :=
  | sub_expr
  | e1 = application; e2 = sub_expr;
    { Application { func = e1; argument = e2 } }
  | e = application; LBRACKET; t = typ; RBRACKET;
    { Type_application { func = e; argument = t } }

let expr :=
  | abstraction
  | application