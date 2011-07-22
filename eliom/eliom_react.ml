(* Ocsigen
 * http://www.ocsigen.org
 * Copyright (C) 2010
 * Raphaël Proust
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

(* Module for event wrapping and related functions *)


include Eliommod_react

module Up =
struct

  type 'a t =
      { event : 'a React.event;
	service : 
	  (unit,
	   'a,
	   [ `Nonattached of [ `Post ] Eliom_services.na_s ],
	   [ `WithoutSuffix ],
	   unit,
	   [ `One of 'a Eliom_parameters.caml ] Eliom_parameters.param_name,
	   [ `Registrable ],
	   Eliom_output.Action.return)
            Eliom_services.service;
	wrapper : 'a t Eliom_common.wrapper }

  let to_react t = t.event
  let wrap t = Eliom_services.wrap t.service

  let internal_wrap t = (t.service, Eliom_common.make_unwrapper Eliom_common.react_up_unwrap_id)

  let up_event_wrapper () = Eliom_common.make_wrapper internal_wrap

  (* An event is created along with a service responsible for it's occurences.
   * function takes a param_type *)
  let create ?scope ?name post_params =
    let (e, push) = React.E.create () in
    let sp = Eliom_common.get_sp_option () in
    let scope = match sp, scope with
      | _, Some l -> l
      | None, _ -> `Global
      | _ -> `Client_process
    in
    let e_writer = Eliom_services.post_coservice' ?name ~post_params () in
    Eliom_output.Action.register
      ~scope
      ~options:`NoReload
      ~service:e_writer
      (fun () value -> push value ; Lwt.return ());
    { event = e;
      service = e_writer;
      wrapper = up_event_wrapper () }

end
