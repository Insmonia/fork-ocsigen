(* $Id: xML.mli,v 1.15 2004/12/13 14:57:45 ohl Exp $

   Copyright (C) 2004 by Thorsten Ohl <ohl@physik.uni-wuerzburg.de>

   XHTML is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   XHTML is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  *)

type aname = string
type separator = Space | Comma
type event = string

type attrib
type attribs
val float_attrib : aname -> float -> attrib
val int_attrib : aname -> int -> attrib
val string_attrib : aname -> string -> attrib
val space_sep_attrib : aname -> string list -> attrib
val comma_sep_attrib : aname -> string list -> attrib
val event_attrib : aname -> string -> attrib

val attrib_name : attrib -> aname
val attrib_value_to_string : (string -> string) -> attrib -> string
val attrib_to_string : (string -> string) -> attrib -> string

type ename = string

(* For Ocsigen I need to unabstract elt: *)
type elt_content =
  | Empty
  | Comment of string
  | EncodedPCDATA of string
  | PCDATA of string
  | Entity of string
  | Leaf of ename * attrib list
  | Node of ename * attrib list * elt list
and elt = {
  (* the element is boxed with some meta-information *)
  mutable ref : int ;
  elt : elt_content ;
}

val empty : unit -> elt

val comment : string -> elt
val pcdata : string -> elt
val encodedpcdata : string -> elt
val entity : string -> elt
(** Neither [comment], [pcdata] nor [entity] check their argument for invalid
    characters.  Unsafe characters will be escaped later by the output routines.  *)

val leaf : ?a:(attrib list) -> ename -> elt
val node : ?a:(attrib list) -> ename -> elt list -> elt
(** NB: [Leaf ("foo", []) -> "<foo />"], but [Node ("foo", [], []) -> "<foo></foo>"] *)

val cdata : string -> elt
val cdata_script : string -> elt
val cdata_style : string -> elt

val encode_unsafe : string -> string
(** The encoder maps strings to HTML and {e must} encode the unsafe characters
    ['<'], ['>'], ['"'], ['&'] and the control characters 0-8, 11-12, 14-31, 127
    to HTML entities.  [encode_unsafe] is the default for [?encode] in [output]
    and [pretty_print] below.  Other implementations are provided by the module
    [Netencoding] in the
    {{:http://www.ocaml-programming.de/programming/ocamlnet.html}OcamlNet} library, e.g.:
    [let encode = Netencoding.Html.encode ~in_enc:`Enc_iso88591 ~out_enc:`Enc_usascii ()],
    Where national characters are replaced by HTML entities.
    The user is of course free to write her own implementation.
    @see <http://www.ocaml-programming.de/programming/ocamlnet.html> OcamlNet *)

val encode_unsafe_and_at : string -> string
(** In addition, encode ["@"] as ["&#64;"] in the hope that this will fool
    simple minded email address harvesters. *)

val output : ?preformatted:ename list -> ?no_break:ename list ->
  ?encode:(string -> string) -> (string -> unit) -> elt -> unit

val output_compact : ?encode:(string -> string) -> 
   (string -> unit) -> elt -> unit

val pretty_print : ?width:int ->
  ?preformatted:ename list -> ?no_break:ename list ->
    ?encode:(string -> string) -> (string -> unit) -> elt -> unit
(** Children of elements that are mentioned in [no_break] do not
    generate additional line breaks for pretty printing in order not to
    produce spurious white space.  In addition, elements that are mentioned
    in [preformatted] are not pretty printed at all, with all
   white space intact.  *)

val decl : ?version:string -> ?encoding:string -> (string -> unit) -> unit -> unit
(** [encoding] is the name of the character encoding, e.g. ["US-ASCII"] *)

val amap : (ename -> attribs -> attribs) -> elt -> elt
(** Recursively edit attributes for the element and all its children. *)

val amap1 : (ename -> attribs -> attribs) -> elt -> elt
(** Edit attributes only for one element. *)

(** The following can safely be exported by higher level libraries,
    because removing an attribute from a element is always legal. *)

val rm_attrib : (aname -> bool) -> attribs -> attribs
val rm_attrib_from_list : (aname -> bool) -> (string -> bool) -> attribs -> attribs

val map_int_attrib :
    (aname -> bool) -> (int -> int) -> attribs -> attribs
val map_string_attrib :
    (aname -> bool) -> (string -> string) -> attribs -> attribs
val map_string_attrib_in_list :
    (aname -> bool) -> (string -> string) -> attribs -> attribs

(** Exporting the following by higher level libraries would drive
    a hole through a type system, because they allow to add {e any}
    attribute to {e any} element. *)

val add_int_attrib : aname -> int -> attribs -> attribs
val add_string_attrib : aname -> string -> attribs -> attribs
val add_comma_sep_attrib : aname -> string -> attribs -> attribs
val add_space_sep_attrib : aname -> string -> attribs -> attribs

val fold : (unit -> 'a) -> (string -> 'a) -> (string -> 'a) -> (string -> 'a) ->
  (ename -> attrib list -> 'a) -> (ename -> attrib list -> 'a list -> 'a) ->
    elt -> 'a

(* (* is this AT ALL useful??? *)
val foldx : (unit -> 'a) -> (string -> 'a) -> (string -> 'a) -> (string -> 'a) ->
  ('state -> ename -> attrib list -> 'a) ->
    ('state -> ename -> attrib list -> 'a list -> 'a) ->
      (ename -> attrib list -> 'state -> 'state) -> 'state -> elt -> 'a
*)


val all_entities : elt -> string list

val translate :
    (ename -> attrib list -> elt) ->
      (ename -> attrib list -> elt list -> elt) ->
        ('state -> ename -> attrib list -> elt list) ->
          ('state -> ename -> attrib list -> elt list -> elt list) ->
            (ename -> attrib list -> 'state -> 'state) -> 'state -> elt -> elt



type ref_tree = Ref_tree of int option * (int * ref_tree) list

val ref_node : elt -> int
val next_ref : unit -> int (** use with care! *)
val make_ref_tree : elt -> ref_tree
val make_ref_tree_list : elt list -> (int * ref_tree) list

val register_event : elt -> string -> ('a -> 'b) -> 'a -> unit

val class_name : string
