(* Ocsigen
 * http://www.ocsigen.org
 * Module Eliom_output
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

(** Predefined modules for generating forms and
    registering handlers, for several types of pages:
    Applications, HTML pages typed with polymorphic variants,
    untyped (text) pages, actions, redirections, files ...
*)

open Eliom_pervasives

type ('a, 'b) kind
type 'a application_content = [ `Appl of 'a ]
type block_content
type browser_content = [ `Browser ]
type 'a caml_content
type unknown_content

type appl_service = [ `Appl ]
type http_service = [ `Http ]
type non_caml_service = [ appl_service | http_service ]

type 'a application_name

(** {2 Creating links and forms with HTML5.M} *)

(** Eliom service registration and forms creation for HTML5 page *)
module Html5 : sig

  (** {2 Service registration } *)

  include "sigs/eliom_html5_reg.mli"

  (** {2 Forms creation } *)

  include "sigs/eliom_html5_forms.mli"

end

(** Eliom service registration for HTML5 page *)
module Html5_registration : "sigs/eliom_html5_reg.mli"

(** Eliom forms creation for HTML5 *)
module Html5_forms : "sigs/eliom_html5_forms.mli"

(** {2 Creating links and forms with XHTML.M} *)

(** Eliom service registration and forms creation for XHTML page *)
module Xhtml : sig

  (** {2 Service registration } *)

  include "sigs/eliom_xhtml_reg.mli"

  (** {2 Forms creation } *)

  include "sigs/eliom_xhtml_forms.mli"

end

(** Eliom service registration for XHTML page *)
module Xhtml_registration : "sigs/eliom_xhtml_reg.mli"

(** Eliom forms creation for XHTML page *)
module Xhtml_forms : "sigs/eliom_xhtml_forms.mli"

(** {3 Eliom client/server applications} *)

module type APPL_PARAMS = sig

  (** Name of the application.
      Two distincts applications must have distincts names.
  *)
  val application_name : string

end

(** Parameters for an Eliom application service *)
type appl_service_options =
    {
      do_not_launch : bool; (** Do not launch the client side program
                                if it is not already launched.
                                Default: [false]. *)
    }
(**
    If you set do_not_launch to [true] for a service, it will send the page
    without launching the client side program if it is not already launched.
    Use this if some of your pages are not using the client side program,
    and you want to make them load faster (for example the main page).
*)

val default_appl_service_options : appl_service_options

module type Eliom_appl = sig

  (** unique type *)
  type appl

  include "sigs/eliom_reg.mli"
    subst type page    := HTML5_types.html HTML5.M.elt
      and type options := appl_service_options
      and type return  := appl_service
      and type result  := (appl application_content, appl_service) kind

  (** Unique identifier for this application.
      It is the application name.
      Warning: do not mix up with the "application instance id",
      that is unique for each instance of the application.
  *)
  val application_name : string
  val typed_name : appl application_name

  val application_script : unit -> [> `Script ] HTML5.M.elt

end

module Eliom_appl (Appl_params : APPL_PARAMS) : Eliom_appl

(** {3 Module to register subpages of type [block]} *)

(** Eliom service registration and forms creation for fragment of
    HTML5 page *)
module Blocks5 : "sigs/eliom_reg.mli"
  subst type page    := HTML5_types.body_content HTML5.M.elt list
    and type options := unit
    and type return  := http_service
    and type result  := (block_content, http_service) kind

(** Use this module for example for XMLHttpRequests for block tags (e.g. <div>) *)

(** Eliom service registration and forms creation for fragment of
    XHTML page *)
module Blocks : "sigs/eliom_reg.mli"
  subst type page    := XHTML_types.body_content XHTML.M.elt list
    and type options := unit
    and type return  := http_service
    and type result  := (block_content, http_service) kind

(** {3 Functor to create modules to register subpages for other XML
    types.} *)

