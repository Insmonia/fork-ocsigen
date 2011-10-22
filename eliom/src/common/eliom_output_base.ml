(* Ocsigen
 * http://www.ocsigen.org
 * Module Eliom_predefmod
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

open Eliom_pervasives

open Eliom_services
open Eliom_parameters

type appl_service = [ `Appl ]
type http_service = [ `Http ]
type non_caml_service = [ appl_service | http_service ]

type basic_input_type =
    [ `Hidden
    | `Password
    | `Submit
    | `Text
    ]

type full_input_type =
    [ `Button
    | `Checkbox
    | `File
    | `Hidden
    | `Image
    | `Password
    | `Radio
    | `Reset
    | `Submit
    | `Text
    ]

type button_type =
    [ `Button
    | `Reset
    | `Submit
    ]

(*****************************************************************************)
(*****************************************************************************)

module Html5_forms_base = struct

  open HTML5.M
  open HTML5_types

  type uri = HTML5_types.uri
  type pcdata_elt = HTML5_types.pcdata HTML5.M.elt

  type form_elt = HTML5_types.form HTML5.M.elt
  type form_content_elt = HTML5_types.form_content HTML5.M.elt
  type form_content_elt_list = HTML5_types.form_content HTML5.M.elt list
  type form_attrib_t = HTML5_types.form_attrib HTML5.M.attrib list

  type 'a a_elt = 'a HTML5_types.a HTML5.M.elt
  type 'a a_elt_list = 'a HTML5_types.a HTML5.M.elt list
  type 'a a_content_elt = 'a HTML5.M.elt
  type 'a a_content_elt_list = 'a HTML5.M.elt list
  type a_attrib_t = HTML5_types.a_attrib HTML5.M.attrib list

  type link_elt = HTML5_types.link HTML5.M.elt
  type link_attrib_t = HTML5_types.link_attrib HTML5.M.attrib list

  type script_elt = HTML5_types.script HTML5.M.elt
  type script_attrib_t = HTML5_types.script_attrib HTML5.M.attrib list

  type textarea_elt = HTML5_types.textarea HTML5.M.elt
  type textarea_attrib_t = HTML5_types.textarea_attrib HTML5.M.attrib list

  type input_elt = HTML5_types.input HTML5.M.elt
  type input_attrib_t = HTML5_types.input_attrib HTML5.M.attrib list

  type select_elt = HTML5_types.select HTML5.M.elt
  type select_content_elt = HTML5_types.select_content HTML5.M.elt
  type select_content_elt_list = HTML5_types.select_content HTML5.M.elt list
  type select_attrib_t = HTML5_types.select_attrib HTML5.M.attrib list

  type button_elt = HTML5_types.button HTML5.M.elt
  type button_content_elt = HTML5_types.button_content HTML5.M.elt
  type button_content_elt_list = HTML5_types.button_content HTML5.M.elt list
  type button_attrib_t = HTML5_types.button_attrib HTML5.M.attrib list

  type option_elt = HTML5_types.selectoption HTML5.M.elt
  type option_elt_list = HTML5_types.selectoption HTML5.M.elt list
  type optgroup_attrib_t = [ HTML5_types.common | `Disabled ] HTML5.M.attrib list
  type option_attrib_t = HTML5_types.option_attrib HTML5.M.attrib list

  type input_type_t = full_input_type
  type raw_input_type_t = full_input_type
  type button_type_t = button_type

  let hidden = `Hidden
  let checkbox = `Checkbox
  let radio = `Radio
  let submit = `Submit
  let file = `File
  let image = `Image

  let buttonsubmit = `Submit

  let uri_of_string = uri_of_string

  let empty_seq = []
  let cons_form a l = a::l

  let map_option = List.map
  let map_optgroup f a l = ((f a), List.map f l)
  let select_content_of_option a = (a :> select_content_elt)

  let make_pcdata s = pcdata s

  let make_a ?(a=[]) ?href (l : 'a a_content_elt_list) : 'a a_elt =
    let a = match href with
      | None -> a
      | Some href -> lazy_a_href href :: a
    in
    HTML5.M.a ~a l

  let make_empty_form_content () = p [pcdata ""] (**** � revoir !!!!! *)
  let remove_first = function
    | a::l -> a,l
    | [] -> (make_empty_form_content ()), []

  let make_get_form ?(a=[]) ~action elts : form_elt =
    let elts = Eliom_lazy.from_fun (fun () -> remove_first (Eliom_lazy.force elts)) in
    let elt1 = Eliom_lazy.from_fun (fun () -> fst (Eliom_lazy.force elts))
    and elts = Eliom_lazy.from_fun (fun () -> snd (Eliom_lazy.force elts)) in
    let r =
      lazy_form ~a:((a_method `Get)::(lazy_a_action action)::a) elt1 elts
    in
    r

  let make_post_form ?(a=[]) ~action ?id ?(inline = false) elts
      : form_elt =
    let aa = (match id with
    | None -> a
    | Some i -> (a_id i)::a)
    in
    let elts = Eliom_lazy.from_fun (fun () -> remove_first (Eliom_lazy.force elts)) in
    let elt1 = Eliom_lazy.from_fun (fun () -> fst (Eliom_lazy.force elts))
    and elts = Eliom_lazy.from_fun (fun () -> snd (Eliom_lazy.force elts)) in
    let r =
      lazy_form ~a:((HTML5.M.a_enctype "multipart/form-data")::
                (* Always Multipart!!! How to test if there is a file?? *)
                  (lazy_a_action action)::
                  (a_method `Post)::
                  (if inline then (a_class ["inline"])::aa else aa))
        elt1 elts
    in
    r

  let make_hidden_field content =
    let c = match content with
      | None -> []
      | Some c -> [c]
    in
    (div ~a:[a_class ["eliom_nodisplay"]] c :> form_content_elt)

  let make_input ?(a=[]) ?(checked=false) ~typ ?name ?src ?value () =
    let a2 = match value with
    | None -> a
    | Some v -> (a_value v)::a
    in
    let a2 = match name with
    | None -> a2
    | Some v -> (a_name v)::a2
    in
    let a2 = match src with
    | None -> a2
    | Some v -> (a_src v)::a2
    in
    let a2 = if checked then (a_checked `Checked)::a2 else a2 in
    input ~a:((a_input_type typ)::a2) ()

  let make_button ?(a = []) ~button_type ?name ?value c =
    let a = match value with
    | None -> a
    | Some v -> (a_text_value v)::a
    in
    let a = match name with
    | None -> a
    | Some v -> (a_name v)::a
    in
    button ~a:((a_button_type button_type)::a) c

  let make_textarea ?(a=[]) ~name ?(value="") ~rows ~cols () =
    let a3 = (a_name name)::a in
    textarea ~a:((a_rows rows)::(a_cols cols)::a3) (pcdata value)

  let make_select ?(a=[]) ~multiple ~name elt elts =
    let a = if multiple then (a_multiple `Multiple)::a else a in
    select ~a:((a_name name)::a) (elt::elts)

  let make_option ?(a=[]) ~selected ?value c =
    let a = match value with
    | None -> a
    | Some v -> (a_text_value v)::a
    in
    let a = if selected then (a_selected `Selected)::a else a in
    option ~a c

  let make_optgroup ?(a=[]) ~label elt elts =
    optgroup ~label ~a (elt::elts)

  let make_css_link ?(a=[]) ~uri () =
    link ~href:uri ~rel:[`Stylesheet]  ~a:((a_mime_type "text/css")::a) ()

  let make_js_script ?(a=[]) ~uri () =
    script ~a:(a_mime_type "text/javascript" :: a_src uri :: a) (pcdata "")

end

(*****************************************************************************)
(*****************************************************************************)

module Html5_forms_closed = Eliom_mkforms.MakeForms(Html5_forms_base)

(* As we want -> [> a ] elt and not -> [ a ] elt (etc.),
   we define a opening functor... *)

module Open_Html5_forms =

  functor (Html5_forms_closed : "sigs/eliom_html5_forms_closed.mli") -> (struct

    open HTML5.M
    open HTML5_types

    include Html5_forms_closed

    let a = (a :
	       ?absolute:bool ->
              ?absolute_path:bool ->
              ?https:bool ->
              ?a:a_attrib attrib list ->
              service:('get, unit, [< get_service_kind ],
                       [< suff ], 'gn, 'pn,
                       [< registrable ], 'return) service ->
              ?hostname:string ->
              ?port:int ->
              ?fragment:string ->
              ?keep_nl_params:[ `All | `Persistent | `None ] ->
              ?nl_params: Eliom_parameters.nl_params_set ->
              ?no_appl:bool ->
              'a HTML5.M.elt list -> 'get ->
              'a a HTML5.M.elt :>
		?absolute:bool ->
              ?absolute_path:bool ->
              ?https:bool ->
              ?a:a_attrib attrib list ->
              service:('get, unit, [< get_service_kind ],
                       [< suff ], 'gn, 'pn,
                       [< registrable ], 'return) service ->
              ?hostname:string ->
              ?port:int ->
              ?fragment:string ->
              ?keep_nl_params:[ `All | `Persistent | `None ] ->
              ?nl_params: Eliom_parameters.nl_params_set ->
              ?no_appl:bool ->
              'a HTML5.M.elt list -> 'get ->
              [> 'a a] HTML5.M.elt)

    let css_link = (css_link :
                      ?a:(link_attrib attrib list) ->
                     uri:uri -> unit -> link elt :>
                     ?a:(link_attrib attrib list) ->
                     uri:uri -> unit -> [> link ] elt)

    let js_script = (js_script :
                       ?a:(script_attrib attrib list) ->
                      uri:uri -> unit -> script elt :>
                      ?a:(script_attrib attrib list) ->
                      uri:uri -> unit -> [> script ] elt)

    let make_uri = (make_uri :
                      ?absolute:bool ->
                     ?absolute_path:bool ->
                     ?https:bool ->
                     service:('get, unit, [< get_service_kind ],
                              [< suff ], 'gn, unit,
                              [< registrable ], 'return) service ->
                     ?hostname:string ->
                     ?port:int ->
                     ?fragment:string ->
                     ?keep_nl_params:[ `All | `Persistent | `None ] ->
                     ?nl_params: Eliom_parameters.nl_params_set ->
                     'get -> HTML5_types.uri)

    let get_form = (get_form :
                      ?absolute:bool ->
                     ?absolute_path:bool ->
                     ?https:bool ->
                     ?a:form_attrib attrib list ->
                     service:('get, unit, [< get_service_kind ],
                              [<suff ], 'gn, 'pn,
                              [< registrable ], 'return) service ->
                     ?hostname:string ->
                     ?port:int ->
                     ?fragment:string ->
                     ?keep_nl_params:[ `All | `Persistent | `None ] ->
                     ?nl_params: Eliom_parameters.nl_params_set ->
                     ?no_appl:bool ->
		     ('gn -> form_content elt list) -> form elt :>
                     ?absolute:bool ->
                     ?absolute_path:bool ->
                     ?https:bool ->
                     ?a:form_attrib attrib list ->
                     service:('get, unit, [< get_service_kind ],
                              [<suff ], 'gn, 'pn,
                              [< registrable ], 'return) service ->
                     ?hostname:string ->
                     ?port:int ->
                     ?fragment:string ->
                     ?keep_nl_params:[ `All | `Persistent | `None ] ->
                     ?nl_params: Eliom_parameters.nl_params_set ->
                     ?no_appl:bool ->
                     ('gn -> form_content elt list) -> [> form ] elt)


    let lwt_get_form = (lwt_get_form :
                          ?absolute:bool ->
			 ?absolute_path:bool ->
			 ?https:bool ->
			 ?a:form_attrib attrib list ->
			 service:('get, unit, [< get_service_kind ],
                                  [<suff ], 'gn, 'pn,
                                  [< registrable ], 'return) service ->
			 ?hostname:string ->
			 ?port:int ->
			 ?fragment:string ->
			 ?keep_nl_params:[ `All | `Persistent | `None ] ->
			 ?nl_params: Eliom_parameters.nl_params_set ->
			 ?no_appl:bool ->
			 ('gn -> form_content elt list Lwt.t) -> form elt Lwt.t :>
			 ?absolute:bool ->
			 ?absolute_path:bool ->
			 ?https:bool ->
			 ?a:form_attrib attrib list ->
			 service:('get, unit, [< get_service_kind ],
                                  [<suff ], 'gn, 'pn,
                                  [< registrable ], 'return) service ->
			 ?hostname:string ->
			 ?port:int ->
			 ?fragment:string ->
			 ?keep_nl_params:[ `All | `Persistent | `None ] ->
			 ?nl_params: Eliom_parameters.nl_params_set ->
			 ?no_appl:bool ->
			 ('gn -> form_content elt list Lwt.t) ->
			 [> form ] elt Lwt.t)


    let post_form = (post_form :
                       ?absolute:bool ->
                      ?absolute_path:bool ->
                      ?https:bool ->
                      ?a:form_attrib attrib list ->
                      service:('get, 'post, [< post_service_kind ],
                               [< suff ], 'gn, 'pn,
                               [< registrable ], 'return) service ->
                      ?hostname:string ->
                      ?port:int ->
                      ?fragment:string ->
                      ?keep_nl_params:[ `All | `Persistent | `None ] ->
                      ?keep_get_na_params:bool ->
                      ?nl_params: Eliom_parameters.nl_params_set ->
                      ?no_appl:bool ->
                      ('pn -> form_content elt list) -> 'get -> form elt :>
                      ?absolute:bool ->
                      ?absolute_path:bool ->
                      ?https:bool ->
                      ?a:form_attrib attrib list ->
                      service:('get, 'post, [< post_service_kind ],
                               [< suff ], 'gn, 'pn,
                               [< registrable ], 'return) service ->
                      ?hostname:string ->
                      ?port:int ->
                      ?fragment:string ->
                      ?keep_nl_params:[ `All | `Persistent | `None ] ->
                      ?keep_get_na_params:bool ->
                      ?nl_params: Eliom_parameters.nl_params_set ->
                      ?no_appl:bool ->
                      ('pn -> form_content elt list) -> 'get -> [> form ] elt)

    let lwt_post_form = (lwt_post_form :
                           ?absolute:bool ->
                          ?absolute_path:bool ->
                          ?https:bool ->
                          ?a:form_attrib attrib list ->
                          service:('get, 'post, [< post_service_kind ],
                                   [< suff ], 'gn, 'pn,
                                   [< registrable ], 'return) service ->
                          ?hostname:string ->
                          ?port:int ->
                          ?fragment:string ->
                          ?keep_nl_params:[ `All | `Persistent | `None ] ->
                          ?keep_get_na_params:bool ->
                          ?nl_params: Eliom_parameters.nl_params_set ->
                          ?no_appl:bool ->
                          ('pn -> form_content elt list Lwt.t) ->
                          'get -> form elt Lwt.t :>
                          ?absolute:bool ->
                          ?absolute_path:bool ->
                          ?https:bool ->
                          ?a:form_attrib attrib list ->
                          service:('get, 'post, [< post_service_kind ],
                                   [< suff ], 'gn, 'pn,
                                   [< registrable ], 'return) service ->
                          ?hostname:string ->
                          ?port:int ->
                          ?fragment:string ->
                          ?keep_nl_params:[ `All | `Persistent | `None ] ->
                          ?keep_get_na_params:bool ->
                          ?nl_params: Eliom_parameters.nl_params_set ->
                          ?no_appl:bool ->
                          ('pn -> form_content elt list Lwt.t) -> 'get ->
                          [> form ] elt Lwt.t)

    let int_input = (int_input :
		       ?a:input_attrib attrib list -> input_type:full_input_type ->
		      ?name:'a -> ?value:int -> unit -> input elt :>
		      ?a:input_attrib attrib list -> input_type:[< full_input_type] ->
		      ?name:'a -> ?value:int -> unit -> [> input ] elt)

    let int32_input = (int32_input :
			 ?a:input_attrib attrib list -> input_type:full_input_type ->
			?name:'a -> ?value:int32 -> unit -> input elt :>
			?a:input_attrib attrib list -> input_type:[< full_input_type] ->
			?name:'a -> ?value:int32 -> unit -> [> input ] elt)

    let int64_input = (int64_input :
			 ?a:input_attrib attrib list -> input_type:full_input_type ->
			?name:'a -> ?value:int64 -> unit -> input elt :>
			?a:input_attrib attrib list -> input_type:[< full_input_type] ->
			?name:'a -> ?value:int64 -> unit -> [> input ] elt)

    let float_input = (float_input :
			 ?a:input_attrib attrib list -> input_type:full_input_type ->
			?name:'a -> ?value:float -> unit -> input elt :>
			?a:input_attrib attrib list -> input_type:[< full_input_type] ->
			?name:'a -> ?value:float -> unit -> [> input ] elt)

    let string_input = (string_input :
			  ?a:input_attrib attrib list -> input_type:full_input_type ->
			 ?name:'a -> ?value:string -> unit -> input elt :>
			 ?a:input_attrib attrib list -> input_type:[< full_input_type] ->
			 ?name:'a -> ?value:string -> unit -> [> input ] elt)

    let user_type_input = (user_type_input :
                             ('a -> string) ->
			    ?a:input_attrib attrib list -> input_type:full_input_type ->
			    ?name:'b -> ?value:'a -> unit -> input elt :>
                            ('a -> string) ->
			    ?a:input_attrib attrib list -> input_type:[< full_input_type] ->
			    ?name:'b -> ?value:'a -> unit -> [> input ] elt)

    let raw_input = (raw_input :
		       ?a:input_attrib attrib list -> input_type:full_input_type ->
		      ?name:string -> ?value:string -> unit -> input elt :>
		      ?a:input_attrib attrib list ->
		      input_type:[< full_input_type ] ->
		      ?name:string -> ?value:string -> unit -> [> input ] elt)

    let file_input = (file_input :
			?a:input_attrib attrib list -> name:'a ->
		       unit -> input elt :>
		       ?a:input_attrib attrib list -> name:'a ->
		       unit -> [> input ] elt)

    let image_input = (image_input :
			 ?a:input_attrib attrib list -> name:'a ->
			?src:uri -> unit -> input elt :>
			?a:input_attrib attrib list -> name:'a ->
			?src:uri -> unit -> [> input ] elt)

    let int_image_input = (int_image_input :
			     ?a:input_attrib attrib list ->
			    name:'a -> value:int ->
			    ?src:uri -> unit -> input elt :>
			    ?a:input_attrib attrib list ->
			    name:'a -> value:int ->
			    ?src:uri -> unit -> [> input ] elt)

    let int32_image_input = (int32_image_input :
			       ?a:input_attrib attrib list ->
			      name:'a -> value:int32 ->
			      ?src:uri -> unit -> input elt :>
			      ?a:input_attrib attrib list ->
			      name:'a -> value:int32 ->
			      ?src:uri -> unit -> [> input ] elt)

    let int64_image_input = (int64_image_input :
			       ?a:input_attrib attrib list ->
			      name:'a -> value:int64 ->
			      ?src:uri -> unit -> input elt :>
			      ?a:input_attrib attrib list ->
			      name:'a -> value:int64 ->
			      ?src:uri -> unit -> [> input ] elt)

    let float_image_input = (float_image_input :
			       ?a:input_attrib attrib list ->
			      name:'a -> value:float ->
			      ?src:uri -> unit -> input elt :>
			      ?a:input_attrib attrib list ->
			      name:'a -> value:float ->
			      ?src:uri -> unit -> [> input ] elt)

    let string_image_input = (string_image_input :
				?a:input_attrib attrib list ->
			       name:'a -> value:string ->
			       ?src:uri -> unit -> input elt :>
			       ?a:input_attrib attrib list ->
			       name:'a -> value:string ->
			       ?src:uri -> unit -> [> input ] elt)

    let user_type_image_input = (user_type_image_input :
				   ('a -> string) ->
				  ?a:input_attrib attrib list ->
				  name:'b -> value:'a ->
				  ?src:uri -> unit -> input elt :>
				  ('a -> string) ->
				  ?a:input_attrib attrib list ->
				  name:'b -> value:'a ->
				  ?src:uri -> unit -> [> input ] elt)

    let raw_image_input = (raw_image_input :
			     ?a:input_attrib attrib list ->
			    name:string -> value:string -> ?src:uri -> unit -> input elt :>
			    ?a:input_attrib attrib list ->
			    name:string -> value:string -> ?src:uri -> unit -> [> input ] elt)

    let bool_checkbox = (bool_checkbox :
			   ?a:(input_attrib attrib list ) -> ?checked:bool ->
			  name:'a -> unit -> input elt :>
			  ?a:(input_attrib attrib list ) -> ?checked:bool ->
			  name:'a -> unit -> [> input ] elt)

    let int_checkbox = (int_checkbox :
			  ?a:input_attrib attrib list -> ?checked:bool ->
			 name:[ `Set of int ] param_name -> value:int -> unit -> input elt :>
			 ?a:input_attrib attrib list -> ?checked:bool ->
			 name:[ `Set of int ] param_name -> value:int -> unit -> [> input ] elt)

    let int32_checkbox = (int32_checkbox :
			    ?a:input_attrib attrib list -> ?checked:bool ->
			   name:[ `Set of int32 ] param_name -> value:int32 -> unit -> input elt :>
			   ?a:input_attrib attrib list -> ?checked:bool ->
			   name:[ `Set of int32 ] param_name -> value:int32 -> unit -> [> input ] elt)

    let int64_checkbox = (int64_checkbox :
			    ?a:input_attrib attrib list -> ?checked:bool ->
			   name:[ `Set of int64 ] param_name -> value:int64 -> unit -> input elt :>
			   ?a:input_attrib attrib list -> ?checked:bool ->
			   name:[ `Set of int64 ] param_name -> value:int64 -> unit -> [> input ] elt)

    let float_checkbox = (float_checkbox :
			    ?a:input_attrib attrib list -> ?checked:bool ->
			   name:[ `Set of float ] param_name -> value:float -> unit -> input elt :>
			   ?a:input_attrib attrib list -> ?checked:bool ->
			   name:[ `Set of float ] param_name -> value:float -> unit -> [> input ] elt)

    let string_checkbox = (string_checkbox :
			     ?a:input_attrib attrib list -> ?checked:bool ->
			    name:[ `Set of string ] param_name -> value:string -> unit -> input elt :>
			    ?a:input_attrib attrib list -> ?checked:bool ->
			    name:[ `Set of string ] param_name -> value:string -> unit -> [> input ] elt)

    let user_type_checkbox = (user_type_checkbox :
				('a -> string) ->
			       ?a:input_attrib attrib list -> ?checked:bool ->
			       name:[ `Set of 'a ] param_name -> value:'a -> unit -> input elt :>
			       ('a -> string) ->
			       ?a:input_attrib attrib list -> ?checked:bool ->
			       name:[ `Set of 'a ] param_name -> value:'a -> unit -> [> input ] elt)

    let raw_checkbox = (raw_checkbox :
			  ?a:input_attrib attrib list -> ?checked:bool ->
			 name:string -> value:string -> unit -> input elt :>
			 ?a:input_attrib attrib list -> ?checked:bool ->
			 name:string -> value:string -> unit -> [> input ] elt)


    let string_radio = (string_radio :
			  ?a:(input_attrib attrib list ) -> ?checked:bool ->
			 name:'a -> value:string -> unit -> input elt :>
			 ?a:(input_attrib attrib list ) -> ?checked:bool ->
			 name:'a -> value:string -> unit -> [> input ] elt)

    let int_radio = (int_radio :
                       ?a:(input_attrib attrib list ) -> ?checked:bool ->
		      name:'a -> value:int -> unit -> input elt :>
                      ?a:(input_attrib attrib list ) -> ?checked:bool ->
		      name:'a -> value:int -> unit -> [> input ] elt)

    let int32_radio = (int32_radio :
			 ?a:(input_attrib attrib list ) -> ?checked:bool ->
			name:'a -> value:int32 -> unit -> input elt :>
			?a:(input_attrib attrib list ) -> ?checked:bool ->
			name:'a -> value:int32 -> unit -> [> input ] elt)

    let int64_radio = (int64_radio :
			 ?a:(input_attrib attrib list ) -> ?checked:bool ->
			name:'a -> value:int64 -> unit -> input elt :>
			?a:(input_attrib attrib list ) -> ?checked:bool ->
			name:'a -> value:int64 -> unit -> [> input ] elt)

    let float_radio = (float_radio :
			 ?a:(input_attrib attrib list ) -> ?checked:bool ->
			name:'a -> value:float -> unit -> input elt :>
			?a:(input_attrib attrib list ) -> ?checked:bool ->
			name:'a -> value:float -> unit -> [> input ] elt)

    let user_type_radio = (user_type_radio :
			     ('a -> string) ->
                            ?a:(input_attrib attrib list ) -> ?checked:bool ->
			    name:'b -> value:'a -> unit -> input elt :>
			    ('a -> string) ->

                            ?a:(input_attrib attrib list ) -> ?checked:bool ->
			    name:'b -> value:'a -> unit -> [> input ] elt)

    let raw_radio = (raw_radio :
                       ?a:(input_attrib attrib list ) -> ?checked:bool ->
		      name:string -> value:string -> unit -> input elt :>
                      ?a:(input_attrib attrib list ) -> ?checked:bool ->
		      name:string -> value:string -> unit -> [> input ] elt)

    let textarea = (textarea :
		      ?a:textarea_attrib attrib list ->
		     name:'a -> ?value:string ->
		     rows:int -> cols:int ->
		     unit -> textarea elt :>
		     ?a:textarea_attrib attrib list ->
		     name:'a -> ?value:string ->
		     rows:int -> cols:int ->
		     unit -> [> textarea ] elt)

    let raw_textarea = (raw_textarea :
			  ?a:textarea_attrib attrib list ->
			 name:string -> ?value:string ->
			 rows:int -> cols:int ->
			 unit -> textarea elt :>
			 ?a:textarea_attrib attrib list ->
			 name:string -> ?value:string ->
			 rows:int -> cols:int ->
			 unit -> [> textarea ] elt)

    let raw_select = (raw_select :
			?a:select_attrib attrib list ->
		       name:string ->
		       string select_opt ->
		       string select_opt list -> select elt :>
		       ?a:select_attrib attrib list ->
		       name:string ->
		       string select_opt ->
		       string select_opt list -> [> select ] elt)

    let int_select = (int_select :
			?a:select_attrib attrib list ->
		       name:'a ->
		       int select_opt ->
		       int select_opt list -> select elt :>
		       ?a:select_attrib attrib list ->
		       name:'a ->
		       int select_opt ->
		       int select_opt list -> [> select ] elt)

    let int32_select = (int32_select :
			  ?a:select_attrib attrib list ->
			 name:'a ->
			 int32 select_opt ->
			 int32 select_opt list -> select elt :>
			 ?a:select_attrib attrib list ->
			 name:'a ->
			 int32 select_opt ->
			 int32 select_opt list -> [> select ] elt)

    let int64_select = (int64_select :
			  ?a:select_attrib attrib list ->
			 name:'a ->
			 int64 select_opt ->
			 int64 select_opt list -> select elt :>
			 ?a:select_attrib attrib list ->
			 name:'a ->
			 int64 select_opt ->
			 int64 select_opt list -> [> select ] elt)

    let float_select = (float_select :
			  ?a:select_attrib attrib list ->
			 name:'a ->
			 float select_opt ->
			 float select_opt list -> select elt :>
			 ?a:select_attrib attrib list ->
			 name:'a ->
			 float select_opt ->
			 float select_opt list -> [> select ] elt)

    let string_select = (string_select :
			   ?a:select_attrib attrib list ->
			  name:'a ->
			  string select_opt ->
			  string select_opt list -> select elt :>
			  ?a:select_attrib attrib list ->
			  name:'a ->
			  string select_opt ->
			  string select_opt list -> [> select ] elt)

    let user_type_select = (user_type_select :
			      ('a -> string) ->
			     ?a:select_attrib attrib list ->
			     name:'b ->
			     'a select_opt ->
			     'a select_opt list -> select elt :>
			     ('a -> string) ->
			     ?a:select_attrib attrib list ->
			     name:'b ->
			     'a select_opt ->
			     'a select_opt list -> [> select ] elt)


    let raw_multiple_select = (raw_multiple_select :
				 ?a:select_attrib attrib list ->
				name:string ->
				string select_opt ->
				string select_opt list -> select elt :>
				?a:select_attrib attrib list ->
				name:string ->
				string select_opt ->
				string select_opt list -> [> select ] elt)

    let int_multiple_select = (int_multiple_select :
				 ?a:select_attrib attrib list ->
				name:'a ->
				int select_opt ->
				int select_opt list -> select elt :>
				?a:select_attrib attrib list ->
				name:'a ->
				int select_opt ->
				int select_opt list -> [> select ] elt)

    let int32_multiple_select = (int32_multiple_select :
				   ?a:select_attrib attrib list ->
				  name:'a ->
				  int32 select_opt ->
				  int32 select_opt list -> select elt :>
				  ?a:select_attrib attrib list ->
				  name:'a ->
				  int32 select_opt ->
				  int32 select_opt list -> [> select ] elt)

    let int64_multiple_select = (int64_multiple_select :
				   ?a:select_attrib attrib list ->
				  name:'a ->
				  int64 select_opt ->
				  int64 select_opt list -> select elt :>
				  ?a:select_attrib attrib list ->
				  name:'a ->
				  int64 select_opt ->
				  int64 select_opt list -> [> select ] elt)

    let float_multiple_select = (float_multiple_select :
				   ?a:select_attrib attrib list ->
				  name:'a ->
				  float select_opt ->
				  float select_opt list -> select elt :>
				  ?a:select_attrib attrib list ->
				  name:'a ->
				  float select_opt ->
				  float select_opt list -> [> select ] elt)

    let string_multiple_select = (string_multiple_select :
				    ?a:select_attrib attrib list ->
				   name:'a ->
				   string select_opt ->
				   string select_opt list -> select elt :>
				   ?a:select_attrib attrib list ->
				   name:'a ->
				   string select_opt ->
				   string select_opt list -> [> select ] elt)

    let user_type_multiple_select = (user_type_multiple_select :
				       ('a -> string) ->
				      ?a:select_attrib attrib list ->
				      name:'b ->
				      'a select_opt ->
				      'a select_opt list -> select elt :>
				      ('a -> string) ->
				      ?a:select_attrib attrib list ->
				      name:'b ->
				      'a select_opt ->
				      'a select_opt list -> [> select ] elt)

    type button_type =
	[ `Button
	| `Reset
	| `Submit
	]

    let string_button = (string_button :
			   ?a:button_attrib attrib list ->
			  name:'a -> value:string ->
			  button_content elt list -> button elt :>
			  ?a:button_attrib attrib list ->
			  name:'a -> value:string ->
			  button_content elt list -> [> button ] elt)

    let int_button = (int_button :
			?a:button_attrib attrib list ->
		       name:'a -> value:int ->
		       button_content elt list -> button elt :>
		       ?a:button_attrib attrib list ->
		       name:'a -> value:int ->
		       button_content elt list -> [> button ] elt)

    let int32_button = (int32_button :
			  ?a:button_attrib attrib list ->
			 name:'a -> value:int32 ->
			 button_content elt list -> button elt :>
			 ?a:button_attrib attrib list ->
			 name:'a -> value:int32 ->
			 button_content elt list -> [> button ] elt)

    let int64_button = (int64_button :
			  ?a:button_attrib attrib list ->
			 name:'a -> value:int64 ->
			 button_content elt list -> button elt :>
			 ?a:button_attrib attrib list ->
			 name:'a -> value:int64 ->
			 button_content elt list -> [> button ] elt)

    let float_button = (float_button :
			  ?a:button_attrib attrib list ->
			 name:'a -> value:float ->
			 button_content elt list -> button elt :>
			 ?a:button_attrib attrib list ->
			 name:'a -> value:float ->
			 button_content elt list -> [> button ] elt)

    let user_type_button = (user_type_button :
			      ('a -> string) ->
			     ?a:button_attrib attrib list ->
			     name:'b -> value:'a ->
			     button_content elt list -> button elt :>
			     ('a -> string) ->
			     ?a:button_attrib attrib list ->
			     name:'b -> value:'a ->
			     button_content elt list -> [> button ] elt)

    let raw_button = (raw_button :
			?a:button_attrib attrib list ->
		       button_type:button_type ->
		       name:string -> value:string ->
		       button_content elt list -> button elt :>
		       ?a:button_attrib attrib list ->
		       button_type:[< button_type ] ->
		       name:string -> value:string ->
		       button_content elt list -> [> button ] elt)

    let button = (button :
		    ?a:button_attrib attrib list ->
		   button_type:button_type ->
		   button_content elt list -> button elt :>
		   ?a:button_attrib attrib list ->
		   button_type:[< button_type ] ->
		   button_content elt list -> [> button ] elt)

end)

module Html5_forms = struct

  module Forms = Open_Html5_forms(Html5_forms_closed)

  include Forms

  let make_info ~https kind service =
    Eliom_lazy.from_fun
      (fun () ->
	if not (Eliom_services.xhr_with_cookies service)
	then None
	else Some (`A, Eliom_uri.make_cookies_info (https, service)))

  let a ?absolute ?absolute_path ?https ?(a = []) ~service ?hostname ?port ?fragment
        ?keep_nl_params ?nl_params
	?(no_appl = false)
	content getparams =
    let a =
      if no_appl
      then a
      else
	let info = make_info ~https `A service in
	HTML5.M.a_onclick (XML.event_of_service info) :: a
    in
    Forms.a
      ?absolute ?absolute_path ?https ~a ~service ?hostname ?port ?fragment
      ?keep_nl_params ?nl_params ~no_appl
      content getparams

  let get_form
      ?absolute ?absolute_path ?https ?(a = []) ~service ?hostname ?port ?fragment
      ?keep_nl_params ?nl_params
      ?(no_appl = false) contents =
    let a =
      if no_appl
      then a
      else
	let info = make_info ~https `Form_get service in
	HTML5.M.a_onsubmit (XML.event_of_service info) :: a
    in
    Forms.get_form
      ?absolute ?absolute_path ?https ~a ~service ?hostname ?port ?fragment
      ?keep_nl_params ?nl_params contents

  let lwt_get_form
      ?absolute ?absolute_path ?https ?(a = []) ~service ?hostname ?port ?fragment
      ?keep_nl_params ?nl_params
      ?(no_appl = false) contents =
    let a =
      if no_appl
      then a
      else
	let info = make_info ~https `Form_get service in
	HTML5.M.a_onsubmit (XML.event_of_service info) :: a
    in
    Forms.lwt_get_form
      ?absolute ?absolute_path ?https ~a ~service ?hostname ?port ?fragment
      ?nl_params ?keep_nl_params
      contents

  let post_form
      ?absolute ?absolute_path ?https ?(a = []) ~service ?hostname ?port ?fragment
      ?keep_nl_params ?keep_get_na_params ?nl_params
      ?(no_appl = false) contents getparams =
    let a =
      if no_appl
      then a
      else
	let info = make_info ~https `Form_post service in
	HTML5.M.a_onsubmit (XML.event_of_service info) :: a
    in
    Forms.post_form
      ?absolute ?absolute_path ?https ~a ~service ?hostname ?port ?fragment
      ?keep_nl_params ?keep_get_na_params ?nl_params
      contents getparams

  let lwt_post_form
      ?absolute ?absolute_path ?https ?(a = []) ~service ?hostname ?port ?fragment
      ?keep_nl_params ?keep_get_na_params ?nl_params
      ?(no_appl = false) contents getparams =
    let a =
      if no_appl
      then a
      else
	let info = make_info ~https `Form_post service in
	HTML5.M.a_onsubmit (XML.event_of_service info) :: a
    in
    Forms.lwt_post_form
      ?absolute ?absolute_path ?https ~a ~service ?hostname ?port ?fragment
      ?keep_nl_params ?keep_get_na_params ?nl_params
      contents getparams


end
