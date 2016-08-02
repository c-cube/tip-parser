
(* This file is free software. See file "license" for more details. *)

(** {1 Lexer for SMBC} *)

{
  module A = Tip_ast
  module Loc = A.Loc
  open Tip_parser (* for tokens *)

}

let printable_char = [^ '\n']
let comment_line = ';' printable_char*

let sym = [^ '"' '(' ')' '\\' ' ' '\t' '\r' '\n']

let ident = sym+

let quoted = '"' ([^ '"'] | '\\' '"')* '"'

rule token = parse
  | eof { EOI }
  | '\n' { Lexing.new_line lexbuf; token lexbuf }
  | [' ' '\t' '\r'] { token lexbuf }
  | comment_line { token lexbuf }
  | '(' { LEFT_PAREN }
  | ')' { RIGHT_PAREN }
  | "Bool" { BOOL }
  | "true" { TRUE }
  | "false" { FALSE }
  | "if" { IF }
  | "match" { MATCH }
  | "case" { CASE }
  | "fun" { FUN }
  | "mu" { MU }
  | "declare-datatypes" { DATA }
  | "assert" { ASSERT }
  | "assert-not" { ASSERT_NOT }
  | "decl" { DECL }
  | "define-fun-rec" { DEFINE }
  | "forall" { FORALL }
  | ident { IDENT(Lexing.lexeme lexbuf) }
  | quoted {
      (* TODO: unescape *)
      let s = Lexing.lexeme lexbuf in
      let s = String.sub s 1 (String.length s -2) in (* remove " " *)
      QUOTED s }
  | _ as c
    {
      let loc = Loc.of_lexbuf lexbuf in
      A.parse_errorf ~loc "unexpected char '%c'" c
    }

{

}
