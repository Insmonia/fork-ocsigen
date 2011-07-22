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

open Eliom_pervasives

(* == Closure *)

let closure_table  : (int64, poly -> unit) Hashtbl.t = Hashtbl.create 0
let register_closure id (f : 'a -> unit) =
  Hashtbl.add closure_table id (Obj.magic f : poly -> unit)
let find_closure = Hashtbl.find closure_table

(* == Process nodes (a.k.a. nodes with a unique Dom instance on each client) *)

let (register_node, find_node) =
  let process_nodes : (string, Dom.node Js.t) Hashtbl.t = Hashtbl.create 0 in
  let find id =
    let node = Hashtbl.find process_nodes id in
    if String.lowercase (Js.to_string node##nodeName) = "script" then
      (* We don't wan't to reexecute "unique" script... *)
      (Dom_html.document##createTextNode (Js.string "") :> Dom.node Js.t)
    else
      node
  in
  let register id node = Hashtbl.add process_nodes id node in
  (register, find)

(* == Event *)

(* forward declaration... *)
let change_page_uri_ = ref (fun ?cookies_info href -> assert false)
let change_page_get_form_ = ref (fun ?cookies_info form href -> assert false)
let change_page_post_form_ = ref (fun ?cookies_info form href -> assert false)

let reify_caml_event node ce = match ce with
  | XML.CE_call_service (`A, cookies_info) ->
      (fun () ->
	let href = (Js.Unsafe.coerce node : Dom_html.anchorElement Js.t)##href in
	!change_page_uri_ ?cookies_info (Js.to_string href); false)
  | XML.CE_call_service (`Form_get, cookies_info) ->
      (fun () ->
	let form = (Js.Unsafe.coerce node : Dom_html.formElement Js.t) in
	let action = Js.to_string form##action in
	!change_page_get_form_ ?cookies_info form action; false)
  | XML.CE_call_service (`Form_post, cookies_info) ->
      (fun () ->
	let form = (Js.Unsafe.coerce node : Dom_html.formElement Js.t) in
	let action = Js.to_string form##action in
	!change_page_post_form_ ?cookies_info form action; false)
  | XML.CE_client_closure f ->
    (fun () -> try f (); true with False -> false)
  | XML.CE_registered_closure (id, args) ->
      try
	let f = find_closure id in
	(fun () -> try f args; true with False -> false)
      with Not_found ->
	Firebug.console##error(Printf.sprintf "Closure not found (%Ld)" id);
	(fun () -> false)

let reify_event node ev = match ev with
  | XML.Raw ev -> Js.Unsafe.variable ev
  | XML.Caml ce -> reify_caml_event node ce

let register_event_handler node (name, ev) =
  let f = reify_caml_event node ev in
  assert(String.sub name 0 2 = "on");
  Js.Unsafe.set node (Js.string name)
    (Dom_html.handler (fun _ -> Js.bool (f ())))

(* == Register nodes id and event in the orginal Dom. *)

let rec relink_dom node (id, attribs, childrens_ref_tree) =
  List.iter
    (register_event_handler (Js.Unsafe.coerce node : Dom_html.element Js.t))
    attribs;
  begin match id with
  | None -> ()
  | Some id ->
      try
	let pnode = find_node id in
	Js.Opt.iter (node##parentNode)
	  (fun parent -> Dom.replaceChild parent pnode node)
      with Not_found ->
	register_node id node
  end;
  let childrens =
    List.filter
      (fun node -> node##nodeType = Dom.ELEMENT)
      (Dom.list_of_nodeList (node##childNodes)) in
  relink_dom_list childrens childrens_ref_tree

and relink_dom_list nodes ref_trees =
  match nodes, ref_trees with
  | node :: nodes, XML.Ref_node ref_tree :: ref_trees ->
      relink_dom node ref_tree;
      relink_dom_list nodes ref_trees
  | nodes, XML.Ref_empty i :: ref_trees ->
      relink_dom_list (List.chop i nodes) ref_trees
  | _, [] -> ()
  | [], _ ->
    Firebug.console##error(Js.string "Incorrect sparse tree.")

(* == Convertion from OCaml XML.elt nodes to native JavaScript Dom nodes *)

module Html5 = struct

  let rebuild_attrib node a = match a with
    | XML.AFloat (name, f) -> Js.Unsafe.set node (Js.string name) (Js.Unsafe.inject f)
    | XML.AInt (name, i) -> Js.Unsafe.set node (Js.string name) (Js.Unsafe.inject i)
    | XML.AStr (name, s) ->
      node##setAttribute(Js.string name, Js.string s)
    | XML.AStrL (XML.Space, name, sl) ->
      node##setAttribute
	(Js.string name,
	 Js.string (match sl with
	   | [] -> ""
	   | a::l -> List.fold_left (fun r s -> r ^ " " ^ s) a l))
    | XML.AStrL (XML.Comma, name, sl) ->
      node##setAttribute
	(Js.string name,
	 Js.string (match sl with
	   | [] -> ""
	   | a::l -> List.fold_left (fun r s -> r ^ "," ^ s) a l))

  let rebuild_rattrib node ra = match XML.racontent ra with
    | XML.RA a -> rebuild_attrib node a
    | XML.RACamlEvent ev -> register_event_handler node ev

  let rec rebuild_node elt =
    match XML.get_unique_id elt with
      | None -> raw_rebuild_node (XML.content elt)
      | Some id ->
	  try (find_node id :> Dom.node Js.t)
	  with Not_found ->
	  let node = raw_rebuild_node (XML.content elt) in
	  register_node id node;
	  node

  and raw_rebuild_node = function
    | XML.Empty
    | XML.Comment _ ->
	(* FIXME *)
	(Dom_html.document##createTextNode (Js.string "") :> Dom.node Js.t)
    | XML.EncodedPCDATA s
    | XML.PCDATA s -> (Dom_html.document##createTextNode (Js.string s) :> Dom.node Js.t)
    | XML.Entity s -> assert false (* FIXME *)
    | XML.Leaf (name,attribs) ->
      let node = Dom_html.document##createElement (Js.string name) in
      List.iter (rebuild_rattrib node) attribs;
      (node :> Dom.node Js.t)
    | XML.Node (name,attribs,childrens) ->
      let node = Dom_html.document##createElement (Js.string name) in
      List.iter (rebuild_rattrib node) attribs;
      List.iter (fun c -> Dom.appendChild node (rebuild_node c)) childrens;
      (node :> Dom.node Js.t)

  let rebuild_node elt = Js.Unsafe.coerce (rebuild_node (HTML5.M.toelt elt))

  let of_element = rebuild_node

  let of_html = rebuild_node
  let of_head = rebuild_node
  let of_link = rebuild_node
  let of_title = rebuild_node
  let of_meta = rebuild_node
  let of_base = rebuild_node
  let of_style = rebuild_node
  let of_body = rebuild_node
  let of_form = rebuild_node
  let of_optgroup = rebuild_node
  let of_option = rebuild_node
  let of_select = rebuild_node
  let of_input = rebuild_node
  let of_textarea = rebuild_node
  let of_button = rebuild_node
  let of_label = rebuild_node
  let of_fieldset = rebuild_node
  let of_legend = rebuild_node
  let of_ul = rebuild_node
  let of_ol = rebuild_node
  let of_dl = rebuild_node
  let of_li = rebuild_node
  let of_div = rebuild_node
  let of_p = rebuild_node
  let of_heading = rebuild_node
  let of_blockquote = rebuild_node
  let of_pre = rebuild_node
  let of_br = rebuild_node
  let of_hr = rebuild_node
  let of_a = rebuild_node
  let of_img = rebuild_node
  let of_object = rebuild_node
  let of_param = rebuild_node
  let of_area = rebuild_node
  let of_map = rebuild_node
  let of_script = rebuild_node
  let of_td = rebuild_node
  let of_tr = rebuild_node
  let of_col = rebuild_node
  let of_tfoot = rebuild_node
  let of_tbody = rebuild_node
  let of_thead = rebuild_node
  let of_caption = rebuild_node
  let of_table = rebuild_node
  let of_canvas = rebuild_node
  let of_iframe = rebuild_node

end

(* == XHR *)

let current_fragment = ref ""
let url_fragment_prefix = "!"
let url_fragment_prefix_with_sharp = "#!"

let create_request_
    ?absolute ?absolute_path ?https ~service ?hostname ?port ?fragment
    ?keep_nl_params ?nl_params ?keep_get_na_params
    get_params post_params =
  match Eliom_services.get_get_or_post service with
    | `Get ->
        let uri =
          Eliom_uri.make_string_uri
            ?absolute ?absolute_path ?https
            ~service
            ?hostname ?port ?fragment ?keep_nl_params ?nl_params get_params
        in
        `Get uri
    | `Post ->
        let path, get_params, fragment, post_params =
          Eliom_uri.make_post_uri_components
            ?absolute ?absolute_path ?https
            ~service
            ?hostname ?port ?fragment ?keep_nl_params ?nl_params
            ?keep_get_na_params get_params post_params
        in
        let uri =
          Eliom_uri.make_string_uri_from_components (path, get_params, fragment)
        in
        `Post (uri, post_params)



let exit_to
    ?absolute ?absolute_path ?https ~service ?hostname ?port ?fragment
    ?keep_nl_params ?nl_params ?keep_get_na_params
    get_params post_params =
  (match create_request_
     ?absolute ?absolute_path ?https ~service ?hostname ?port ?fragment
     ?keep_nl_params ?nl_params ?keep_get_na_params
     get_params post_params
   with
     | `Get uri -> Eliom_request.redirect_get uri
     | `Post (uri, post_params) -> Eliom_request.redirect_post uri post_params)


(** This will change the URL, without doing a request.
    As browsers do not not allow to change the URL,
    we write the new URL in the fragment part of the URL.
    A script must do the redirection if there is something in the fragment.
    Usually this function is only for internal use.
*)
let change_url_string uri =
  current_fragment := url_fragment_prefix_with_sharp^uri;
  Dom_html.window##location##hash <- Js.string (url_fragment_prefix^uri)

let change_url
(*VVV is it safe to have absolute URLs? do we accept non absolute paths? *)
    ?absolute ?absolute_path ?https ~service ?hostname ?port ?fragment
    ?keep_nl_params ?nl_params ?keep_get_na_params
    get_params post_params =
(*VVV only for GET services? *)
  let uri =
    (match create_request_
       ?absolute ?absolute_path ?https ~service ?hostname ?port ?fragment
       ?keep_nl_params ?nl_params ?keep_get_na_params
       get_params post_params
     with
       | `Get uri -> uri
       | `Post (uri, post_params) -> uri)
  in
  change_url_string uri

let loading_phase = ref true
let load_end = Lwt_condition.create ()
let on_unload_scripts = ref []
let at_exit_scripts = ref []

(* BEGIN FORMDATA HACK: This is only needed if FormData is not available in the browser.
   When it will be commonly available, remove all sections marked by "FORMDATA HACK" !
   Notice: this hack is used to circumvent a limitation in FF4 implementation of formdata:
     if the user click on a button in a form, formdatas created in the onsubmit callback normaly contains the value of the button. ( it is the behaviour of chromium )
     in FF4, it is not the case: we must do this hack to find wich button was clicked.

   This is implemented in:
   * this file -> here and called in load_eliom_data
   * Eliom_request: in send_post_form
   * in js_of_ocaml, module Form: the code to emulate FormData *)

let onclick_on_body_handler event =
  (match Dom_html.tagged (Dom_html.eventTarget event) with
    | Dom_html.Button button ->
	(Js.Unsafe.variable "window")##eliomLastButton <- Some button;
    | Dom_html.Input input when input##_type = Js.string "submit" ->
	(Js.Unsafe.variable "window")##eliomLastButton <- Some input;
    | _ ->
	(Js.Unsafe.variable "window")##eliomLastButton <- None);
  Js._true

let add_onclick_events () =
  ignore (Dom_html.addEventListener ( Dom_html.window##document##body )
	    Dom_html.Event.click ( Dom_html.handler onclick_on_body_handler )
	    Js._true : Dom_html.event_listener_id);
  true

(* END FORMDATA HACK *)

let broadcast_load_end () =
  loading_phase := false;
  Lwt_condition.broadcast load_end ();
  true

let load_eliom_data page =
  let tab_cookies = unmarshal_js_var "eliom_cookies" in
  Eliommod_cookies.update_cookie_table tab_cookies;
  loading_phase := true;
  let js_data = Eliom_unwrap.unwrap (unmarshal_js_var "eliom_data") in
  relink_dom_list
    [(page :> Dom.node Js.t)]
    [js_data.Eliom_types.ejs_ref_tree];
  Eliom_request_info.set_session_info js_data.Eliom_types.ejs_sess_info;
  change_url_string js_data.Eliom_types.ejs_url;
  let on_load =
    List.map
      (reify_event Dom_html.document##documentElement)
      js_data.Eliom_types.ejs_onload in
  let on_unload =
    List.map
      (reify_event Dom_html.document##documentElement)
      js_data.Eliom_types.ejs_onunload in
  on_unload_scripts := [fun () -> List.for_all (fun f -> f ())
  on_unload];
  add_onclick_events :: on_load @ [broadcast_load_end]

let wait_load_end () =
  if !loading_phase
  then Lwt_condition.wait load_end
  else Lwt.return ()

let on_unload f =
  on_unload_scripts :=
    (fun () -> try f(); true with False -> false) :: !on_unload_scripts

let get_head_and_body page =
  match Dom.list_of_nodeList page##childNodes with
  | [_; head; body] ->
     (* First node is ocsigen advertisement *)
     (Js.Unsafe.coerce head : Dom_html.headElement Js.t),
     (Js.Unsafe.coerce body : Dom_html.bodyElement Js.t)
  | _ -> assert false

let get_data_script page =
  let head, _ = get_head_and_body page in
  match Dom.list_of_nodeList head##childNodes with
    | _ :: _ :: data_script :: _ ->
      (Js.Unsafe.coerce data_script : Dom_html.scriptElement Js.t)
    | _ -> assert false

let set_content content =
  ignore (List.for_all (fun f -> f ()) !on_unload_scripts);
  on_unload_scripts := [];
  (* Hack to make the result considered as DOM : *)
  let fake_page = Dom_html.createHtml Dom_html.document in
  fake_page##innerHTML <- Js.string content;
  let data_script = get_data_script fake_page in
  ignore (Js.Unsafe.eval_string (Js.to_string data_script##innerHTML));
  let on_load = load_eliom_data fake_page in
  let head, body = get_head_and_body fake_page in
  Dom.replaceChild
    (Dom_html.document##documentElement)
    head (Dom_html.document##head);
  Dom.replaceChild
    (Dom_html.document##documentElement)
    body (Dom_html.document##body);
  ignore (List.for_all (fun f -> f ()) on_load);
  Lwt.return ()

let change_page
    ?absolute ?absolute_path ?https ~service ?hostname ?port ?fragment
    ?keep_nl_params ?nl_params ?keep_get_na_params
    get_params post_params =

  if not (Eliom_services.xhr_with_cookies service)
  then
    Lwt.return
      (exit_to
         ?absolute ?absolute_path ?https ~service ?hostname ?port ?fragment
	 ?keep_nl_params ?nl_params ?keep_get_na_params
         get_params post_params)
  else
    lwt r = match
        create_request_
          ?absolute ?absolute_path ?https ~service ?hostname ?port ?fragment
	  ?keep_nl_params ?nl_params ?keep_get_na_params
          get_params post_params
     with
       | `Get uri ->
         Eliom_request.http_get
           ~expecting_process_page:true
           ?cookies_info:(Eliom_uri.make_cookies_info (https, service)) uri []
       | `Post (uri, p) ->
         Eliom_request.http_post
           ~expecting_process_page:true
           ?cookies_info:(Eliom_uri.make_cookies_info (https, service)) uri p in
    set_content r

let change_page_uri ?cookies_info ?(get_params = []) uri =
  lwt r = Eliom_request.http_get
    ~expecting_process_page:true ?cookies_info uri get_params
  in
  set_content r

let change_page_get_form ?cookies_info form uri =
  let form = Js.Unsafe.coerce form in
  lwt r = Eliom_request.send_get_form 
    ~expecting_process_page:true ?cookies_info form uri
  in
  set_content r

let change_page_post_form ?cookies_info form uri =
  let form = Js.Unsafe.coerce form in
  lwt r = Eliom_request.send_post_form
      ~expecting_process_page:true ?cookies_info form uri
  in
  set_content r

let _ =
  change_page_uri_ :=
    (fun ?cookies_info href ->
       ignore(change_page_uri ?cookies_info href));
  change_page_get_form_ :=
    (fun ?cookies_info form href ->
       ignore(change_page_get_form ?cookies_info form href));
  change_page_post_form_ :=
    (fun ?cookies_info form href ->
       ignore(change_page_post_form ?cookies_info form href))

let call_service
    ?absolute ?absolute_path ?https ~service ?hostname ?port ?fragment
    ?keep_nl_params ?nl_params ?keep_get_na_params
    get_params post_params =
  (match create_request_
     ?absolute ?absolute_path ?https ~service ?hostname ?port ?fragment
     ?keep_nl_params ?nl_params ?keep_get_na_params
     get_params post_params
   with
     | `Get uri ->
	 Eliom_request.http_get
         ?cookies_info:(Eliom_uri.make_cookies_info (https, service)) uri []
     | `Post (uri, post_params) ->
       Eliom_request.http_post
         ?cookies_info:(Eliom_uri.make_cookies_info (https, service))
	 uri post_params)


let call_caml_service
    ?absolute ?absolute_path ?https ~service ?hostname ?port ?fragment
    ?keep_nl_params ?nl_params ?keep_get_na_params
    get_params post_params =
  lwt s =
    call_service
      ?absolute ?absolute_path ?https ~service ?hostname ?port ?fragment
      ?keep_nl_params ?nl_params ?keep_get_na_params
      get_params post_params in
  Lwt.return (Eliom_unwrap.unwrap (Marshal.from_string (Url.decode s) 0))



(*****************************************************************************)
(* Make the back button work when only the fragment has changed ... *)
(*VVV We check the fragment every t second ... :-( *)

let write_fragment s = Dom_html.window##location##hash <- Js.string s

let read_fragment () = Js.to_string Dom_html.window##location##hash


let (fragment, set_fragment_signal) = React.S.create (read_fragment ())

let rec fragment_polling () =
  lwt () = Lwt_js.sleep 0.2 in
  let new_fragment = read_fragment () in
  set_fragment_signal new_fragment;
  fragment_polling ()

let _ = fragment_polling ()

let auto_change_page fragment =
  ignore
    (let l = String.length fragment in
     if (l = 0) || ((l > 1) && (fragment.[1] = '!'))
     then
       if fragment <> !current_fragment
       then
         (
         current_fragment := fragment;
         let uri =
           match l with
             | 2 -> "./" (* fix for firefox *)
             | 0 | 1 -> Eliom_request_info.full_uri
             | _ -> String.sub fragment 2 ((String.length fragment) - 2)
         in
         lwt r = Eliom_request.http_get ~expecting_process_page:true uri [] in
	 set_content r
	 )
       else Lwt.return ()
     else Lwt.return ())

let _ = React.E.map auto_change_page (React.S.changes fragment)
