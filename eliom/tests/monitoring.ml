(* Ocsigen
 * Copyright (C) 2005 Vincent Balat
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

(* A page providing infos about the server (number of sessions, uptime...) *)

open Ocsigen_extensions (* for profiling info *)
open Eliom_output.Xhtml
open Eliom_output
open Eliom_services
open Eliom_parameters
open Eliom_state
open Unix
open Lwt

let launchtime = Unix.time ()

let _ =
  register_service
    ~path:[]
    ~get_params:unit
    (fun () () ->
      let tm = Unix.gmtime ((Unix.time ()) -. launchtime) in
      let year = if tm.tm_year>0 then (string_of_int (tm.tm_year - 70))^" years, "
      else "" in
      let days = (string_of_int (tm.tm_yday))^" days, " in
      let hour = (string_of_int (tm.tm_hour))^" hours, " in
      let min = (string_of_int (tm.tm_min))^" min, " in
      let sec = (string_of_int (tm.tm_sec))^" seconds" in
      let uptime = year^days^hour^min^sec in

      let stat = Gc.quick_stat () in
      let size = string_of_int (stat.Gc.heap_words) in
      let maxsize = string_of_int (stat.Gc.top_heap_words) in
      let compactions = string_of_int stat.Gc.compactions in
      let mincol = string_of_int stat.Gc.minor_collections in
      let majcol = string_of_int stat.Gc.major_collections in
      let top_heap_words = string_of_int stat.Gc.top_heap_words in
      let pid = string_of_int (Unix.getpid ()) in
      let fd =
        try
          let dir = Unix.opendir
              ("/proc/"^pid^"/fd") in
          let rec aux v =
            try ignore ((* print_endline *) (readdir dir)); aux (v+1)
            with End_of_file -> v
          in
          let r =
            try string_of_int ((aux 0) - 2)
            with e -> ("(Error: "^(Printexc.to_string e)^")") in
          Unix.closedir dir;
          Some r
        with _ -> None
      in
      let nssess = Eliom_state.number_of_service_sessions () in
      let ndsess = Eliom_state.number_of_volatile_data_sessions () in
      let ntables = Eliom_state.number_of_tables () in
      let ntableselts = Eliom_state.number_of_table_elements () in
      Eliom_state.number_of_persistent_data_sessions () >>=
        (fun nbperssess ->
          let nbperstab = Eliom_state.number_of_persistent_tables () in
          Eliom_state.number_of_persistent_table_elements () >>=
          (fun nbperstabel ->
            let dot = <:xhtmllist< . >> in
            let list1 a l = <:xhtmllist<  with, respectively
             $str:List.fold_left
             (fun deb i -> deb^", "^(string_of_int i))
             (string_of_int a) l $
           elements inside. >>
           in
            let list2 (n,a) l = <:xhtmllist<  with, respectively
             $str:List.fold_left
             (fun deb (s, i) -> deb^", "^s^" : "^(string_of_int i))
             (n^" : "^(string_of_int a)) l$
           elements inside. >>
            in
            Eliommod_sessiongroups.Pers.nb_of_groups () >>= fun persgrplength ->
Lwt.return
<<
 <html>
   <head>
   </head>
   <body>
     <h1>Ocsigen server monitoring</h1>
      <p>Version of Ocsigen: $str:Ocsigen_config.version_number$</p>
     <p>Uptime: $str:uptime$.</p>
     <p>The number of sessions is not available in this version of Eliom.</p>
     <p>Number of clients connected:
         $str:(string_of_int (get_number_of_connected ()))$.</p>
     <p>PID : $str:pid$</p>
     <p>$str:match fd with
       None -> "Information on file descriptors not accessible in /proc."
     | Some fd -> fd^" file descriptors opened."$</p>
     <h2>GC</h2>
     <p>Size of major heap: $str:size$ words (max: $str:maxsize$).</p>
     <p>Since the beginning:</p>
       <ul><li>$str:mincol$ minor garbage collections,</li>
           <li> $str:majcol$ major collections,</li>
           <li>$str:compactions$ compactions of the heap.</li>
           <li>Maximum size reached by the major heap: $str:top_heap_words$ words.</li>
       </ul>
     <h2>Lwt threads</h2>
     <p><em>removed</em>
     </p>
     <h2>Preemptive threads</h2>
     <p>There are currently $str:(string_of_int (Lwt_preemptive.nbthreads ()))$
             detached threads running
             (min $str:(string_of_int (Ocsigen_config.get_minthreads ()))$,
             max $str:(string_of_int (Ocsigen_config.get_maxthreads ()))$),
      from which $str:(string_of_int (Lwt_preemptive.nbthreadsbusy ()))$ are busy.
        $str:(string_of_int (Lwt_preemptive.nbthreadsqueued ()))$ computations
           queued (max
        $str:(string_of_int (Ocsigen_config.get_max_number_of_threads_queued ()))$).</p>
     <h2>HTTP connexions</h2>
     <p>Number of
        $str:"" (* string_of_int
                     (Ocsigen_http_com.Timeout.nb_threads_waiting_timeout ()) *)$
     connexions waiting for timeout: not implemented in that version</p>
     <h2>Eliom sessions</h2>
     <p>There are $str:string_of_int nssess$ Eliom service sessions opened,
        $str:string_of_int ndsess$ Eliom in memory data sessions opened.<br/>
     There are $str:string_of_int ntables$ Eliom in memory tables created $list:
      (match ntableselts with
      | [] -> dot
      | a::l -> list1 a l)
       $
       </p>
     <p>There are $str:string_of_int nbperssess$
        Eliom persistent sessions opened.<br/>
     and $str:string_of_int nbperstab$ Eliom
    persistent tables created $list:
      (match nbperstabel with
      | [] -> dot
      | a::l -> list2 a l)
       $</p>
      <p>Number of session groups:</p>
      <ul>
        <li>Service sessions: $str: string_of_int (Eliommod_sessiongroups.Serv.nb_of_groups ())$</li>
        <li>Volatile data sessions: $str: string_of_int (Eliommod_sessiongroups.Data.nb_of_groups ())$</li>
        <li>Persistent data sessions: $str: string_of_int persgrplength$</li>
      </ul>
   </body>
 </html>
>>)))

(* Lwt threads:
       $str:(string_of_int (Lwt_unix.inputs_length ()))$
             lwt threads waiting for inputs<br/>
       $str:(string_of_int (Lwt_unix.outputs_length ()))$
               lwt threads waiting for outputs<br/>
       $str:(string_of_int (Lwt_unix.wait_children_length ()))$
               lwt threads waiting for children<br/>
       $str:(string_of_int (Lwt_unix.sleep_queue_size ()))$
               sleeping lwt threads<br/>
       $str:(string_of_int (Lwt_unix.get_new_sleeps ()))$ new sleeps.<br/>
                   *)
