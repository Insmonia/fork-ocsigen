(* Ocsigen
 * http://www.ocsigen.org
 * Copyright (C) 2010-2011
 * Raphaël Proust
 * Pierre Chambart
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

type 'a chan_id = string

external string_of_chan_id : 'a chan_id -> string = "%identity"
external chan_id_of_string : string -> 'a chan_id = "%identity"

type command =
  | Register of string
  | Close of string
deriving (Json)

type comet_request =
  | Request_data of int
  | Commands of command list
deriving (Json)

type 'a channel_data =
  | Data of 'a
  | Full

let comet_request_param =
  Eliom_parameters.caml "comet_request" Json.t<comet_request>

type comet_service =
    (unit, comet_request,
     [ `Nonattached of [ `Get | `Post ] Eliom_services.na_s ],
     [ `WithoutSuffix ], unit,
     [ `One of comet_request Eliom_parameters.caml ] Eliom_parameters.param_name, [ `Registrable ],
     Eliom_services.http )
      Eliom_services.service
