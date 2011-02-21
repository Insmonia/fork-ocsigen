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

open Lwt
open Ocsigen_extensions


(*****************************************************************************)
let find_sitedata fun_name =
  match Eliom_common.get_sp_option () with
    | Some sp -> sp.Eliom_common.sp_sitedata
    | None ->
      match Eliom_common.global_register_allowed () with
        | Some get_current_sitedata -> get_current_sitedata ()
        | _ ->
          raise
            (Eliom_common.Eliom_site_information_not_available fun_name)

(*****************************************************************************)
let get_user_agent () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_request.request_info.ri_user_agent
let get_full_url_sp sp =
  sp.Eliom_common.sp_request.request_info.ri_url_string
let get_full_url () =
  let sp = Eliom_common.get_sp () in
  get_full_url_sp sp
let get_remote_ip () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_request.request_info.ri_remote_ip
let get_remote_inet_addr () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_request.request_info.ri_remote_inet_addr
let get_get_params () =
  let sp = Eliom_common.get_sp () in
  Lazy.force sp.Eliom_common.sp_request.request_info.ri_get_params
let get_all_current_get_params_sp sp =
  sp.Eliom_common.sp_si.Eliom_common.si_all_get_params
let get_all_current_get_params () =
  let sp = Eliom_common.get_sp () in
  get_all_current_get_params_sp sp
let get_initial_get_params () =
  let sp = Eliom_common.get_sp () in
  Lazy.force sp.Eliom_common.sp_request.request_info.ri_initial_get_params
let get_get_params_string () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_request.request_info.ri_get_params_string
let get_post_params_sp sp =
  match sp.Eliom_common.sp_request.request_info.ri_post_params with
    | None -> None
    | Some f -> Some (f sp.Eliom_common.sp_request.request_config)
let get_post_params () =
  let sp = Eliom_common.get_sp () in
  get_post_params_sp sp
let get_files_sp sp =
  match sp.Eliom_common.sp_request.request_info.ri_files with
    | None -> None
    | Some f -> Some (f sp.Eliom_common.sp_request.request_config)
let get_all_post_params () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_si.Eliom_common.si_all_post_params
let get_original_full_path_string_sp sp =
  sp.Eliom_common.sp_request.request_info.ri_original_full_path_string
let get_original_full_path_string () =
  let sp = Eliom_common.get_sp () in
  get_original_full_path_string_sp sp
let get_original_full_path_sp sp =
  sp.Eliom_common.sp_request.request_info.ri_original_full_path
let get_original_full_path () =
  let sp = Eliom_common.get_sp () in
  get_original_full_path_sp sp
let get_current_full_path () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_request.request_info.ri_full_path
let get_current_full_path_string () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_request.request_info.ri_full_path_string
let get_current_sub_path () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_request.request_info.ri_sub_path
let get_current_sub_path_string () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_request.request_info.ri_sub_path_string
let get_header_hostname () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_request.request_info.ri_host
let get_timeofday_sp sp =
  sp.Eliom_common.sp_request.request_info.ri_timeofday
let get_request_id_sp sp = Int64.bits_of_float (get_timeofday_sp sp)
let get_timeofday () =
  let sp = Eliom_common.get_sp () in
  get_timeofday_sp sp
let get_request_id () = Int64.bits_of_float (get_timeofday ())
let get_hostname_sp sp =
  Ocsigen_extensions.get_hostname sp.Eliom_common.sp_request
let get_hostname () =
  let sp = Eliom_common.get_sp () in
  get_hostname_sp sp
let get_server_port_sp sp =
  Ocsigen_extensions.get_port sp.Eliom_common.sp_request
let get_server_port () =
  let sp = Eliom_common.get_sp () in
  get_server_port_sp sp
let get_ssl_sp sp =
  sp.Eliom_common.sp_request.request_info.ri_ssl
let get_ssl () =
  let sp = Eliom_common.get_sp () in
  get_ssl_sp sp

let get_other_get_params () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_si.Eliom_common.si_other_get_params
let get_nl_get_params () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_si.Eliom_common.si_nl_get_params
let get_persistent_nl_get_params () =
  let sp = Eliom_common.get_sp () in
  Lazy.force sp.Eliom_common.sp_si.Eliom_common.si_persistent_nl_get_params
