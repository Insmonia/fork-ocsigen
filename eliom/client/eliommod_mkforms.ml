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

let (>>=) = Lwt.bind
let (>|=) = Lwt.(>|=)

let make_a_with_onclick
    make_a
    register_event
    ?a
    ?cookies_info
    _
    href
    content
    =
  let node = make_a ?a ?onclick:None ?href:(Some href) content in
  register_event ?keep_default:(Some false) node "onclick"
    (fun () -> Eliom_client.change_page_uri ?cookies_info href)
    ();
  node

let make_get_form_with_onsubmit
    make_get_form
    register_event
    ?a
    ?cookies_info
    _
    uri
    field
    fields
    =
  let node = make_get_form ?a ~action:uri ?onsubmit:None field fields in
  register_event ?keep_default:(Some false) node "onsubmit"
    (fun () -> Eliom_client.change_page_get_form ?cookies_info
      (Js.Unsafe.coerce (XHTML5.M.toelt node)) uri)
    ();
  node

let make_post_form_with_onsubmit
    make_post_form
    register_event
    ?a
    ?cookies_info
    _
    uri
    field
    fields
    =
  let node = make_post_form ?a ~action:uri ?onsubmit:None field fields in
  register_event ?keep_default:(Some false) node "onsubmit"
    (fun () -> Eliom_client.change_page_post_form ?cookies_info
      (Js.Unsafe.coerce (XHTML5.M.toelt node)) uri)
    ();
  node



(*POSTtabcookies* forms with tab cookies in POST params:

let tab_cookie_class = "__eliom_tab_cookies"

let remove_tab_cookie_fields (node : #Dom.node Js.t) =
  let children = node##childNodes in
  let toremove = ref [] in
  for i = children##length - 1 downto 0 do
      let child =
        Js.Optdef.get (children##item (i)) (fun () -> assert false) in
      if child##nodeType = Dom.ELEMENT
      then let child' : #Dom.element Js.t = Js.Unsafe.coerce child in
           let classes = Ocsigen_lib.split
             ~multisep:true ' ' (Js.to_string child'##className)
           in
           if List.mem tab_cookie_class classes
           then toremove := child::!toremove
  done;
  List.iter (fun c -> ignore (node##removeChild (c))) !toremove

let add_tab_cookie_fields l node =
  if l = []
  then ()
  else
    let my_div = 
      XHTML5.M.div ~a:[XHTML5.M.a_class [tab_cookie_class;
                                         Eliom_common.nodisplay_class_name]]
        (List.map (fun (n, v) ->
          XHTML5.M.input ~a:[XHTML5.M.a_input_type `Hidden;
                             XHTML5.M.a_name n;
                             XHTML5.M.a_value v] ())
           l)
    in
    ignore (node##appendChild (XHTML5.M.toelt my_div))



let add_tab_cookies_to_form' l node =
  remove_tab_cookie_fields node;
  add_tab_cookie_fields l node;
  Lwt_js.sleep 0.7 >|=
  (* PC we need to sleep to wait for the form submition to finish. If
     we do an xhr during the submition, chrome destroy the xhr object
     and raise a javascript exception. The right way to circumvent
     this is to check for availability of FormData, wich is handled by
     recent chrome.
     This wait is useless for other browsers *)
  Eliom_client_comet.restart

let add_tab_cookies_to_post_form' node =
  let action = node##action in
  let (https, path) = Eliom_request.get_cookie_info_for_uri_js action in
  let cookies = Eliommod_client_cookies.get_cookies_to_send https path in
  let l = [(Eliom_common.tab_cookies_param_name,
            Ocsigen_lib.encode_form_value cookies)]
  in
  add_tab_cookies_to_form' l node

let add_tab_cookies_to_post_form node () =
  let node : #Dom.node Js.t = Js.Unsafe.coerce (XHTML5.M.toelt node) in
  add_tab_cookies_to_post_form' node

let add_tab_cookies_to_get_form' node =
  (* we transform the form into POST form:
     - to avoid long URLs (not supported by (old?) IE)
     - ...
  *)
  node##_method <- "post";
  let action = node##action in
  let (https, path) = Eliom_request.get_cookie_info_for_uri_js action in
  let cookies = Eliommod_client_cookies.get_cookies_to_send https path in
  let l = [(Eliom_common.to_be_considered_as_get_param_name, "1");
           (Eliom_common.tab_cookies_param_name,
            Ocsigen_lib.encode_form_value cookies)]
  in
  add_tab_cookies_to_form' l node

let add_tab_cookies_to_get_form node () =
  let node = Js.Unsafe.coerce (XHTML5.M.toelt node) in
  add_tab_cookies_to_get_form' node

let make_get_form_with_post_tab_cookies
    make_get_form register_event add_tab_cookies_to_get_form _
    ?a ~action i1 i =
  let node =
    make_get_form ?a ~action ?onsubmit:(None : XML.event option) i1 i in
  register_event node "onsubmit" (add_tab_cookies_to_get_form node);
  node

let make_post_form_with_post_tab_cookies
    make_post_form register_event add_tab_cookies_to_post_form _
    ?a ~action i1 i =
  let node = make_post_form ?a ~action ?onsubmit:None
    ?id:None ?inline:None i1 i
  in
  register_event node "onsubmit" (add_tab_cookies_to_post_form node);
  node



let _ =
  Eliommod_cli.register_closure
    Eliom_client_types.add_tab_cookies_to_get_form_id
    (fun node ->
      let node = (Eliommod_cli.unwrap_node node :> Dom.node Js.t) in
      ignore (add_tab_cookies_to_get_form (XHTML5.M.tot node) ());
      Js._true)

let _ =
  Eliommod_cli.register_closure
    Eliom_client_types.add_tab_cookies_to_post_form_id
    (fun node ->
      let node = (Eliommod_cli.unwrap_node node :> Dom.node Js.t) in
      ignore (add_tab_cookies_to_post_form (XHTML5.M.tot node) ());
      Js._true)

*)