module Make_TypedXML_Registration
  (XML: XML_sigs.Iterable)
  (TypedXML: XML_sigs.TypedXML with module XML := XML)
  (E : sig type content end) :

  "sigs/eliom_reg.mli"
      subst type page    := E.content TypedXML.elt list
	and type options := unit
	and type return  := http_service
        and type result  := (block_content, http_service) kind

(** {2 Untyped pages} *)

(** {3 Module to create forms and register untyped HTML pages} *)

module HtmlText : sig

  (** {2 Service registration } *)

  include "sigs/eliom_reg.mli"
  subst type page    := string
    and type options := unit
    and type return  := http_service
    and type result  := (browser_content, http_service) kind

  (** {2 Forms creation } *)

  include "sigs/eliom_forms.mli"
  subst type uri := string
    and type pcdata_elt := string

    and type form_elt := string
    and type form_content_elt := string
    and type form_content_elt_list := string
    and type form_attrib_t := string

    and type 'a a_elt := string
    and type 'a a_content_elt := string
    and type 'a a_content_elt_list := string
    and type a_attrib_t := string

    and type link_elt := string
    and type link_attrib_t := string

    and type script_elt := string
    and type script_attrib_t := string

    and type textarea_elt := string
    and type textarea_attrib_t := string

    and type input_elt := string
    and type input_attrib_t := string

    and type select_elt := string
    and type select_attrib_t := string

    and type button_elt := string
    and type button_content_elt := string
    and type button_content_elt_list := string
    and type button_attrib_t := string

    and type optgroup_attrib_t := string
    and type option_attrib_t := string

    and type input_type_t := string
    and type raw_input_type_t := string
    and type button_type_t := string

end

(** {3 Module to register untyped CSS pages} *)
module CssText : "sigs/eliom_reg.mli"
  subst type page    := string
    and type options := unit
    and type return  := http_service
    and type result  := (browser_content, http_service) kind

(** {3 Module to register untyped text pages} *)
module Text : "sigs/eliom_reg.mli"
  subst type page    := string * string
    and type options := unit
    and type return  := http_service
    and type result  := (unknown_content, http_service) kind

(** The first string is the content, the second is the content type,
    for example "text/html" *)

(** {2 Other kinds of services} *)

(** Actions do not generate any page. They do something,
    then the page corresponding to the URL (without POST parameters
    or non-attached parameters or coservice parameters) is sent to the browser.

    If you want to give information to the handler that will be called
    to reload the page, put it in an Eliom reference with scope [`Request].

    If you give the optional parameter
    [~options:`NoReload] to the registration function, no page will be sent.
 *)
module Action : "sigs/eliom_reg.mli"
 subst type page    := unit
   and type options := [ `Reload | `NoReload ]
   and type return  := http_service
   and type result  := (browser_content, http_service) kind

