(* Ocsigen
 * http://www.ocsigen.org
 * Module eliommod_datasess.ml
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
(** Volatile data tables                                                     *)
(*****************************************************************************)
(*****************************************************************************)

let compute_cookie_info secure secure_ci cookie_info =
  let secure = match secure with
    | None -> true
    | Some s -> s
  in
  if secure 
  then match secure_ci with
    | None (* not ssl *) -> cookie_info
    | Some (_, c, _) -> c
  else cookie_info




(* to be called during a request *)
let close_data_session ?state_name ?(scope = `Session) ~secure ?sp () =
  let sp = Eliom_common.sp_of_option sp in
  try
    let cookie_scope = Eliom_common.cookie_scope_of_user_scope scope in
    let fullsessname = 
      Eliom_common.make_fullsessname ~sp cookie_scope state_name
    in
    let ((_, cookie_info, _), secure_ci) = 
      Eliom_common.get_cookie_info sp cookie_scope
    in
    let cookie_info = compute_cookie_info secure secure_ci cookie_info in
    let (_, ior) =
      Lazy.force 
        (Eliom_common.Fullsessionname_Table.find fullsessname !cookie_info)
    in

    match !ior with
      | Eliom_common.SC c ->
        (* There is only one way to close a session:
           remove it from the session group table.
           It will remove all the data table entries
           and also the entry in the session table *)
        if scope = `Session_group
        then
          (* If we want to close all the group of browser sessions,
             the node is found in the group table: *)
          match 
            Eliommod_sessiongroups.Data.find_node_in_group_of_groups
              !(c.Eliom_common.dc_session_group)
          with
            | None -> Ocsigen_messages.errlog
              "Eliom: No group of groups. Please report this problem."
            | Some g -> Eliommod_sessiongroups.Data.remove g
        else
          (* If we want to close a (tab/browser) session, the node is found
             in the cookie info: *)
          Eliommod_sessiongroups.Data.remove
            c.Eliom_common.dc_session_group_node;
        ior := Eliom_common.SCNo_data
      | _ -> ()

  with Not_found -> ()


let fullsessgrp ~cookie_scope ~sp set_session_group =
  Eliommod_sessiongroups.make_full_group_name
    ~cookie_scope
    sp.Eliom_common.sp_request.Ocsigen_extensions.request_info
    sp.Eliom_common.sp_sitedata.Eliom_common.site_dir_string
    (Eliom_common.get_mask4 sp.Eliom_common.sp_sitedata)
    (Eliom_common.get_mask6 sp.Eliom_common.sp_sitedata)
    set_session_group

let rec find_or_create_data_cookie ?set_session_group
    ?state_name ?(cookie_scope = `Session) ~secure ?sp () =
  (* If the cookie does not exist, create it.
     Returns the cookie info for the cookie *)

  let sp = Eliom_common.sp_of_option sp in

  let new_data_cookie sitedata fullsessname table =

    let set_session_group =
      if cookie_scope = `Client_process
      then begin (* We create a group whose name is the
                    browser session cookie 
                    and put the tab session into it. *)
        let v = find_or_create_data_cookie
          ?state_name
          ~cookie_scope:`Session
          ~secure
          ~sp
          ()
        in
        Eliommod_sessiongroups.Data.set_max
          v.Eliom_common.dc_session_group_node
          (fst sitedata.Eliom_common.max_volatile_data_tab_sessions_per_group);
        Some v.Eliom_common.dc_value
      end
      else set_session_group
    in
    let fullsessgrp = fullsessgrp ~cookie_scope ~sp set_session_group in

    let rec aux () =
      let c = Eliommod_cookies.make_new_session_id () in
      try
        ignore (Eliom_common.SessionCookies.find table c);
      (* Actually not needed for the cookies we use *)
        aux ()
      with Not_found ->
        let usertimeout = ref Eliom_common.TGlobal (* See global table *) in
        let serverexp = ref None (* Some 0. *) (* None = never. We'll change it later. *) in
        let fullsessgrpref = ref fullsessgrp in
        let node = Eliommod_sessiongroups.Data.add sitedata c fullsessgrp in
        Eliom_common.SessionCookies.replace
        (* actually it will add the cookie *)
          table
          c
          (fullsessname,
           serverexp (* exp on server *),
           usertimeout,
           fullsessgrpref,
           node);
        {Eliom_common.dc_value= c;
         Eliom_common.dc_timeout= usertimeout;
         Eliom_common.dc_exp= serverexp;
         Eliom_common.dc_cookie_exp=
            ref Eliom_common.CENothing (* exp on client - nothing to set *);
         Eliom_common.dc_session_group= fullsessgrpref;
         Eliom_common.dc_session_group_node= node;
        }
    in
    aux ()
  in

  let fullsessname =
    Eliom_common.make_fullsessname ~sp cookie_scope state_name 
  in

  let ((_, cookie_info, _), secure_ci) =
    Eliom_common.get_cookie_info sp cookie_scope
  in
  let cookie_info = compute_cookie_info secure secure_ci cookie_info in
  try
    let (old, ior) =
      Lazy.force
        (Eliom_common.Fullsessionname_Table.find fullsessname !cookie_info)
    in
    match !ior with
    | Eliom_common.SCData_session_expired
        (* We do not trust the value sent by the client,
           for security reasons *)
    | Eliom_common.SCNo_data ->
      let sitedata = Eliom_request_info.get_sitedata_sp sp in
      let v =
        new_data_cookie
          sitedata fullsessname
          sitedata.Eliom_common.session_data
      in
      ior := Eliom_common.SC v;
      v
    | Eliom_common.SC c -> 
        (match set_session_group with
          | None -> ()
          | Some session_group -> 
            let sitedata = Eliom_request_info.get_sitedata_sp sp in
            let fullsessgrp = fullsessgrp ~cookie_scope ~sp set_session_group in
            let node = Eliommod_sessiongroups.Data.move
              sitedata
              c.Eliom_common.dc_session_group_node
              fullsessgrp
            in
            c.Eliom_common.dc_session_group_node <- node;
            c.Eliom_common.dc_session_group := fullsessgrp
        );
        c
  with Not_found ->
    let sitedata = Eliom_request_info.get_sitedata_sp sp in
    let v =
      new_data_cookie
        sitedata fullsessname
        sitedata.Eliom_common.session_data
    in
    cookie_info :=
      Eliom_common.Fullsessionname_Table.add
        fullsessname
        (Lazy.lazy_from_val (None, ref (Eliom_common.SC v)))
        !cookie_info;
    v

let find_data_cookie_only ?state_name 
    ?(cookie_scope = `Session) ~secure ?sp () =
  (* If the cookie does not exist, do not create it, raise Not_found.
     Returns the cookie info for the cookie *)
  let sp = Eliom_common.sp_of_option sp in
  let fullsessname = 
    Eliom_common.make_fullsessname ~sp cookie_scope state_name 
  in
  let ((_, cookie_info, _), secure_ci) =
    Eliom_common.get_cookie_info sp cookie_scope
  in
  let cookie_info = compute_cookie_info secure secure_ci cookie_info in
  let (_, ior) =
    Lazy.force 
      (Eliom_common.Fullsessionname_Table.find fullsessname !cookie_info)
  in
  match !ior with
  | Eliom_common.SCNo_data -> raise Not_found
  | Eliom_common.SCData_session_expired ->
      raise Eliom_common.Eliom_Session_expired
  | Eliom_common.SC v -> v




(*****************************************************************************)
(** session data *)

let counttableelements = ref []
(* Here only for exploration functions *)

let create_volatile_table, create_volatile_table_during_session =
  let aux ~scope ~state_name ~secure sitedata =
    let t = Eliom_common.SessionCookies.create 100 in
    let old_remove_session_data =
      sitedata.Eliom_common.remove_session_data
    in
    sitedata.Eliom_common.remove_session_data <-
      (fun cookie ->
        old_remove_session_data cookie;
        Eliom_common.SessionCookies.remove t cookie
      );
    let old_not_bound_in_data_tables =
      sitedata.Eliom_common.not_bound_in_data_tables
    in
    sitedata.Eliom_common.not_bound_in_data_tables <-
      (fun cookie ->
        old_not_bound_in_data_tables cookie &&
        not (Eliom_common.SessionCookies.mem t cookie)
      );
    counttableelements :=
      (fun () -> Eliom_common.SessionCookies.length t)::
      !counttableelements;
    (scope, state_name, secure, t)
  in
  ((fun ~scope ~state_name ~secure ->
    let sitedata = Eliom_common.get_current_sitedata () in
    aux ~scope ~state_name ~secure sitedata),
   (fun ~scope ~state_name ~secure sitedata ->
     aux ~scope ~state_name ~secure sitedata))


