(* Ocsigen
 * http://www.ocsigen.org
 * Copyright (C) 2007 Vincent Balat
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
(*****************************************************************************)
(*****************************************************************************)
(** Internal functions used by Eliom:                                        *)
(** Service sessions                                                         *)
(*****************************************************************************)
(*****************************************************************************)


let compute_cookie_info secure secure_ci cookie_info =
  let secure_if_ssl = match secure with
    | None -> true (* If HTTPS, than the default is secure *)
    | Some s -> s
  in
  if secure_if_ssl
  then match secure_ci with
    | None (* not ssl *) -> cookie_info
    | Some (c, _, _) -> c
  else cookie_info



(*****************************************************************************)
let close_service_session ~scope ~secure ?sp () =
  let sp = Eliom_common.sp_of_option sp in
  try
    let cookie_scope = Eliom_common.cookie_scope_of_user_scope scope in
    let fullsessname =
      Eliom_common.make_fullsessname ~sp scope
    in
    let ((cookie_info, _, _), secure_ci) =
      Eliom_common.get_cookie_info sp cookie_scope
    in
    let cookie_info = compute_cookie_info secure secure_ci cookie_info in
    let (_, ior) =
      Eliom_common.Fullsessionname_Table.find fullsessname !cookie_info
    in

    match !ior with
      | Eliom_common.SC c ->
          (* there is only one way to close a session:
             remove it from the session group table.
             It will remove the entry in the session table *)
        begin
	  match scope with
	    | `Session_group _ ->
              begin
		(* If we want to close all the group of browser sessions,
		   the node is found in the group table: *)
		match
		  Eliommod_sessiongroups.Serv.find_node_in_group_of_groups
		    !(c.Eliom_common.sc_session_group)
		with
		  | None -> Ocsigen_messages.errlog
		    "Eliom: No group of groups. Please report this problem."
		  | Some (service_table, g) -> Eliommod_sessiongroups.Serv.remove g
	      end
	    | `Session _
	    | `Client_process _ ->
              Eliommod_sessiongroups.Serv.remove
		c.Eliom_common.sc_session_group_node
	end;
        ior := Eliom_common.SCNo_data
      | _ -> ()

  with Not_found -> ()



let fullsessgrp ~cookie_scope ~sp set_session_group =
  let sitedata = Eliom_request_info.get_sitedata_sp sp in
  Eliommod_sessiongroups.make_full_group_name
    ~cookie_scope
    (Eliom_request_info.get_request_sp sp).Ocsigen_extensions.request_info
    sitedata.Eliom_common.site_dir_string
    (Eliom_common.get_mask4 sitedata)
    (Eliom_common.get_mask6 sitedata)
    set_session_group

let rec find_or_create_service_cookie_ ?set_session_group
    ~scope ~secure ~sp () =
  (* If the cookie does not exist, create it.
     Returns the cookie info for the cookie *)

  let cookie_scope = Eliom_common.cookie_scope_of_user_scope scope in

  let rec new_service_cookie sitedata fullsessname table =

    let set_session_group =
      match scope with
	| `Client_process n ->
	  begin (* We create a group whose name is the
                   browser session cookie
                   and put the tab session into it. *)
            let v = find_or_create_service_cookie_
	      ~scope:(`Session n)
              ~secure
              ~sp
              ()
            in
            Eliommod_sessiongroups.Data.set_max
              v.Eliom_common.sc_session_group_node
              (fst sitedata.Eliom_common.max_service_tab_sessions_per_group);
            Some v.Eliom_common.sc_value
	  end
	| `Session _ | `Session_group _ -> set_session_group
    in
    let fullsessgrp = fullsessgrp ~cookie_scope ~sp set_session_group in

    let rec aux () =
      let c = Eliommod_cookies.make_new_session_id () in
      try
        ignore (Eliom_common.SessionCookies.find table c);
      (* Actually not needed
         for the cookies we use *)
        aux ()
      with Not_found ->
        let str = ref (Eliom_common.new_service_session_tables sitedata) in
        let usertimeout = ref Eliom_common.TGlobal (* See global table *) in
        let serverexp = ref None (*Some 0.*) (* None = never. We'll change it later. *) in
        let fullsessgrpref = ref fullsessgrp in
        let node = Eliommod_sessiongroups.Serv.add sitedata c fullsessgrp in
        Eliom_common.SessionCookies.replace
        (* actually it will add the cookie *)
          table
          c
          (fullsessname,
           !str,
           serverexp (* exp on server *),
           usertimeout,
           fullsessgrpref,
           node);
        {Eliom_common.sc_value= c;
         Eliom_common.sc_table= str;
         Eliom_common.sc_timeout= usertimeout;
         Eliom_common.sc_exp= serverexp;
         Eliom_common.sc_cookie_exp= ref Eliom_common.CENothing
       (* exp on client - nothing to set *);
         Eliom_common.sc_session_group= fullsessgrpref;
         Eliom_common.sc_session_group_node= node;
        }
    in aux ()
  in


  let fullsessname =
    Eliom_common.make_fullsessname ~sp scope
  in

  let ((cookie_info, _, _), secure_ci) =
    Eliom_common.get_cookie_info sp cookie_scope
  in
  let cookie_info = compute_cookie_info secure secure_ci cookie_info in
  try

    let (old, ior) =
      Eliom_common.Fullsessionname_Table.find fullsessname !cookie_info
    in
    match !ior with
    | Eliom_common.SCData_session_expired
        (* We do not trust the value sent by the client,
           for security reasons *)
    | Eliom_common.SCNo_data ->
      let sitedata = Eliom_request_info.get_sitedata_sp sp in
      let v =
        new_service_cookie
          sitedata fullsessname
          sitedata.Eliom_common.session_services
      in
      ior := Eliom_common.SC v;
      v
    | Eliom_common.SC c ->
      (match set_session_group with
        | None -> ()
        | Some session_group ->
          let sitedata = Eliom_request_info.get_sitedata_sp sp in
          let fullsessgrp = fullsessgrp ~cookie_scope ~sp set_session_group in
          let node = Eliommod_sessiongroups.Serv.move
            sitedata
            c.Eliom_common.sc_session_group_node fullsessgrp
          in
          c.Eliom_common.sc_session_group_node <- node;
          c.Eliom_common.sc_session_group := fullsessgrp
      );
      c
  with Not_found ->
    let sitedata = Eliom_request_info.get_sitedata_sp sp in
    let v =
      new_service_cookie
        sitedata fullsessname
        sitedata.Eliom_common.session_services
    in
    cookie_info :=
      Eliom_common.Fullsessionname_Table.add
        fullsessname
        (None, ref (Eliom_common.SC v))
        !cookie_info;
    v

let find_or_create_service_cookie ?set_session_group
    ~scope ~secure ?sp () =
  let sp = Eliom_common.sp_of_option sp in
  find_or_create_service_cookie_ ?set_session_group
    ~scope ~secure ~sp ()


let find_service_cookie_only
    ~scope ~secure ?sp () =
  (* If the cookie does not exist, do not create it, raise Not_found.
     Returns the cookie info for the cookie *)
  let sp = Eliom_common.sp_of_option sp in
  let fullsessname =
    Eliom_common.make_fullsessname ~sp scope
  in
  let ((cookie_info, _, _), secure_ci) =
      Eliom_common.get_cookie_info sp (Eliom_common.cookie_scope_of_user_scope scope)
    in
  let cookie_info = compute_cookie_info secure secure_ci cookie_info in
  let (_, ior) =
    Eliom_common.Fullsessionname_Table.find fullsessname !cookie_info
  in
  match !ior with
  | Eliom_common.SCNo_data -> raise Not_found
  | Eliom_common.SCData_session_expired ->
      raise Eliom_common.Eliom_Session_expired
  | Eliom_common.SC v -> v