let get_nl_post_params () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_si.Eliom_common.si_nl_post_params

let get_other_get_params_sp sp =
  sp.Eliom_common.sp_si.Eliom_common.si_other_get_params
let get_nl_get_params_sp sp =
  sp.Eliom_common.sp_si.Eliom_common.si_nl_get_params
let get_persistent_nl_get_params_sp sp =
  Lazy.force sp.Eliom_common.sp_si.Eliom_common.si_persistent_nl_get_params
let get_nl_post_params_sp sp =
  sp.Eliom_common.sp_si.Eliom_common.si_nl_post_params

let get_suffix_sp sp =
  sp.Eliom_common.sp_suffix
let get_suffix () =
  let sp = Eliom_common.get_sp () in
  get_suffix_sp sp
let get_state_name () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_fullsessname
let get_request_cache_sp sp =
  sp.Eliom_common.sp_request.request_info.ri_request_cache
let get_request_cache () =
  let sp = Eliom_common.get_sp () in
  get_request_cache_sp sp
let clean_request_cache () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_request.request_info.ri_request_cache <- 
    Polytables.create ()
let get_link_too_old () =
  let sp = Eliom_common.get_sp () in
  try
    Polytables.get
      ~table:sp.Eliom_common.sp_request.request_info.ri_request_cache
      ~key:Eliom_common.eliom_link_too_old
  with Not_found -> false
let get_expired_service_sessions () =
  let sp = Eliom_common.get_sp () in
  try
    Polytables.get
      ~table:sp.Eliom_common.sp_request.request_info.ri_request_cache
      ~key:Eliom_common.eliom_service_session_expired
  with Not_found -> ([], [])

let get_cookies ?(cookie_scope = `Session) () =
  let sp = Eliom_common.get_sp () in
  match cookie_scope with
    | `Session ->
      Lazy.force sp.Eliom_common.sp_request.request_info.ri_cookies
    | `Client_process ->
      sp.Eliom_common.sp_si.Eliom_common.si_tab_cookies

let get_data_cookies () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_si.Eliom_common.si_data_session_cookies
let get_persistent_cookies () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_si.Eliom_common.si_persistent_session_cookies
let get_previous_extension_error_code () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_si.Eliom_common.si_previous_extension_error
let get_si sp = sp.Eliom_common.sp_si
  

let get_user_cookies () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_user_cookies

let get_user_tab_cookies () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_user_tab_cookies



(****)
let get_sp_client_appl_name () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_client_appl_name
let get_sp_client_process_info_sp sp =
  if Lazy.lazy_is_val sp.Eliom_common.sp_client_process_info
  then Some (Lazy.force sp.Eliom_common.sp_client_process_info)
  else None
let get_sp_client_process_info () =
  let sp = Eliom_common.get_sp () in
  get_sp_client_process_info_sp sp

(* *)

let get_site_dir () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_sitedata.Eliom_common.site_dir
let get_site_dir_sp sp =
  sp.Eliom_common.sp_sitedata.Eliom_common.site_dir
let get_site_dir_string () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_sitedata.Eliom_common.site_dir_string
let get_request () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_request
let get_request_sp sp =
  sp.Eliom_common.sp_request
let get_ri_sp sp =
  sp.Eliom_common.sp_request.Ocsigen_extensions.request_info
let get_ri () =
  let sp = Eliom_common.get_sp () in
  get_ri_sp sp

let get_tmp_filename fi = fi.Ocsigen_lib.tmp_filename
let get_filesize fi = fi.Ocsigen_lib.filesize
let get_original_filename fi = fi.Ocsigen_lib.original_basename

let get_sitedata () =
  let sp = Eliom_common.get_sp () in
  sp.Eliom_common.sp_sitedata

let get_sitedata_sp ~sp = sp.Eliom_common.sp_sitedata


(***)

(*VVV ici ? pour des raisons de typage... *)
let set_site_handler sitedata handler =
  sitedata.Eliom_common.exn_handler <- handler
