(* Ocsigen
 * Copyright (C) 2008 Vincent Balat, Mauricio Fernandez
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception;
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)
open XML
open Buffer

module MakeCompact (Format : sig
  type 'a elt
  type doctypes
  val emptytags : string list
  val need_name : string list
  val doctype : doctypes -> string
  val default_doctype : doctypes
  val toeltl : 'a elt list -> XML.elt list
  val toelt : 'a elt -> XML.elt end) 
  = struct
    open Format
    let mem_func l =
      let h = Hashtbl.create 17 in
      List.iter (fun x -> Hashtbl.add h x true) l;
      fun x -> Hashtbl.mem h x
        
    let is_emptytag = mem_func emptytags
    let needs_id2name = mem_func need_name
    let x_print, xh_print =
      
      let aux b ~encode ?(html_compat = false) doctype arbre =
        let endemptytag = if html_compat then ">" else " />" in
        let rec xh_print_attrs doid2name encode attrs = match attrs with
          | [] ->  ();
          | attr::queue ->
            add_char b ' ';
            add_string b (XML.attrib_to_string encode attr);
            if doid2name && XML.attrib_name attr = "id" then (
              add_string b " id=";
              add_string b (XML.attrib_value_to_string encode attr)
            );
            xh_print_attrs doid2name encode queue

        and xh_print_closedtag encode tag attrs =
          if html_compat && not (is_emptytag tag) then (
            add_char b '<';
            add_string b tag;
            xh_print_attrs (html_compat && needs_id2name tag) encode attrs;
            add_string b "></";
            add_string b tag;
            add_string b ">"
          ) else (
            add_char b '<';
            add_string b tag;
            xh_print_attrs (html_compat && needs_id2name tag) encode attrs;
            add_string b endemptytag;
          )

        and xh_print_tag encode tag attrs taglist =
          if taglist = []
          then xh_print_closedtag encode tag attrs
          else (
            add_char b '<';
            add_string b tag;
            xh_print_attrs (html_compat && needs_id2name tag) encode attrs;
            add_char b '>';
            xh_print_taglist taglist;
            add_string b "</";
            add_string b tag;
            add_char b '>';
          )

        and print_nodes name xh_attrs xh_taglist queue =
          xh_print_tag encode name xh_attrs xh_taglist;
          xh_print_taglist queue

        and xh_print_taglist taglist =
          match taglist with

            | [] -> ()

            | { elt = Comment texte }::queue ->
              add_string b "<!--";
              add_string b (encode texte);
              add_string b "-->";
              xh_print_taglist queue;

            | { elt = Entity e }::queue ->
              add_char b '&';
              add_string b e; (* no encoding *)
              add_char b ';';
              xh_print_taglist queue;

            | { elt = PCDATA texte }::queue ->
              add_string b (encode texte);
              xh_print_taglist queue;

            | { elt = EncodedPCDATA texte }::queue ->
              add_string b texte;
              xh_print_taglist queue;

      (* Nodes and Leafs *)
            | { elt = Node (name, xh_attrs, xh_taglist )}::queue ->
              print_nodes name xh_attrs xh_taglist queue

            | { elt = Leaf (name,xh_attrs )}::queue ->
              print_nodes name xh_attrs [] queue

            | { elt = Empty }::queue ->
              xh_print_taglist queue

        in
        xh_print_taglist [arbre]
      in
      ((fun ?header ?(encode = encode_unsafe) ?html_compat doctype foret ->
        let b = Buffer.create 16384 in
        (match header with Some s -> add_string b s | None -> ());
        List.iter (aux b ?encode ?html_compat doctype) foret;
        Buffer.contents b),

       (fun ?header ?(encode = encode_unsafe) ?html_compat doctype arbre ->
         let b = Buffer.create 16384 in
         (match header with Some s -> add_string b s | None -> ());
         add_string b doctype;
         aux b ?encode ?html_compat doctype arbre;
         Buffer.contents b))

    let opt_default x = function
      | Some x -> x
      | _ -> x
    let xhtml_print ?(header = "") ?version ?encode ?html_compat arbre =
      xh_print ~header ?encode ?html_compat
        (Format.doctype (opt_default Format.default_doctype version)) (Format.toelt arbre)

    let xhtml_list_print ?(header = "") ?version ?encode ?html_compat foret =
      x_print ~header ?encode ?html_compat
        (Format.doctype (opt_default Format.default_doctype version) )
        (Format.toeltl foret)

    let emptytags = Format.emptytags
end