(** Like actions, but the page is not reloaded. Just do something and do
   not generate any page. To be used carefully. Probably not usefull at all.
   (Same as {!Action} with [`NoReload] option).
 *)
module Unit : "sigs/eliom_reg.mli"
  subst type page    := unit
    and type options := unit
    and type return  := http_service
    and type result  := (browser_content, http_service) kind

(** Allows to create redirections towards another service.
   A 301 or 307 code is sent to the browser to ask it to redo the request to
   another URL.

   To choose if you want permanent or temporary redirection, use
   the [options] parameter of registration functions.
   For example: [register ~options:`Temporary ...].
*)
module Redirection : "sigs/eliom_reg_alpha_return.mli"
  subst type page :=
    (unit, unit, Eliom_services.get_service_kind,
     [ `WithoutSuffix ],
     unit, unit, Eliom_services.registrable, 'b)
      Eliom_services.service
    and type options := [ `Temporary | `Permanent ]
    and type return  := 'b
    and type result  := ('a, 'b) kind

(** Allows to create redirections towards other URLs.
   A 301 or 307 code is sent to the browser to ask it to redo the request to
   another URL.

   Warning: The URL given must be an absolute URI.

   To choose if you want permanent or temporary redirection, use
   the [options] parameter of registration functions.
   For example: [register ~options:`Temporary ...].
 *)
module String_redirection : "sigs/eliom_reg.mli"
  subst type page    := Url.uri
    and type options := [ `Temporary | `Permanent ]
    and type return  := http_service
    and type result  := (browser_content, http_service) kind

(** Allows to send files. The content is the name of the file to send. *)
module Files : sig
  include "sigs/eliom_reg.mli"
    subst type page    := string
      and type options := unit
      and type return  := http_service
      and type result  := (browser_content, http_service) kind
  val check_file : string -> bool
  (** [check_file file] is true if [Files.send file] would effectively
      return the file (i.e. the file is present and readable ) *)
end

(** Allows to create services that choose dynamically what they want
    to send. The content is created using for example
    {!Html5_forms.send} or {!Text.send} functions.  *)
module Any : "sigs/eliom_reg_alpha_return.mli"
  subst type page    := ('a, 'b) kind
	and type options := unit
	and type return  := 'b
        and type result  := ('a, 'b) kind

val appl_self_redirect :
  ('page -> ([< 'a application_content | browser_content ], [< non_caml_service ]) kind Lwt.t) -> 'page ->
  ('appl application_content, appl_service) kind Lwt.t
(** [appl_self_redirect send page] does a redirection to the same
    address with same parameters ( GET and POST ). It allows using
    different kind content ( browser and applications ) with
    Any. It always leaves the current application. All parameters
    are sent another time. Files can't be sent by a
    redirection. Content returned by [appl_self_redirect] is always
    marked as not cacheable by the browser. *)

(** Allows to send raw data using Ocsigen's streams.
    The content is a pair containing:

    - a list of functions returning a stream and the
    function to close it,
    - the  content type string to send.

    Streams are opened by calling the functions in the list, and closed
    automatically by a call to the closing function.
    If something goes wrong, the current stream is closed,
    and the following are not opened.
*)
module Streamlist : "sigs/eliom_reg.mli"
  subst type page    := (((unit -> string Ocsigen_stream.t Lwt.t) list) * string)
    and type options := unit
    and type return  := http_service
    and type result  := (unknown_content, http_service) kind

(** Allows to register services that send caml values.
    Note that this kind of services are most of the time
    POST coservices, and GET (co)services are probably useless here.
*)
module Caml : "sigs/eliom_reg_simpl.mli"
  subst type page    := 'return
    and type options := unit
    and type return  := 'return Eliom_parameters.caml
    and type result  := ('return caml_content, 'return Eliom_parameters.caml) kind

module Customize :
  functor (B : sig type options type return type page type result end) ->
  functor (R : "sigs/eliom_reg.mli" subst type options := B.options
				      and type return  := B.return
				      and type page    := B.page
                                      and type result  := B.result) ->
  functor (T : sig type page val translate : page -> B.page Lwt.t end) ->
    "sigs/eliom_reg.mli"
      subst type page    := T.page
        and type options := B.options
        and type return  := B.return
        and type result  := B.result

(** {2 Using your own error pages} *)

(** Allows to use your own error pages
    (404, or any exception during page generation).

    {e Warning: This functions must be called when the site
    information is available, that is, either
    during a request or during the initialisation phase of the site.
    Otherwise, it will raise the exception
    {!Eliom_common.Eliom_site_information_not_available}.
    If you are using static linking, you must delay the call to this function
    until the configuration file is read, using
    {!Eliom_services.register_eliom_module}. Otherwise you will also get
    this exception.}
 *)
val set_exn_handler : (exn -> (browser_content, http_service) kind Lwt.t) -> unit

(**/**)

val cast_unknown_content_kind :
  (unknown_content, http_service) kind -> ('a, http_service) kind
(** If you know that the content you generated using [Text.send] or
    [Streamlist.send] is the same as some other kind, you can cast
    it with [cast_unknown_content_kind] for use with [Any] module.*)

val cast_http_result : Ocsigen_http_frame.result -> ('a, 'b) kind
(** [cast_http_result] should only be used to register new output modules *)
