(* Ocsigen
 * http://www.ocsigen.org
 * Copyright (C) 2010 Vincent Balat
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


let cookie_table = ref Ocsigen_cookies.Cookies.empty

let now () = Js.to_float (Js.date##now ())

let update_cookie_table cookieset =
  let now = now () in
  Ocsigen_cookies.Cookies.iter
    (fun path table ->
      Ocsigen_lib.String_Table.iter
        (fun name -> function 
          | Ocsigen_cookies.OSet (Some exp, _, _) when exp <= now ->
            cookie_table := Ocsigen_cookies.remove_cookie path name !cookie_table
          | Ocsigen_cookies.OUnset -> 
            cookie_table := Ocsigen_cookies.remove_cookie path name !cookie_table
          | Ocsigen_cookies.OSet (exp, value, secure) ->
            cookie_table := 
              Ocsigen_cookies.add_cookie
              path name (exp, value, secure)
              !cookie_table)
        table
    )
    cookieset


let get_cookies_to_send https path =
  let now = now () in
  Ocsigen_cookies.Cookies.fold
    (fun cpath t cookies_to_send ->
      if Ocsigen_lib.list_is_prefix_skip_end_slash
          (Ocsigen_lib.remove_slash_at_beginning cpath)
          (Ocsigen_lib.remove_slash_at_beginning path)
      then Ocsigen_lib.String_Table.fold
        (fun name (exp, value, secure) cookies_to_send ->
          match exp with
            | Some exp when exp <= now ->
              cookie_table := 
                Ocsigen_cookies.remove_cookie cpath name !cookie_table;
              cookies_to_send
            | _ ->
              if (not secure) || https
              then Ocsigen_lib.String_Table.add name value cookies_to_send
              else cookies_to_send
        )
        t
        cookies_to_send
      else cookies_to_send
    )
    !cookie_table
    Ocsigen_lib.String_Table.empty
