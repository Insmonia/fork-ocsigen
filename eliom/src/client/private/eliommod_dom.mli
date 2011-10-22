(* Ocsigen
 * http://www.ocsigen.org
 * Copyright (C) 2011 Pierre Chambart, Grégoire Henry
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

(** Cross browser dom manipulation functions *)

class type ['element] get_tag = object
  method getElementsByTagName : Js.js_string Js.t -> 'element Dom.nodeList Js.t Js.meth
end

val get_body : 'element #get_tag Js.t -> 'element Js.t
val get_head : 'element #get_tag Js.t -> 'element Js.t

val copy_element : Dom.element Js.t -> Dom_html.element Js.t
(** [copy_element e] creates recursively a fresh html from any xml
    element avoiding brower bugs *)

val html_document : Dom.element Dom.document Js.t -> Dom_html.element Js.t
(** Assuming [d] has a body and head element, [html_document d] will
    return the same document as html *)

val preload_css : Dom_html.element Js.t -> unit Lwt.t
(** [preload_css e] downloads every css included in every link element
    descendant of [e] and replace it and its linked css by raw style
    elements *)
