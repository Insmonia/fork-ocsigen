(* Ocsigen
 * Copyright (C) 2011 Pierre Chambart
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

type 'a wrapped_value

type +'a wrapper
(** ['a wrapper] is the type of values to include into a value of type 'a for
   it to be wraped specificaly *)

val create_wrapper : ( 'a -> 'b ) -> 'a wrapper
(** [create f] create a new tag that can be included into a value.  if
    [wrap] is called on a father of a value [v] containing a tag, the
    value [v] will be replaced by [f v] before marshaling. *)

val wrap : 'a -> 'a wrapped_value
(** marshal a value, taking into account the tags *)

val empty_wrapper : 'a wrapper
(** a wrapper that do not change the value *)

(** unwrap **)

type unwrap_id
type unwrapper

val create_unwrapper : unwrap_id -> unwrapper
val empty_unwrapper : unwrapper
val id_of_int : int -> unwrap_id
