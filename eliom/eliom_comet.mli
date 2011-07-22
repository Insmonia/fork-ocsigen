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

module Channels :
(** A module with all the base primitive needed for server push. *)
sig

  type 'a t
  (** [v t] is the type of server-to-client communication channels
      transporting data of type [v] *)

  val create : ?name:string -> ?size:int -> 'a Lwt_stream.t -> 'a t
  (** [create s] returns a channel sending values from [s]. This
      function can only be used when client application datas are
      available. The eliom service created to communicate with the
      client is only available in the scope of the client process. A
      channel can be used only one time on client side. To be able to
      receive the same data multiples times on client side, use
      [create (Lwt_stream.clone s)] each time.
      To avoid memory leak when the client do not read the sent datas,
      the channel has a limited [size]. When a channel is full, no data
      can be read from it anymore.
      Not that to limit the data are read into the channel as soon as possible:
      If you want a channel that read data to the stream only when the
      client request it, use [create_unlimited] instead, but be carefull
      to memory leaks. *)

  val create_unlimited : ?name:string -> 'a Lwt_stream.t -> 'a t

  val get_id : 'a t -> 'a Eliom_common_comet.chan_id
  val wrap : 'a t -> ( 'a Eliom_common_comet.chan_id * Eliom_common.unwrapper ) Eliom_client_types.data_key

end

(**/**)

val get_service : unit -> Eliom_common_comet.comet_service

type comet_handler = Eliom_common_comet.comet_service

val init : unit -> comet_handler

