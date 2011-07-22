open Eliom_pervasives
open Eliom_services
open Eliom_parameters

val send :
  ?options:options ->
  ?charset:string ->
  ?code: int ->
  ?content_type:string ->
  ?headers: Http_headers.t ->
  page ->
  result Lwt.t

    (** Register a service with the associated handler function.
	[register s t f] will associate the service [s] to the function [f].
	[f] is the function that creates a page, called {e service handler}.

	The handler function takes two parameters.
	- The second and third ones are respectively GET and POST parameters.

	For example if [t] is [Eliom_parameters.int "s"], then [ 'get] is [int].

	The [?scope] optional parameter is [Eliom_common.global] by default, which means that the
	service will be registered in the global table and be available to any client.
	If you want to restrict the visibility of the service to a browser session,
	use [~scope:Eliom_common.session].
	If you want to restrict the visibility of the service to a group of sessions,
	use [~scope:Eliom_common.session_group].
	If you have a client side Eliom program running, and you want to restrict
	the visibility of the service to this instance of the program,
	use [~scope:Eliom_common.client_process]. You can create new scopes with
	[Eliom_common.create_session_group_scope], [Eliom_common.create_session_scope]
	and [Eliom_common.create_client_process_scope] if you want several service
	sessions on the same site.

	If the same service is registered several times with different visibilities,
	Eliom will choose the service for handling a request in that order:
	[`Client_process], [`Session], [`Session_group] and finally [`Global]. It means for example
	that you can register a specialized version of a public service for a session.

	Warning: All public services created during initialization must be
	registered in the public table during initialisation, never after,

	Registering services and coservices is always done in memory as there is
	no means of marshalling closures.

	If you register new services dynamically, be aware that they will disappear
	if you stop the server. If you create dynamically new URLs,
	be very careful to re-create these URLs when you relaunch the server,
	otherwise, some external links or bookmarks may be broken!

	Some output modules (for example Redirectmod) define their own options
	for that function. Use the [?options] parameter to set them.

	The optional parameters [?charset], [?code], [?content_type] and [?headers]
	can be used to modify the HTTP answer sent by Eliom. Use this with care.

	If [~secure_session] is false when the protocol is https, the service will be
	registered in the unsecure session,
	otherwise in the secure session with https, the unsecure one with http.
	(Secure session means that Eliom will ask the browser to send the cookie
	only through HTTPS). It has no effect for scope [`Global].

	Note that in the case of CSRF safe coservices, parameters
	[?scope] and [?secure_session] must match exactly the scope
	and secure option specified while creating the CSRF safe service.
	Otherwise, the registration will fail
	with {Eliom_services.Wrong_session_table_for_CSRF_safe_coservice}
    *)
val register :
  ?scope:[<Eliom_common.scope] ->
  ?options:options ->
  ?charset:string ->
  ?code: int ->
  ?content_type:string ->
  ?headers: Http_headers.t ->
  ?secure_session:bool ->
  service:('get, 'post,
           [< internal_service_kind ],
           [< suff ], 'gn, 'pn, [ `Registrable ], return) service ->
  ?error_handler:((string * exn) list -> page Lwt.t) ->
  ('get -> 'post -> page Lwt.t) ->
  unit

(** Same as [service] followed by [register] *)
val register_service :
  ?scope:[<Eliom_common.scope] ->
  ?options:options ->
  ?charset:string ->
  ?code: int ->
  ?content_type:string ->
  ?headers: Http_headers.t ->
  ?secure_session:bool ->
  ?https:bool ->
  ?priority:int ->
  path:Url.path ->
  get_params:('get, [< suff ] as 'tipo, 'gn) params_type ->
  ?error_handler:((string * exn) list -> page Lwt.t) ->
  ('get -> unit -> page Lwt.t) ->
  ('get, unit,
   [> `Attached of
       ([> `Internal of [> `Service ] ], [> `Get]) a_s ],
   'tipo, 'gn, unit,
   [> `Registrable ], return) service


(** Same as [coservice] followed by [register] *)
val register_coservice :
  ?scope:[<Eliom_common.scope] ->
  ?options:options ->
  ?charset:string ->
  ?code: int ->
  ?content_type:string ->
  ?headers: Http_headers.t ->
  ?secure_session:bool ->
  ?name: string ->
  ?csrf_safe: bool ->
  ?csrf_scope: [<Eliom_common.user_scope] ->
  ?csrf_secure: bool ->
  ?max_use:int ->
  ?timeout:float ->
  ?https:bool ->
  fallback:(unit, unit,
            [ `Attached of ([ `Internal of [ `Service ] ], [`Get]) a_s ],
            [ `WithoutSuffix ] as 'tipo,
            unit, unit, [< registrable ], return)
    service ->
  get_params:
    ('get, [`WithoutSuffix], 'gn) params_type ->
  ?error_handler:((string * exn) list -> page Lwt.t) ->
  ('get -> unit -> page Lwt.t) ->
  ('get, unit,
   [> `Attached of
       ([> `Internal of [> `Coservice ] ], [> `Get]) a_s ],
   'tipo, 'gn, unit,
   [> `Registrable ], return)
    service

(** Same as [coservice'] followed by [register] *)
val register_coservice' :
  ?scope:[<Eliom_common.scope] ->
  ?options:options ->
  ?charset:string ->
  ?code: int ->
  ?content_type:string ->
  ?headers: Http_headers.t ->
  ?secure_session:bool ->
  ?name: string ->
  ?csrf_safe: bool ->
  ?csrf_scope: [<Eliom_common.user_scope] ->
  ?csrf_secure: bool ->
  ?max_use:int ->
  ?timeout:float ->
  ?https:bool ->
  get_params:
    ('get, [`WithoutSuffix] as 'tipo, 'gn) params_type ->
  ?error_handler:((string * exn) list -> page Lwt.t) ->
  ('get -> unit -> page Lwt.t) ->
  ('get, unit,
   [> `Nonattached of [> `Get] na_s ],
   'tipo, 'gn, unit, [> `Registrable ], return)
    service


(** Same as [post_service] followed by [register] *)
val register_post_service :
  ?scope:[<Eliom_common.scope] ->
  ?options:options ->
  ?charset:string ->
  ?code: int ->
  ?content_type:string ->
  ?headers: Http_headers.t ->
  ?secure_session:bool ->
  ?https:bool ->
  ?priority:int ->
  fallback:('get, unit,
            [ `Attached of
                ([ `Internal of
                    ([ `Service | `Coservice ] as 'kind) ], [`Get]) a_s ],
            [< suff ] as 'tipo, 'gn,
            unit, [< `Registrable ], 'return2) (* 'return2 <> return *)
    service ->
  post_params:('post, [ `WithoutSuffix ], 'pn) params_type ->
  ?error_handler:((string * exn) list -> page Lwt.t) ->
  ('get -> 'post -> page Lwt.t) ->
  ('get, 'post, [> `Attached of
      ([> `Internal of 'kind ], [> `Post]) a_s ],
   'tipo, 'gn, 'pn, [> `Registrable ], return)
    service

(** Same as [post_coservice] followed by [register] *)
val register_post_coservice :
  ?scope:[<Eliom_common.scope] ->
  ?options:options ->
  ?charset:string ->
  ?code: int ->
  ?content_type:string ->
  ?headers: Http_headers.t ->
  ?secure_session:bool ->
  ?name: string ->
  ?csrf_safe: bool ->
  ?csrf_scope: [<Eliom_common.user_scope] ->
  ?csrf_secure: bool ->
  ?max_use:int ->
  ?timeout:float ->
  ?https:bool ->
  fallback:('get, unit ,
            [ `Attached of
                ([ `Internal of [< `Service | `Coservice ] ], [`Get]) a_s ],
            [< suff ] as 'tipo,
            'gn, unit, [< `Registrable ], return)
    service ->
  post_params:('post, [ `WithoutSuffix ], 'pn) params_type ->
  ?error_handler:((string * exn) list -> page Lwt.t) ->
  ('get -> 'post -> page Lwt.t) ->
  ('get, 'post,
   [> `Attached of
       ([> `Internal of [> `Coservice ] ], [> `Post]) a_s ],
   'tipo, 'gn, 'pn, [> `Registrable ], return)
    service


(** Same as [post_coservice'] followed by [register] *)
val register_post_coservice' :
  ?scope:[<Eliom_common.scope] ->
  ?options:options ->
  ?charset:string ->
  ?code: int ->
  ?content_type:string ->
  ?headers: Http_headers.t ->
  ?secure_session:bool ->
  ?name: string ->
  ?csrf_safe: bool ->
  ?csrf_scope: [<Eliom_common.user_scope] ->
  ?csrf_secure: bool ->
  ?max_use:int ->
  ?timeout:float ->
  ?keep_get_na_params:bool ->
  ?https:bool ->
  post_params:('post, [ `WithoutSuffix ], 'pn) params_type ->
  ?error_handler:((string * exn) list -> page Lwt.t) ->
  (unit -> 'post -> page Lwt.t) ->
  (unit, 'post, [> `Nonattached of [> `Post] na_s ],
   [ `WithoutSuffix ], unit, 'pn,
   [> `Registrable ], return)
    service

