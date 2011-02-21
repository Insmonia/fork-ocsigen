(* BEGIN INTERFACE *)
(*
   Copyright (C) 2004 by Thorsten Ohl <ohl@physik.uni-wuerzburg.de>
   Copyright (C) 2007 by Vincent Balat, Gabriel Kerneis
   Copyright (C) 2010 by Cecile Herbelin

   XHTML is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   XHTML is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  *)

(* IDEAS:
      The [a_] prefix would have to be maintained and the
   only advantage are a potentially better mapping of the XHTML modularization
   to O'Caml modules. *)

(** Typesafe constructors for XHTML 1.1 documents.
    @see <http://www.w3.org/TR/xhtml-modularization/abstract_modules.html> W3C Recommendation *)
open Xhtmltypes
module type T =
  sig

(** The elements, attributes, attribute types and data types are given names
    that match the names in the W3C recommendation as closely as allowed by
    a strict typing discipline and the lexical conventions of O'Caml:
    {ul
      {- {e elements} are implemented as O'Caml constructors with the same name as
         in the W3C recommendation.  The domain and codomain are specified as ['a elt],
         where ['a] is a concrete phantom type build out of polymorphic variants.}
      {- {e attributes} are implemented as O'Caml constructors with [a_] prefixed to the
         name.  The name is the same as in the W3C recommendation, unless an additional
         prefix is required to disambiguate:
         {ul
           {- [a_fs_rows] and [a_fs_cols] instead of [a_rows] and [a_cols] for framesets,
              because of the different argument types.}}}
      {- {e attribute types} are implemented as O'Caml types that all have the same names
         as in the W3C recommendation, but are all lowercase.}
      {- {e data types} are also implemented as O'Caml types that all have the same names
         as in the W3C recommendation and are again all lowercase.}}

    Finite sets of alternatives are mapped to polymorphic variants.

    The phantom type is always the {e most general} required by any (supported)
    version of the standard.  Type discipline is enforced by exporting or not-exporting
    the corresponding constructor.  

    The type defining group of html elements are in {!Xhtmltypes}
*)

    (** An abstract type for URI. 
        @deprecated Provided for backward-compatibility. You should directly use {!Uri}'s type and functions for URI management.
    *)
    type uri = Uri.uri
    val uri_of_string : string -> uri
    val string_of_uri : uri -> string


(** {1 Common Attributes} *)

    type +'a attrib
    type +'a attribs
    val to_xmlattribs : 'a attrib list -> XML.attrib list (* VB *)

    (** ['a] is known as a {i phantom type}.  The implementation is
       actually monomorphic (the different element types are distinguished
       by a homogeneous variable, such as their textual representation)
       and the type variable [`a] is just used by the type checker.

       NB: It might be possible to use polymorphic variants directly, without
       phantom types, but the implementation is likely to be more involved. *)

(** {2 Core} *)

    val a_class : nmtokens -> [>`Class] attrib
(** This attribute assigns a class name or set of class names to an
    element. Any number of elements may be assigned the same class
    name or names.  *)

    val a_id : id -> [>`Id] attrib
(** This attribute assigns a name to an element. This name must be
    unique in a document. *)

    val a_title : cdata -> [>`Title] attrib
(** This attribute offers advisory information about the element for
    which it is set. *)

(** Values of the title attribute may be rendered by user agents in a
    variety of ways. For instance, visual browsers frequently display
    the title as a {i tool tip} (a short message that appears when the
    pointing device pauses over an object). Audio user agents may
    speak the title information in a similar context.  *)

(** The title attribute has an additional role when used with the [link]
    element to designate an external style sheet. Please consult the
    section on links and style sheets for details.  *)

(** {2 I18N} *)

    val a_xml_lang : nmtoken -> [>`XML_lang] attrib


(** {2 Style}
    The Style collection is deprecated, because the Style Attribute Module is
    deprecated. *)

(** {2 Events} *)

(** Javascript events *)

    val a_onblur : XML.event -> [>`OnBlur] attrib
    val a_onclick : XML.event -> [>`OnClick] attrib
    val a_ondblclick : XML.event -> [>`OnDblClick] attrib
    val a_onchange : XML.event -> [>`OnChange] attrib
    val a_onfocus : XML.event -> [>`OnFocus] attrib
    val a_onload : XML.event -> [>`OnLoad] attrib
    val a_onunload : XML.event -> [>`OnUnload] attrib
    val a_onreset : XML.event -> [>`OnReset] attrib
    val a_onselect : XML.event -> [>`OnSelect] attrib
    val a_onsubmit : XML.event -> [>`OnSubmit] attrib
    val a_onmousedown : XML.event -> [>`OnMouseDown] attrib
    val a_onmouseup : XML.event -> [>`OnMouseUp] attrib
    val a_onmouseover : XML.event -> [>`OnMouseOver] attrib
    val a_onmousemove : XML.event -> [>`OnMouseMove] attrib
    val a_onmouseout : XML.event -> [>`OnMouseOut] attrib
    val a_onkeypress : XML.event -> [>`OnKeyPress] attrib
    val a_onkeydown : XML.event -> [>`OnKeyDown] attrib
    val a_onkeyup : XML.event -> [>`OnKeyUp] attrib


(** {1 Modules, Element Sets and Attributes } *)


    val a_profile : uri -> [>`Profile] attrib
    val a_version : cdata -> [>`Version] attrib
    val a_xmlns : [< `W3_org_1999_xhtml ] -> [>`XMLns] attrib
    val a_cite : uri -> [>`Cite] attrib
    val a_xml_space : [< `Preserve ] -> [>`XML_space] attrib

    val a_accesskey : character -> [>`Accesskey] attrib
(** This attribute assigns an access key to an element. An access key
    is a single character from the document character
    set. NB: authors should consider the input method of the
    expected reader when specifying an accesskey. *)

    val a_charset : charset -> [>`Charset] attrib
(** This attribute specifies the character encoding of the resource
    designated by the link. Please consult the section on character
    encodings for more details. *)

    val a_accept_charset : charset -> [>`Accept_charset] attrib
    val a_accept : contenttype -> [>`Accept] attrib

    val a_href : uri -> [>`Href] attrib
(** This attribute specifies the location of a Web resource, thus
    defining a link between the current element (the source anchor)
    and the destination anchor defined by this attribute. *)

    val a_hreflang : languagecode -> [>`Hreflang] attrib
(** This attribute specifies the base language of the resource
    designated by href and may only be used when href is specified. *)

    val a_rel : linktypes -> [>`Rel] attrib
(** This attribute describes the relationship from the current document
    to the anchor specified by the href attribute. The value of this attribute
    is a space-separated list of link types. *)

    val a_rev : linktypes -> [>`Rev] attrib
(** This attribute is used to describe a reverse link from the anchor specified
    by the href attribute to the current document. The value of this attribute
    is a space-separated list of link types. *)

    val a_tabindex : number -> [>`Tabindex] attrib
(** This attribute specifies the position of the current element in
    the tabbing order for the current document. This value must be a
    number between 0 and 32767. User agents should ignore leading
    zeros. *)

    val a_type : contenttype -> [>`Type] attrib
(** This attribute gives an advisory hint as to the content type of
    the content available at the link target address. It allows user
    agents to opt to use a fallback mechanism rather than fetch the
    content if they are advised that they will get content in a
    content type they do not support.Authors who use this attribute
    take responsibility to manage the risk that it may become
    inconsistent with the content available at the link target
    address. *)

    val a_datetime : cdata -> [>`Datetime] attrib


(** {3 Bi-directional Text Attributes} *)

    val a_dir : [< `Ltr | `Rtl ] -> [>`Dir] attrib

(** {3 Forms attributes} *)

    val a_action : uri -> [>`Action] attrib
(** This attribute specifies a form processing agent. User agent
    behavior for a value other than an HTTP URI is undefined. *)

    val a_checked : [< `Checked ] -> [>`Checked] attrib
(** When the [type] attribute has the value ["radio"] or ["checkbox"],
    this boolean attribute specifies that the button is on. User
    agents must ignore this attribute for other control types. *)

    val a_cols : number -> [>`Cols] attrib
(** This attribute specifies the visible width in average character
    widths. Users should be able to enter longer lines than this, so
    user agents should provide some means to scroll through the
    contents of the control when the contents extend beyond the
    visible area. User agents may wrap visible text lines to keep long
    lines visible without the need for scrolling. *)

    val a_enctype : contenttype -> [>`Enctype] attrib
    val a_for : idref -> [>`For] attrib
    val a_maxlength : number -> [>`Maxlength] attrib
    val a_method : [< `Get | `Post ] -> [>`Method] attrib
    val a_multiple : [< `Multiple ] -> [>`Multiple] attrib

    val a_name : cdata -> [>`Name] attrib
(** This attribute assigns the control name. *)

    val a_rows : number -> [>`Rows] attrib
(** This attribute specifies the number of visible text lines. Users
    should be able to enter more lines than this, so user agents
    should provide some means to scroll through the contents of the
    control when the contents extend beyond the visible area. *)

    val a_selected : [< `Selected ] -> [>`Selected] attrib
(** When set, this boolean attribute specifies that this option is pre-selected. *)

    val a_size : number -> [>`Size] attrib
    val a_src : uri -> [>`Src] attrib
    val a_input_type :
        [< `Text | `Password | `Checkbox | `Radio | `Submit | `Reset | `Hidden | `File | `Image | `Button ] ->
          [>`Input_Type] attrib

    val a_value : cdata -> [>`Value] attrib
(** This attribute specifies the initial value of the control. If this
    attribute is not set, the initial value is set to the contents of
    the [option] element. *)

    val a_value_type : [< `Data | `Ref | `Object ] -> [>`Value_Type] attrib


    val a_disabled : [< `Disabled ] -> [>`Disabled] attrib
    val a_readonly : [< `Readonly ] -> [>`Readonly] attrib
    val a_button_type : [< `Button | `Submit | `Reset ] ->
      [>`Button_Type] attrib

    val a_label : text -> [> `Label ] attrib


(** {2 Attributes for tables} *)

    val a_abbr : text -> [>`Abbr] attrib
    val a_align : [< `Left | `Center | `Right | `Justify | `Char ] ->
      [>`Align] attrib
    val a_axis : cdata -> [>`Axis] attrib
    val a_colspan : number -> [>`Colspan] attrib
    val a_headers : idrefs -> [>`Headers] attrib
    val a_rowspan : number -> [>`Rowspan] attrib
    val a_scope : [< `Row | `Col | `Rowgroup | `Colgroup ] -> [>`Scope] attrib
    val a_summary : text -> [>`Summary] attrib
    val a_valign : [< `Top | `Middle | `Bottom | `Baseline ] ->
      [>`Valign] attrib

    val a_border : pixels -> [>`Border] attrib
    val a_cellpadding : length -> [>`Cellpadding] attrib
    val a_cellspacing : length -> [>`Cellspacing] attrib
    val a_datapagesize : cdata -> [>`Datapagesize] attrib
    val a_frame :
        [< `Void | `Above | `Below | `Hsides | `LHS | `RHS
        | `Vsides | `Box | `Border ] -> [>`Frame] attrib
    val a_rules : [< `None | `Groups | `Rows | `Cols | `All ] -> [>`Rules] attrib
    val a_char : character -> [>`Char] attrib
    val a_charoff : length -> [>`Charoff] attrib
    val a_span : number -> [>`Span] attrib

    val a_alt : text -> [>`Alt] attrib
    val a_height : length -> [>`Height] attrib
    val a_longdesc : uri -> [>`Longdesc] attrib
    val a_width : length -> [>`Width] attrib

(** {2 Attributes for client-side image map} *)

    type shape = [ `Rect | `Circle | `Poly | `Default ]
    val a_shape : shape -> [>`Shape] attrib
    val a_coords : int list -> [>`Coords] attrib
    val a_nohref : [< `Nohref ] -> [>`Nohref] attrib
    val a_usemap : idref -> [>`Usemap] attrib

(** {2 Attributes for Server-side Image Map} *)
    val a_ismap : [< `Ismap ] -> [>`Ismap] attrib

(** {2 Attributes for Object} *)

    val a_declare : [< `Declare ] -> [> `Declare ] attrib
    val a_classid : uri -> [> `Classid ] attrib
    val a_codebase : uri -> [> `Codebase ] attrib
    val a_data : uri -> [> `Data ] attrib
    val a_codetype : contenttype -> [>`Codetype] attrib
    val a_archive : uris -> [>`Archive] attrib
    val a_standby : text -> [>`Standby] attrib

(** {2 Attributes for Frames } *)

    val a_fs_rows : multilengths -> [>`FS_Rows] attrib
    val a_fs_cols : multilengths -> [>`FS_Cols] attrib
    val a_frameborder : [< `Zero | `One ] -> [>`Frameborder] attrib
    val a_marginheight : pixels -> [>`Marginheight] attrib
    val a_marginwidth : pixels -> [>`Marginwidth] attrib
    val a_noresize : [< `Noresize ] -> [>`Noresize] attrib
    val a_scrolling : [< `Yes | `No | `Auto ] -> [>`Scrolling] attrib

    val a_target : frametarget -> [>`Target] attrib


(** {2 Attributes for metadata} *)

    val a_content : cdata -> [>`Content] attrib
    val a_http_equiv : nmtoken -> [>`Http_equiv] attrib
    val a_scheme : cdata -> [>`Scheme] attrib


    val a_defer : [< `Defer ] -> [>`Defer] attrib

(** {3 Style attributes }*)

    val a_media : mediadesc -> [>`Media] attrib
    val a_style : string -> [>`Style_Attr] attrib


(** {1 Elements} *)

    type +'a elt

(** {2 Element Constructor Types} *)

    type ('a, 'b) nullary = ?a:('a attrib list) -> unit -> 'b elt
    type ('a, 'b, 'c) unary = ?a:('a attrib list) -> 'b elt -> 'c elt
    type ('a, 'b, 'c, 'd) binary = ?a:('a attrib list) -> 'b elt -> 'c elt -> 'd elt

    type ('a, 'b, 'c, 'd, 'e, 'f) quadry= ?a:('a attrib list) -> 'b elt -> 'c elt -> 'd elt -> 'e elt -> 'f elt


    type ('a, 'b, 'c) star = ?a:('a attrib list) -> 'b elt list -> 'c elt
(** Star '*' denotes any number of children, uncluding zero. *)

    type ('a, 'b, 'c) plus = ?a:('a attrib list) -> 'b elt -> 'b elt list -> 'c elt
(** Plus '+' requires at least one child.  *)

(** {2 Structure} *)

    type html = [`Html] elt

    val html : ?a:([< i18n | `Version | `XMLns | `Id ] attrib list) -> [< `Head ] elt -> [< `Body | `Frameset ] elt -> html
    val head : ?a:([< i18n | `Profile | `Id ] attrib list) -> [< `Base | `Title ] elt -> 
      [< `Meta | `Link | `Style | `Object | `Script ] elt list -> [>`Head] elt
(* CHANGED (from:     val title : ([< i18n | `Id ], [< `PCDATA ], [>`Title]) unary)*)
(* CHANGED (from:     val title : ([< title_attrib] , [< title_content], [> title ]) unary)*)
val title : ([< title_attrib] , [< title_content], [> title ]) unary
(* CHANGED (from:     val body : ([< common |`OnLoad |`OnUnload ], [< block ], [>`Body]) star)*)
(* CHANGED (from:     val body : ([< body_attrib] , [< body_content], [> body ]) star)*)
val body : ([< body_attrib] , [< body_content], [> body ]) star

(** {2 Data} *)

    val pcdata : string -> [>`PCDATA] elt
    val entity : string -> [>`PCDATA] elt
    val space : unit -> [>`PCDATA] elt
    val cdata : string -> [>`PCDATA] elt (* GK *)
    val cdata_script : string -> [>`PCDATA] elt (* GK *)
    val cdata_style : string -> [>`PCDATA] elt (* GK *)
(**/**)
    val unsafe_data : string -> 'a elt
(**/**)



(** {2 Text} *)

(* CHANGED (from:     val h1 : ([< common ], [< `PCDATA | inline ], [>`H1]) star)*)
(* CHANGED (from:     val h1 : ([< h1_attrib] , [< h1_content], [> h1 ]) star)*)
val h1 : ([< h1_attrib] , [< h1_content], [> h1 ]) star
(* CHANGED (from:     val h2 : ([< common ], [< `PCDATA | inline ], [>`H2]) star)*)
(* CHANGED (from:     val h2 : ([< h2_attrib] , [< h2_content], [> h2 ]) star)*)
val h2 : ([< h2_attrib] , [< h2_content], [> h2 ]) star
(* CHANGED (from:     val h3 : ([< common ], [< `PCDATA | inline ], [>`H3]) star)*)
(* CHANGED (from:     val h3 : ([< h3_attrib] , [< h3_content], [> h3 ]) star)*)
val h3 : ([< h3_attrib] , [< h3_content], [> h3 ]) star
(* CHANGED (from:     val h4 : ([< common ], [< `PCDATA | inline ], [>`H4]) star)*)
(* CHANGED (from:     val h4 : ([< h4_attrib] , [< h4_content], [> h4 ]) star)*)
val h4 : ([< h4_attrib] , [< h4_content], [> h4 ]) star
(* CHANGED (from:     val h5 : ([< common ], [< `PCDATA | inline ], [>`H5]) star)*)
(* CHANGED (from:     val h5 : ([< h5_attrib] , [< h5_content], [> h5 ]) star)*)
val h5 : ([< h5_attrib] , [< h5_content], [> h5 ]) star
(* CHANGED (from:     val h6 : ([< common ], [< `PCDATA | inline ], [>`H6]) star)*)
(* CHANGED (from:     val h6 : ([< h6_attrib] , [< h6_content], [> h6 ]) star)*)
val h6 : ([< h6_attrib] , [< h6_content], [> h6 ]) star

(* CHANGED (from:     val address : ([< common ], [< `PCDATA | inline ], [>`Address]) star)*)
(* CHANGED (from:     val address : ([< address_attrib] , [< address_content], [> address ]) star)*)
val address : ([< address_attrib] , [< address_content], [> address ]) star
    val blockquote : ([< common | `Cite ],
                      [< `PCDATA | block ], [>`Blockquote]) star
(* CHANGED (from:     val div : ([< common ], [< `PCDATA | flow ], [>`Div]) star)*)
(* CHANGED (from:     val div : ([< div_attrib] , [< div_content], [> div ]) star)*)
val div : ([< div_attrib] , [< div_content], [> div ]) star
(* CHANGED (from:     val p : ([< common ], [< `PCDATA | inline ], [>`P]) star)*)
(* CHANGED (from:     val p : ([< p_attrib] , [< p_content], [> p ]) star)*)
val p : ([< p_attrib] , [< p_content], [> p ]) star
    val pre : ([< common | `XML_space ],
               [< `PCDATA | precontent ], [>`Pre]) star
      
(* CHANGED (from:     val abbr : ([< common ], [< `PCDATA | inline ], [>`Abbr]) star)*)
(* CHANGED (from:     val abbr : ([< abbr_attrib] , [< abbr_content], [> abbr ]) star)*)
val abbr : ([< abbr_attrib] , [< abbr_content], [> abbr ]) star
(* CHANGED (from:     val acronym : ([< common ], [< `PCDATA | inline ], [>`Acronym]) star)*)
(* CHANGED (from:     val acronym : ([< acronym_attrib] , [< acronym_content], [> acronym ]) star)*)
val acronym : ([< acronym_attrib] , [< acronym_content], [> acronym ]) star
(* CHANGED (from:     val br :  ([< core ], [>`Br]) nullary)*)
(* CHANGED (from:     val br : ([< br_attrib ], [> br]) nullary)*)
val br : ([< br_attrib ], [> br]) nullary
(* CHANGED (from:     val cite : ([< common ], [< `PCDATA | inline ], [>`Cite]) star)*)
(* CHANGED (from:     val cite : ([< cite_attrib] , [< cite_content], [> cite ]) star)*)
val cite : ([< cite_attrib] , [< cite_content], [> cite ]) star
(* CHANGED (from:     val code : ([< common ], [< `PCDATA | inline ], [>`Code]) star)*)
(* CHANGED (from:     val code : ([< code_attrib] , [< code_content], [> code ]) star)*)
val code : ([< code_attrib] , [< code_content], [> code ]) star
(* CHANGED (from:     val dfn : ([< common ], [< `PCDATA | inline ], [>`Dfn]) star)*)
(* CHANGED (from:     val dfn : ([< dfn_attrib] , [< dfn_content], [> dfn ]) star)*)
val dfn : ([< dfn_attrib] , [< dfn_content], [> dfn ]) star
(* CHANGED (from:     val em : ([< common ], [< `PCDATA | inline ], [>`Em]) star)*)
(* CHANGED (from:     val em : ([< em_attrib] , [< em_content], [> em ]) star)*)
val em : ([< em_attrib] , [< em_content], [> em ]) star
(* CHANGED (from:     val kbd : ([< common ], [< `PCDATA | inline ], [>`Kbd]) star)*)
(* CHANGED (from:     val kbd : ([< kbd_attrib] , [< kbd_content], [> kbd ]) star)*)
val kbd : ([< kbd_attrib] , [< kbd_content], [> kbd ]) star
(* CHANGED (from:     val q : ([< common | `Cite ], [< `PCDATA | inline ], [>`Q]) star)*)
(* CHANGED (from:     val q : ([< q_attrib] , [< q_content], [> q ]) star)*)
val q : ([< q_attrib] , [< q_content], [> q ]) star
(* CHANGED (from:     val samp : ([< common ], [< `PCDATA | inline ], [>`Samp]) star)*)
(* CHANGED (from:     val samp : ([< samp_attrib] , [< samp_content], [> samp ]) star)*)
val samp : ([< samp_attrib] , [< samp_content], [> samp ]) star
(* CHANGED (from:     val span : ([< common ], [< `PCDATA | inline ], [>`Span]) star)*)
(* CHANGED (from:     val span : ([< span_attrib] , [< span_content], [> span ]) star)*)
val span : ([< span_attrib] , [< span_content], [> span ]) star
(* CHANGED (from:     val strong : ([< common ], [< `PCDATA | inline ], [>`Strong]) star)*)
(* CHANGED (from:     val strong : ([< strong_attrib] , [< strong_content], [> strong ]) star)*)
val strong : ([< strong_attrib] , [< strong_content], [> strong ]) star
(* CHANGED (from:     val var : ([< common ], [< `PCDATA | inline ], [>`Var]) star)*)
(* CHANGED (from:     val var : ([< var_attrib] , [< var_content], [> var ]) star)*)
val var : ([< var_attrib] , [< var_content], [> var ]) star

(** {2 Hypertext} *)

(* CHANGED (from:     val a : ([< common | `Accesskey | `Charset | `Href | `Hreflang  | `Name_01_00 | `Rel | `Rev | `Tabindex | `Target | `Type | `Shape | `Coords | `OnBlur |`OnFocus],  [< `PCDATA | inline_sans_a_mix ], [>`A]) star)*)
(* CHANGED (from:     val a : ([< a_attrib] , [< a_content], [> a ]) star)*)
val a : ([< a_attrib] , [< a_content], [> a ]) star

(** {2 List} *)

(* CHANGED (from:     val dl : ([< common ], [< `Dt | `Dd ], [>`Dl]) plus)*)
(* CHANGED (from:     val dl : ([< dl_attrib] , [< dl_content], [> dl ]) plus)*)
val dl : ([< dl_attrib] , [< dl_content], [> dl ]) plus
(* CHANGED (from:     val ol : ([< common ], [< `Li ], [>`Ol]) plus)*)
(* CHANGED (from:     val ol : ([< ol_attrib] , [< ol_content], [> ol ]) plus)*)
val ol : ([< ol_attrib] , [< ol_content], [> ol ]) plus
(* CHANGED (from:     val ul : ([< common ], [< `Li ], [>`Ul]) plus)*)
(* CHANGED (from:     val ul : ([< ul_attrib] , [< ul_content], [> ul ]) plus)*)
val ul : ([< ul_attrib] , [< ul_content], [> ul ]) plus
(* CHANGED (from:     val dd : ([< common ], [< `PCDATA | flow ], [>`Dd]) star)*)
(* CHANGED (from:     val dd : ([< dd_attrib] , [< dd_content], [> dd ]) star)*)
val dd : ([< dd_attrib] , [< dd_content], [> dd ]) star
(* CHANGED (from:     val dt : ([< common ], [< `PCDATA | inline ], [>`Dt]) star)*)
(* CHANGED (from:     val dt : ([< dt_attrib] , [< dt_content], [> dt ]) star)*)
val dt : ([< dt_attrib] , [< dt_content], [> dt ]) star
(* CHANGED (from:     val li : ([< common ], [< `PCDATA | flow ], [>`Li]) star)*)
(* CHANGED (from:     val li : ([< li_attrib] , [< li_content], [> li ]) star)*)
val li : ([< li_attrib] , [< li_content], [> li ]) star
      
(** {2 Presentation} *)

(* CHANGED (from:     val hr : ([< common ], [>`Hr]) nullary)*)
(* CHANGED (from:     val hr : ([< hr_attrib ], [> hr]) nullary)*)
val hr : ([< hr_attrib ], [> hr]) nullary
(* CHANGED (from:     val b : ([< common ], [< `PCDATA | inline ], [>`B]) star)*)
(* CHANGED (from:     val b : ([< b_attrib] , [< b_content], [> b ]) star)*)
val b : ([< b_attrib] , [< b_content], [> b ]) star
(* CHANGED (from:     val big : ([< common ], [< `PCDATA | inline ], [>`Big]) star)*)
(* CHANGED (from:     val big : ([< big_attrib] , [< big_content], [> big ]) star)*)
val big : ([< big_attrib] , [< big_content], [> big ]) star
(* CHANGED (from:     val i : ([< common ], [< `PCDATA | inline ], [>`I]) star)*)
(* CHANGED (from:     val i : ([< i_attrib] , [< i_content], [> i ]) star)*)
val i : ([< i_attrib] , [< i_content], [> i ]) star
(* CHANGED (from:     val small : ([< common ], [< `PCDATA | inline ], [>`Small]) star)*)
(* CHANGED (from:     val small : ([< small_attrib] , [< small_content], [> small ]) star)*)
val small : ([< small_attrib] , [< small_content], [> small ]) star
(* CHANGED (from:     val sub : ([< common ], [< `PCDATA | inline ], [>`Sub]) star)*)
(* CHANGED (from:     val sub : ([< sub_attrib] , [< sub_content], [> sub ]) star)*)
val sub : ([< sub_attrib] , [< sub_content], [> sub ]) star
(* CHANGED (from:     val sup : ([< common ], [< `PCDATA | inline ], [>`Sup]) star)*)
(* CHANGED (from:     val sup : ([< sup_attrib] , [< sup_content], [> sup ]) star)*)
val sup : ([< sup_attrib] , [< sup_content], [> sup ]) star
(* CHANGED (from:     val tt : ([< common ], [< `PCDATA | inline ], [>`Tt]) star)*)
(* CHANGED (from:     val tt : ([< tt_attrib] , [< tt_content], [> tt ]) star)*)
val tt : ([< tt_attrib] , [< tt_content], [> tt ]) star
      
    (* CH *)
    (* CHANGED (from:     val bdo : dir:[< `Ltr | `Rtl ] -> ([< core | `XML_lang ],[< `PCDATA | inline ],[> `Bdo ]) star)*)
(* CHANGED (from:     val bdo : dir:[< `Ltr | `Rtl ]  -> ([< bdo_attrib] , [< bdo_content], [> bdo ]) star)*)
    val bdo : dir:[< `Ltr | `Rtl ]   ->([< bdo_attrib] , [< bdo_content], [> bdo ]) star
(* CH *)

(* CHANGED (from:     val area : alt:text -> ([< area_attrib ], [> area ]) nullary)*)
    val area : alt:text  ->([< area_attrib ], [> area]) nullary
      
(* CHANGED (from:     val map : id:id -> ([< events | core | `XMLns | `Class | `Title | i18n ],[< block | `Area ],[>`Map]) plus)*)
    val map : id:id  ->([< map_attrib] , [< map_content], [> map ]) plus

(* CHANGED (from:     val del : ([< del_attrib ], [< del_content ], [> del]) star)*)
val del : ([< del_attrib] , [< del_content], [> del ]) star
(* CHANGED (from:     val ins : ([< ins_attrib ],[< ins_content ],[>` ins]) star)*)
val ins : ([< ins_attrib] , [< ins_content], [> ins ]) star
(* CHANGED (from:     val script : contenttype:contenttype -> ([< script_attrib ], [< script_content],  [> script ]) unary)*)
    val script : contenttype:contenttype  ->([< script_attrib] , [< script_content], [> script ]) unary
(* CHANGED (from:     val noscript : ([< common ],[< block ],[>`Noscript]) plus)*)
val noscript : ([< noscript_attrib] , [< noscript_content], [> noscript ]) plus

(** {2 Forms} *)

(** {3 Basic Forms} *)

(** One can use [open Basic_Forms] to enable basic forms. *)

    module Basic_Forms :
        sig
(* CHANGED (from:           val form : action:uri -> ([< common | `Enctype | `Method | `Name_01_00 | `Target |`OnReset | `OnSubmit],       [< block_sans_form ], [>`Form]) plus)*)
          val form : action:uri  ->([< form_attrib] , [< form_content], [> form ]) plus
(* CHANGED (from:           val input : ([< common | `Accesskey | `Checked | `Maxlength | `Name | `Size                       | `Src | `Tabindex | `Input_Type | `Value | `Usemap|`Ismap |`OnBlur |`OnChange |`OnFocus | `OnSelect], [>`Input]) nullary)*)
val input : ([< input_attrib ], [> input]) nullary
(* CHANGED (from:           val label : ([< common | `Accesskey | `For ],                       [< `PCDATA | inline_sans_label ], [>`Label]) star)*)
val label : ([< label_attrib] , [< label_content], [> label ]) star
(* CHANGED (from:           val option : ([< common | `Selected | `Value ],                        [< `PCDATA ], [>`Option]) unary)*)
val option : ([< option_attrib] , [< option_content], [> selectoption ]) unary
(* CHANGED (from:           val select : ([< common | `Multiple | `Name | `Size | `Tabindex |`OnBlur |`OnChange |`OnFocus ],                        [< `Option ], [>`Select]) plus)*)
val select : ([< select_attrib] , [< select_content], [> select ]) plus
(* CHANGED (from:           val textarea : rows:number -> cols:number ->            ([< common | `Accesskey | `Name | `Tabindex |`OnBlur |`OnChange |`OnFocus | `OnSelect],             [< `PCDATA ], [>`Textarea]) unary)*)
          val textarea : rows:number  -> cols:number  ->([< textarea_attrib] , [< textarea_content], [> textarea ]) unary
        end

(** {3 Forms} *)

(** Generic forms. WARNING: If you find a bug or if something is missing please send a bug report to the Ocsigen project! -- VB *)
(* CHANGED (from:     val form : action:uri ->      ([< common | `Enctype | `Method | `Name_01_00 | `Target | `Accept_charset | `Accept |`OnReset | `OnSubmit],       [< block_sans_form | `Fieldset ], [>`Form]) plus)*)
    val form : action:uri  ->([< form_attrib] , [< form_content], [> form ]) plus
(* CHANGED (from:     val input : ([< common | `Accesskey | `Checked | `Maxlength | `Name | `Size  | `Src | `Tabindex | `Input_Type | `Value | `Disabled | `Readonly | `Alt | `Accept | `Usemap |`Ismap |`OnBlur |`OnChange |`OnFocus | `OnSelect], [>`Input]) nullary)*)
val input : ([< input_attrib ], [> input]) nullary
(* CHANGED (from:     val label : ([< common | `Accesskey | `For |`OnBlur |`OnFocus],                 [< `PCDATA | inline_sans_label ], [>`Label]) star)*)
val label : ([< label_attrib] , [< label_content], [> label ]) star
(* CHANGED (from:     val optgroup : label:text ->      ([< common | `Disabled ],       [< `Option ], [>`Optgroup]) plus)*)
    val optgroup : label:text  ->([< optgroup_attrib] , [< optgroup_content], [> optgroup ]) plus
(* CHANGED (from:     val option : ([< common | `Selected | `Value | `Disabled | `Label ],                  [< `PCDATA ], [>`Option]) unary)*)
val option : ([< option_attrib] , [< option_content], [> selectoption ]) unary
(* CHANGED (from:     val select : ([< common | `Multiple | `Name | `Size | `Tabindex | `Disabled |`OnBlur |`OnChange |`OnFocus ],                  [< `Option | `Optgroup ], [>`Select]) plus)*)
val select : ([< select_attrib] , [< select_content], [> select ]) plus
(* CHANGED (from:     val textarea : rows:number -> cols:number ->      ([< common | `Accesskey | `Name | `Tabindex | `Disabled | `Readonly |`OnBlur |`OnChange |`OnFocus | `OnSelect],       [< `PCDATA ], [>`Textarea]) unary)*)
    val textarea : rows:number  -> cols:number  ->([< textarea_attrib] , [< textarea_content], [> textarea ]) unary
(* CHANGED (from:     val fieldset : ([< common ],                    [< `PCDATA | `Legend | flow ], [>`Fieldset]) star)*)
val fieldset : ([< fieldset_attrib] , [< fieldset_content], [> fieldset ]) star
(* CHANGED (from:     val legend : ([< common | `Accesskey ],                    [< `PCDATA | inline ], [>`Legend]) star)*)
val legend : ([< legend_attrib] , [< legend_content], [> legend ]) star
(* CHANGED (from:     val button : ([< common | `Name | `Value | `Button_Type | `Disabled | `Accesskey | `Tabindex |`OnBlur |`OnFocus],                    [< `PCDATA | buttoncontent ], [>`Button]) star)*)
val button : ([< button_attrib] , [< button_content], [> button ]) star

(** {2 Tables} *)

(** {3 Basic Tables} *)

(** One can use [open Basic_Tables] to switch globally to basic tables. *)

    module Basic_Tables :
      sig
        val a_align : [< `Left | `Center | `Right ] -> [>`Align] attrib
        val a_scope : [< `Row | `Col ] -> [>`Scope] attrib
        val a_valign : [< `Top | `Middle | `Bottom ] -> [>`Valign] attrib

(* CHANGED (from:         val caption : ([< common ], [< `PCDATA | inline ], [>`Caption]) star)*)
val caption : ([< caption_attrib] , [< caption_content], [> caption ]) star
(* CHANGED (from:         val table : ?caption:([< `Caption ] elt) ->            ([< common | `Summary | `Width ], [< `Tr ], [>`Table]) plus)*)
        val table : ?caption:([< `Caption ] elt)  ->([< table_attrib] , [< table_content], [> table ]) plus
(* CHANGED (from:         val td : ([< common | `Abbr | `Align | `Axis | `Colspan | `Headers | `Rowspan                  | `Scope | `Valign ], [< `PCDATA | flow_sans_table ], [>`Td]) star)*)
val td : ([< td_attrib] , [< td_content], [> td ]) star
(* CHANGED (from:         val th : ([< common |  `Abbr | `Align | `Axis | `Colspan | `Headers | `Rowspan                  | `Scope | `Valign ], [< `PCDATA | flow_sans_table ], [>`Th]) star)*)
val th : ([< th_attrib] , [< th_content], [> th ]) star
(* CHANGED (from:         val tr : ([< common | `Align | `Valign ], [< `Td | `Th ], [>`Tr]) plus)*)
val tr : ([< tr_attrib] , [< tr_content], [> tr ]) plus
      end

(** {3 Tables} *)

(* CHANGED (from:     val caption : ([< common ], [< `PCDATA | inline ], [>`Caption]) star)*)
val caption : ([< caption_attrib] , [< caption_content], [> caption ]) star

    val table : ?caption:([< `Caption ] elt) ->      ?columns:([< `Cols of ([< `Col ] elt list)
                | `Colgroups of ([< `Colgroup ] elt list) ]) ->        ([< common | `Border | `Cellpadding | `Cellspacing | `Datapagesize         | `Frame | `Rules | `Summary | `Width ], [< `Tr ], [>`Table]) plus

    val tablex : ?caption:([< `Caption ] elt) ->      ?columns:([< `Cols of ([< `Col ] elt list)
                | `Colgroups of ([< `Colgroup ] elt list) ]) ->        ?thead:([< `Thead ] elt) -> ?tfoot:([< `Tfoot ] elt) ->          ([< common | `Border | `Cellpadding | `Cellspacing | `Datapagesize           | `Frame | `Rules | `Summary | `Width ], [< `Tbody ], [>`Table]) plus

(* CHANGED (from:     val td : ([< common |  `Abbr | `Align | `Axis | `Char | `Charoff              | `Colspan | `Headers | `Rowspan | `Scope | `Valign ],              [< `PCDATA | flow ], [>`Td]) star)*)
val td : ([< td_attrib] , [< td_content], [> td ]) star
(* CHANGED (from:     val th : ([< common |  `Abbr | `Align | `Axis | `Char | `Charoff              | `Colspan | `Headers | `Rowspan | `Scope | `Valign ],              [< `PCDATA | flow ], [>`Th]) star)*)
val th : ([< th_attrib] , [< th_content], [> th ]) star
(* CHANGED (from:     val tr : ([< common | `Align | `Char | `Charoff | `Valign ],              [< `Td | `Th ], [>`Tr]) plus)*)
val tr : ([< tr_attrib] , [< tr_content], [> tr ]) plus

(* CHANGED (from:     val col : ([< common | `Align | `Char | `Charoff               | `Span | `Valign | `Width ], [>`Col]) nullary)*)
val col : ([< col_attrib ], [> col]) nullary
(* CHANGED (from:     val colgroup : ([< common | `Align | `Char | `Charoff                    | `Span | `Valign | `Width ], [< `Col ], [>`Colgroup]) star)*)
val colgroup : ([< colgroup_attrib] , [< colgroup_content], [> colgroup ]) star
(* CHANGED (from:     val thead : ([< common | `Align | `Char | `Charoff | `Valign ],                 [< `Tr ], [>`Thead]) plus)*)
val thead : ([< thead_attrib] , [< thead_content], [> thead ]) plus
(* CHANGED (from:     val tbody : ([< common | `Align | `Char | `Charoff | `Valign ],                 [< `Tr ], [>`Tbody]) plus)*)
val tbody : ([< tbody_attrib] , [< tbody_content], [> tbody ]) plus
(* CHANGED (from:     val tfoot : ([< common | `Align | `Char | `Charoff | `Valign ],                 [< `Tr ], [>`Tfoot]) plus)*)
val tfoot : ([< tfoot_attrib] , [< tfoot_content], [> tfoot ]) plus

(** {2 Image} *)

(* CHANGED (from:     val img : src:uri -> alt:text ->      ([< common | `Height | `Longdesc | `Name_01_00 | `Width | `Usemap |`Ismap ], [>`Img]) nullary)*)
    val img : src:uri  -> alt:text  ->([< img_attrib ], [> img]) nullary

(** {2 Object} VB *)

(* CHANGED (from:     val object_ : ([< common | `Declare | `Classid | `Codebase | `Data | `Type | `Codetype | `Archive | `Standby                   | `Height | `Width | `Name | `Tabindex | `Usemap],[< `PCDATA | flow | `Param ],[> `Object ]) star)*)
val object_ : ([< object__attrib] , [< object__content], [> object_ ]) star

(* CHANGED (from:     val param : name:text ->([< `XMLns |`Id | `Value | `Value_Type | `Type ], [> `Param ]) nullary)*)
    val param : name:text  ->([< param_attrib ], [> param]) nullary

(** {2 Frames} *)

(* CHANGED (from:     val frameset : ?noframes:([< `Noframes ] elt) ->      ([< core | `FS_Rows | `FS_Cols |`OnLoad |`OnUnload], [< `Frameset | `Frame ], [>`Frameset]) plus)*)
    val frameset : ?noframes:([< `Noframes ] elt)  ->([< frameset_attrib] , [< frameset_content], [> frameset ]) plus

(* CHANGED (from:     val frame : src:uri ->      ([< core | `Frameborder | `Longdesc | `Marginheight | `Marginwidth       | `Name_01_00 | `Noresize | `Scrolling ], [>`Frame]) nullary)*)
    val frame : src:uri  ->([< frame_attrib ], [> frame]) nullary

(* CHANGED (from:     val noframes : ([< common ], [< `Body ], [>`Noframes]) unary)*)
val noframes : ([< noframes_attrib], [< noframes_content], [> noframes ]) unary

(* CHANGED (from:     val iframe : ([< core | `Frameborder | `Longdesc | `Marginheight | `Marginwidth                  | `Src | `Scrolling | `Name_01_00 | `Width | `Height ],                  [< `PCDATA | flow ], [>`Iframe]) star)*)
val iframe : ([< iframe_attrib], [< iframe_content], [> iframe ]) star


(** {2 Meta} *)

(* CHANGED (from:     val meta : content:cdata ->      ([< i18n |`Id | `Http_equiv | `Name | `Scheme ], [>`Meta]) nullary)*)
    val meta : content:cdata -> ([< meta_attrib ], [> meta]) nullary

(** {2 Style Sheets} *)

(* CHANGED (from:     val style : contenttype:contenttype ->      ([< i18n |`XMLns |`Id | `Media | `Title | `XML_space ], [< `PCDATA ], [>`Style]) star)*)
    val style : contenttype:contenttype -> ([< style_attrib] , [< style_content], [> style ]) star

(** {2 Link} *)

(* CHANGED (from:     val link : ([< common | `Charset | `Href | `Hreflang | `Media | `Rel | `Rev | `Target | `Type ], [>`Link]) nullary)*)
val link : ([< link_attrib ], [> link]) nullary

(** {2 Base} *)
      (* in the DTD of xHTML1.1 xmlns attribute
         in the doc of xHTML1.1 id attribute *)
(* CHANGED (from:     val base : href:uri -> ([`XMLns | `Target ], [>`Base]) nullary)*)
    val base : href:uri  ->([< base_attrib ], [> base]) nullary

(** {2 Ruby} *)

    val ruby_simple1 : ?a:([< common] attrib list) ->      [< `Rb ] elt -> [< `Rt ] elt -> [>`Ruby_simple1] elt
    val ruby_simple2 : ?a:([< common] attrib list) ->      [< `Rb ] elt -> [< `Rp ] elt -> [< `Rt ] elt -> [< `Rp ] elt -> [>`Ruby_simple2] elt
    val ruby_complex : ?a:([< common] attrib list) ->      [< `Rbc ] elt -> [< `Rtc_complex ] elt -> [>`Ruby_complex] elt

(* CHANGED (from:     val rbc : ([< common ], [< `Rb ], [>`Rbc]) plus)*)
val rbc : ([< rbc_attrib] , [< rbc_content], [> rbc ]) plus
(* CHANGED (from:     val rtc : ([< common ], [< `Rt ], [>`Rtc]) plus)*)
val rtc : ([< rtc_attrib] , [< rtc_content], [> rtc ]) plus
(* CHANGED (from:     val rtc_complex : ([< common ], [< `Rt_complex ], [>`Rtc]) plus)*)
val rtc_complex : ([< rtc_complex_attrib] , [< rtc_complex_content], [> rtc_complex ]) plus
(* CHANGED (from:     val rb : ([< common ], [< no_ruby_content ], [>`Rb]) star)*)
val rb : ([< rb_attrib] , [< rb_content], [> rb ]) star
(* CHANGED (from:     val rt : ([< common ], [< no_ruby_content ], [>`Rt]) star)*)
val rt : ([< rt_attrib] , [< rt_content], [> rt ]) star
(* CHANGED (from:     val rt_complex : ([< common | `Rbspan], [< no_ruby_content ], [>`Rt]) star)*)
val rt_complex : ([< rt_complex_attrib] , [< rt_complex_content], [> rt_complex ]) star
(* CHANGED (from:     val rp : ([< common ], [< `PCDATA ], [>`Rp]) star)*)
val rp : ([< rp_attrib] , [< rp_content], [> rp ]) star

    val a_rbspan : number -> [>`Rbspan] attrib


(** {1 Output} *)

(** [?encode] maps strings to HTML and {e must} encode the unsafe characters
    ['<'], ['>'], ['"'], ['&'] and the control characters 0-8, 11-12, 14-31, 127
    to HTML entities.  [XML.encode_unsafe] is the default for [?encode] in [output]
    and [pretty_print] below.  Other implementations are provided by the module
    [Netencoding] in the
    {{:http://www.ocaml-programming.de/programming/ocamlnet.html}OcamlNet} library, e.g.:
    [let encode = Netencoding.Html.encode ~in_enc:`Enc_iso88591 ~out_enc:`Enc_usascii ()],
    Where national characters are replaced by HTML entities.
    The user is of course free to write her own implementation.
    @see <http://www.ocaml-programming.de/programming/ocamlnet.html> OcamlNet *)

(** [~encoding] is the official name of the external character set encoding that
    is used by [outs : string -> unit]. *)

    type doctypes = 
        [ `HTML_v03_02 | `HTML_v04_01 | `XHTML_01_00 | `XHTML_01_01
        | `XHTML_05_00 | `Doctype of string ]

    val doctype : [< doctypes ] -> string

(*
    val output : ?encode:(string -> string) -> ?encoding:string ->
      (string -> unit) -> html -> unit

    val pretty_print : ?width:int ->
      ?encode:(string -> string) -> ?encoding:string ->
        (string -> unit) -> html -> unit
*)

(** {1 Tools} *)

    val version : string
    val standard : uri
(*    val validator : uri
    val validator_icon : unit -> [>`A] elt
(** A hyperlink to the W3C validator, including the logo.
    @see <http://validator.w3.org> Validator *)
*)
(*
    val addto_class : string -> 'a elt -> 'a elt
(** Add the element and all its subelements to a class.  Note that this
   is only almost typesafe, because a few elements from the structure class
   do not support the class attribute.   On the other hand, listing all
   allowed elements would be too tedious right now.  *)

    val addto_class1 : string -> 'a elt -> 'a elt
(** Add the element to a class. *)

    val set_rowspan : int -> ([< `Th | `Td ] as 'a) elt -> 'a elt
(** Set the rowspan attribute for the element. *)

    val rewrite_hrefs : (string -> string) -> 'a elt -> 'a elt
*)
(*
    val amap : (string -> 'a attribs -> 'a attribs) -> 'b elt -> 'b elt
    val amap1 : (string -> 'a attribs -> 'a attribs) -> 'b elt -> 'b elt

    val rm_attrib : (string -> bool) -> 'a attribs -> 'a attribs
    val rm_attrib_from_list :
        (string -> bool) -> (string -> bool) -> 'a attribs -> 'a attribs

(** Exporting the following will drive a hole through the type system,
   because they allow to add any attribute to any element. *)
    val add_int_attrib : string -> int -> 'a attribs -> 'a attribs
    val add_string_attrib : string -> string -> 'a attribs -> 'a attribs
    val add_comma_sep_attrib : string -> string -> 'a attribs -> 'a attribs
    val add_space_sep_attrib : string -> string -> 'a attribs -> 'a attribs
*)

    val tot : XML.elt -> 'a elt
    val totl : XML.elt list -> 'a elt list
    val toelt : 'a elt -> XML.elt
    val toeltl : 'a elt list -> XML.elt list

  end

(** An alias for XHTML 1.1 (for symmetry):
    @see <http://www.w3.org/TR/xhtml11/> XHTML 1.1 - Module-based XHTML *)
module type T_01_01 = T

(** XHTML 1.0 includes some deprecated features that since
    have been removed from XHTML 1.1:
    @see <http://www.w3.org/TR/xhtml11/changes.html#a_changes> Changes from XHTML 1.0 Strict
    @see <http://www.w3.org/TR/2000/REC-xhtml1-20000126/> XHTML 1.0: The Extensible HyperText Markup Language *)
module type T_01_00 =
  sig
    include T

(** XHTML 1.1 has removed the name attribute from several elements: *)
    val a_name_01_00 : cdata -> [>`Name_01_00] attrib
  end

(* END INTERFACE *)

(* BEGIN INTERFACE

module M : T
module M_01_01 : T_01_01
module M_01_00 : T_01_00

   END INTERFACE *)

module Version =
  struct
    include Uri
    (* Directly from http://www.w3.org/TR/xhtml-modularization/abstract_modules.html *)

    type core = [ `Class | `Id | `Title | `XML_space ]
    type i18n = [ `XML_lang | `Dir ]

    type events = [ `OnClick | `OnDblClick | `OnMouseDown | `OnMouseUp |
                    `OnMouseOver | `OnMouseMove | `OnMouseOut | `OnKeyPress |
                    `OnKeyDown | `OnKeyUp ]

    type common = [ core | i18n | events | `Style_Attr]

    type 'a attrib = XML.attrib
    type 'a attribs = XML.attribs

    let to_xmlattribs x = x (* VB *)

    let int_attrib = XML.int_attrib
    let string_attrib = XML.string_attrib
    let uri_attrib a b = XML.string_attrib a (string_of_uri b)
    let space_sep_attrib = XML.space_sep_attrib
    let comma_sep_attrib = XML.comma_sep_attrib
    let event_attrib = XML.event_attrib

    type cdata = string
    type id = string
    type idref = string
    type idrefs = idref list (* space-separated *)
    type name = string
    type nmtoken = string
    type nmtokens = nmtoken list (* space-separated *)
    type pcdata = string

    type character = char
    type charset = string
    type charsets = charset list (* space-separated *)

    type contenttype = string
    type contenttypes = contenttype list (* comma-separated *)
    type coords = string list (* Comma separated list of coordinates to use in defining areas. *)
    type datetime = string
    type fpi = string
    type frametarget = string
    type languagecode = string
    type length = [ `Pixels of int | `Percent of int ]
    type linktypes =
        [`Alternate | `Appendix | `Bookmark | `Chapter | `Contents
        | `Copyright | `Glossary | `Help | `Index | `Next | `Prev
        | `Section | `Start | `Stylesheet | `Subsection | `Other of string] list
    type mediadesc =
        [ `All | `Aural | `Braille | `Embossed | `Handheld | `Print
        | `Projection | `Screen | `Speech | `TTY | `TV ] list

    type multilength = [ length | `Relative of int ]
    type multilengths = multilength list (* comma-separated *)
    type number = int
    type pixels = int
    type script = string
    type text = string

    let length_attrib name = function
      | `Pixels p -> int_attrib name p
      | `Percent p -> string_attrib name (string_of_int p ^ "%")

    let multilength_attrib name = function
      | #length as l -> length_attrib name l
      | `Relative 1 -> string_attrib name "*"
      | `Relative i -> string_attrib name (string_of_int i ^ "*")

    let multilength_to_string = function
      | `Pixels p -> string_of_int p
      | `Percent p -> string_of_int p ^ "%"
      | `Relative 1 -> "*"
      | `Relative i -> string_of_int i ^ "*"

    let multilengths_attrib name multilengths =
      string_attrib name
        (String.concat ", " (List.map multilength_to_string multilengths))

    let linktype_to_string = function
      | `Alternate -> "alternate"
      | `Appendix -> "appendix"
      | `Bookmark -> "bookmark"
      | `Chapter -> "chapter"
      | `Contents -> "contents"
      | `Copyright -> "copyright"
      | `Glossary -> "glossary"
      | `Help -> "help"
      | `Index -> "index"
      | `Next -> "next"
      | `Prev -> "prev"
      | `Section -> "section"
      | `Start -> "start"
      | `Stylesheet -> "stylesheet"
      | `Subsection -> "subsection"
      | `Other t -> t

    let linktypes_attrib name linktypes =
      string_attrib name
        (String.concat " " (List.map linktype_to_string linktypes))

    let mediadesc_to_string = function
      | `All -> "all"
      | `Aural -> "aural"
      | `Braille -> "braille"
      | `Embossed -> "embossed"
      | `Handheld -> "handheld"
      | `Print -> "print"
      | `Projection -> "projection"
      | `Screen -> "screen"
      | `Speech -> "speech"
      | `TTY -> "tty"
      | `TV -> "tv"

    let mediadesc_attrib name mediadescs =
      string_attrib name
        (String.concat ", " (List.map mediadesc_to_string mediadescs))

    (* Core: *)

    let a_class = space_sep_attrib XML.class_name
      (* class is different on client side.
         We put the value in xML.ml 
         because this file has a different implementation client side.
      *)
    let a_id = string_attrib "id"
    let a_title = string_attrib "title"

    (* I18N: *)

    let a_xml_lang = string_attrib "xml:lang"

    (* Style: *)

    let a_style = string_attrib "style"


    (* Events: *)

    let a_onblur = event_attrib "onblur"
    let a_onclick = event_attrib "onclick"
    let a_ondblclick = event_attrib "ondblclick"
    let a_onchange = event_attrib "onchange"
    let a_onfocus = event_attrib "onfocus"
    let a_onload = event_attrib "onload"
    let a_onunload = event_attrib "onunload"
    let a_onreset = event_attrib "onreset"
    let a_onselect = event_attrib "onselect"
    let a_onsubmit = event_attrib "onsubmit"
    let a_onmousedown = event_attrib "onmousedown"
    let a_onmouseup = event_attrib "onmouseup"
    let a_onmouseover = event_attrib "onmouseover"
    let a_onmousemove = event_attrib "onmousemove"
    let a_onmouseout = event_attrib "onmouseout"
    let a_onkeypress = event_attrib "onkeypress"
    let a_onkeydown = event_attrib "onkeydown"
    let a_onkeyup = event_attrib "onkeyup"


    (* Other Attributes *)

    let a_profile = uri_attrib "profile"
    let a_version = string_attrib "version"
    let a_xmlns = function
      | `W3_org_1999_xhtml -> string_attrib "xmlns" "http://www.w3.org/1999/xhtml"

    let a_cite = uri_attrib "cite"
    let a_xml_space = function
      | `Preserve -> string_attrib "xml:space" "preserve"

    let a_accesskey c = string_attrib "accesskey" (String.make 1 c)
    let a_charset = string_attrib "charset"
    let a_accept_charset = string_attrib "accept-charset"
    let a_accept = string_attrib "accept"
    let a_href = uri_attrib "href"
    let a_hreflang = string_attrib "hreflang"
    let a_rel = linktypes_attrib "rel"
    let a_rev = linktypes_attrib "rev"
    let a_tabindex = int_attrib "tabindex"
    let a_type = string_attrib "type"

    let a_alt = string_attrib "alt"
    let a_height p = length_attrib "height" p
    let a_longdesc = uri_attrib "longdesc"
    let a_src = uri_attrib "src"
    let a_width p = length_attrib "width" p

    let a_for = string_attrib "for"
    let a_selected = function
      | `Selected -> string_attrib "selected" "selected"
    let a_value = string_attrib "value"
    let a_action = uri_attrib "action"
    let a_method m =
      string_attrib "method" (match m with `Get ->  "get" | `Post -> "post")
    let a_enctype = string_attrib "enctype"

    let a_ismap `Ismap = string_attrib "ismap" "ismap"

    let a_checked `Checked = string_attrib "checked" "checked"
    let a_disabled `Disabled = string_attrib "disabled" "disabled"
    let a_readonly `Readonly = string_attrib "readonly" "readonly"
    let a_maxlength = int_attrib "maxlength"
    let a_name = string_attrib "name"

   let a_span = int_attrib "span"

    let a_value_type it =
      string_attrib "valuetype"
        (match it with
        | `Data -> "data"
        | `Ref -> "ref"
        | `Object -> "object")

(* XHTML 1.0 allows the name attribute for more elements:*)
    let a_name_01_00 = string_attrib "name"

    let a_size = int_attrib "size"
    let a_input_type it =
      string_attrib "type"
        (match it with
        | `Text -> "text"
        | `Password -> "password"
        | `Checkbox -> "checkbox"
        | `Radio -> "radio"
        | `Submit -> "submit"
        | `Reset -> "reset"
        | `File -> "file"
        | `Image -> "image"
        | `Button -> "button"
        | `Hidden -> "hidden")
    let a_button_type bt =
      string_attrib "type"
        (match bt with
        | `Button -> "button"
        | `Submit -> "submit"
        | `Reset -> "reset")
    let a_multiple = function
      | `Multiple -> string_attrib "multiple" "multiple"
    let a_cols = int_attrib "cols"
    let a_rows = int_attrib "rows"

    let a_summary = string_attrib "summary"

    let a_abbr = string_attrib "attrib"
    let a_align a =
      string_attrib "align"
        (match a with
        | `Left -> "left"
        | `Center -> "center"
        | `Right -> "right"
        | `Justify -> "justify"
        | `Char -> "char")
    let a_axis = string_attrib "axis"
    let a_colspan = int_attrib "colspan"
    let a_headers = space_sep_attrib "headers"
    let a_rowspan = int_attrib "rowspan"
    let a_scope s =
      string_attrib "scope"
        (match s with
        | `Row -> "row"
        | `Col -> "col"
        | `Rowgroup -> "rowgroup"
        | `Colgroup -> "colgroup")
    let a_valign v =
      string_attrib "valign"
        (match v with
        | `Top -> "top"
        | `Middle -> "middle"
        | `Bottom -> "bottom"
        | `Baseline -> "baseline")

    let a_border = int_attrib "border"
    let a_cellpadding = length_attrib "cellpadding"
    let a_cellspacing = length_attrib "cellspacing"
    let a_datapagesize = string_attrib "datapagesize"
    let a_frame f =
      string_attrib "frame"
        (match f with
        | `Void -> "void"
        | `Above -> "above"
        | `Below -> "below"
        | `Hsides -> "hsides"
        | `LHS -> "lhs"
        | `RHS -> "rhs"
        | `Vsides -> "vsides"
        | `Box -> "box"
        | `Border -> "border")
    let a_rules r =
      string_attrib "rules"
        (match r with
        | `None -> "none"
        | `Groups -> "groups"
        | `Rows -> "rows"
        | `Cols -> "cols"
        | `All -> "all")
    let a_char c = string_attrib "char" (String.make 1 c)
    let a_charoff = length_attrib "charoff"

    let a_declare `Declare = string_attrib "declare" "declare"
    let a_classid = uri_attrib "classid"
    let a_codebase = uri_attrib "codebase"
    let a_data = uri_attrib "data"
    let a_codetype = string_attrib "codetype"
    let a_archive = uri_attrib "archive"
    let a_standby = string_attrib "standby"

    let a_fs_rows mls = multilengths_attrib "rows" mls
    let a_fs_cols mls = multilengths_attrib "cols" mls
    let a_frameborder b =
      int_attrib "frameborder" (match b with `Zero -> 0 | `One -> 1)
    let a_marginheight = int_attrib "marginheight"
    let a_marginwidth = int_attrib "marginwidth"
    let a_noresize `Noresize = string_attrib "noresize" "noresize"
    let a_scrolling s =
      string_attrib "scrolling"
        (match s with
        | `Yes -> "yes"
        | `No -> "no"
        | `Auto -> "auto")

    let a_target = string_attrib "target"

    let a_content = string_attrib "content"
    let a_http_equiv = string_attrib "http-equiv"
    let a_scheme = string_attrib "scheme"

    let a_media = mediadesc_attrib "media"

    type 'a elt = XML.elt

    type html = [`Html] elt

    (* NB: These are more general than the ones in xHTML.mli *)

    type ('a, 'b) nullary = ?a:('a attrib list) -> unit -> 'b elt
    type ('a, 'b, 'c) unary = ?a:('a attrib list) -> 'b elt -> 'c elt
    type ('a, 'b, 'c, 'd) binary = ?a:('a attrib list) -> 'b elt -> 'c elt -> 'd elt
(* CH *)
    type ('a, 'b, 'c, 'd, 'e, 'f) quadry= ?a:('a attrib list) -> 'b elt -> 'c elt -> 'd elt -> 'e elt -> 'f elt
(* CH *)
    type ('a, 'b, 'c) star = ?a:('a attrib list) -> 'b elt list -> 'c elt
    type ('a, 'b, 'c) plus = ?a:('a attrib list) -> 'b elt -> 'b elt list -> 'c elt

    let terminal tag ?a () = XML.leaf ?a tag
    (* let nullary tag ?a () = XML.node ?a tag [] *)
    let unary tag ?a elt = XML.node ?a tag [elt]
    let binary tag ?a elt1 elt2 = XML.node ?a tag [elt1; elt2]
    let star tag ?a elts = XML.node ?a tag elts
    let plus tag ?a elt elts = XML.node ?a tag (elt :: elts)

(* CH *)
    let quadry tag ?a elt1 elt2 elt3 elt4 = XML.node ?a tag [elt1; elt2; elt3; elt4]
(* CH *)


    module STRUCTURE =
      struct
        type t = [ `Body | `Head | `Html | `Title ]
      end

    let body = star "body"
    let head = plus "head"
    let title = unary "title"
    let html = binary "html"

    let pcdata = XML.pcdata
    let entity = XML.entity

    let space () = entity "nbsp"

    let cdata = XML.cdata

    let cdata_script = XML.cdata_script

    let cdata_style = XML.cdata_style

    let unsafe_data s = XML.encodedpcdata s


    module TEXT =
      struct
        type heading = [ `H1 | `H2 | `H3 | `H4 | `H5 | `H6 ]
        type block = [ `Address | `Blockquote | `Div | `P | `Pre ]
        type inline =
            [ `Abbr | `Acronym | `Br | `Cite | `Code | `Dfn
            | `Em | `Kbd | `Q | `Samp | `Span | `Strong | `Var ]
        type flow = [ heading | block | inline ]
      end

    let h1 = star "h1"
    let h2 = star "h2"
    let h3 = star "h3"
    let h4 = star "h4"
    let h5 = star "h5"
    let h6 = star "h6"

    let address = star "address"
    let blockquote = star "blockquote"
    let div = star "div"
    let p = star "p"
    let pre = star "pre"

    let abbr = star "abbr"
    let acronym = star "acronym"
    let br = terminal "br"
    let cite = star "cite"
    let code = star "code"
    let dfn = star "dfn"
    let em = star "em"
    let kbd = star "kbd"
    let q = star "q"
    let samp = star "samp"
    let span = star "span"
    let strong = star "strong"
    let var = star "var"

    module HYPERTEXT =
      struct
        type inline = [ `A ]
        type flow = inline
      end

    let a = star "a"

    module LIST =
      struct
        type list = [ `Dl | `Ol | `Ul ]
        type t = [ `Dd | `Dt | `Li ]
        type flow = list
      end

    let dl = plus "dl"
    let ol = plus "ol"
    let ul = plus "ul"
    let dd = star "dd"
    let dt = star "dt"
    let li = star "li"

    module PRESENTATION =
      struct
        type block = [ `Hr ]
        type inline = [ `B | `Big | `I | `Small | `Sub | `Sup | `Tt ]
        type flow = [ inline | block ]
      end

    let hr = terminal "hr"
    let b = star "b"
    let big = star "big"
    let i = star "i"
    let small = star "small"
    let sub = star "sub"
    let sup = star "sup"
    let tt = star "tt"


(* VB *)
    type i18nclass = [ `Bdo ]
    type shape = [ `Rect | `Circle | `Poly | `Default ]


    let a_datetime = string_attrib "datetime"

    let a_dir d =
      string_attrib "dir" (match d with `Rtl -> "rtl" | `Ltr -> "ltr")

(* CH *)
    let bdo ~dir ?(a = []) elts =
      XML.node ~a:(a_dir dir :: a) "bdo" elts
(* CH *)

    let a_shape d =
      string_attrib "shape"
        (match d with
          `Rect -> "rect"
        | `Circle -> "circle"
        | `Poly -> "poly"
        | `Default -> "default")
    let a_coords coords = 
      string_attrib "coords" (String.concat ","
                                (List.map string_of_int coords))

    let a_nohref `Nohref = string_attrib "nohref" "nohref"
    let a_usemap = string_attrib "usemap"
    let a_defer `Defer = string_attrib "defer" "defer"
    let a_label = string_attrib "label"

    let area ~alt ?(a = []) () =
      XML.leaf ~a:(a_alt alt :: a) "area"
    let map ~id ?(a = []) elt elts =
      XML.node ~a:(a_id id :: a) "map" (elt::elts)
    let del = star "del"
    let ins = star "ins"
    let script ~contenttype ?(a = []) elt =
      XML.node ~a:(a_type contenttype :: a) "script" [elt]
    let noscript = plus "noscript"
(* VB *)

    module FORMS =
      struct
        type t = [ `Option ]
        type form = [ `Form ]
        type formctrl_sans_label = [ `Input | `Select | `Textarea | `Button ]
        type formctrl = [ `Label | formctrl_sans_label ]
        type block = form
        type inline_sans_label = formctrl_sans_label
        type inline = formctrl
        type flow_sans_label = [block | inline_sans_label ]
        type flow = [ block | inline ]
      end

    module Basic_Forms =
      struct
        let form ~action ?(a = []) elt elts =
          XML.node ~a:(a_action action :: a) "form" (elt::elts)
        let input = terminal "input"
        let label = star "label"
        let option = unary "option"
        let select = plus "select"
        let textarea ~rows ~cols ?(a = []) elt =
          XML.node ~a:(a_rows rows :: a_cols cols :: a) "textarea" [elt]
      end

    let form ~action ?(a = []) elt elts =
      XML.node ~a:(a_action action :: a) "form" (elt::elts)
    let input = terminal "input"
    let label = star "label"
    let option = unary "option"
    let select = plus "select"
    let textarea ~rows ~cols ?(a = []) elt =
      XML.node ~a:(a_rows rows :: a_cols cols :: a) "textarea" [elt]
    let button = star "button"
    let legend = star "legend"
    let fieldset = star "fieldset"
    let optgroup ~label ?(a = []) elt elts =
      XML.node ~a:(a_label label :: a) "optgroup" (elt :: elts)

    module TABLES =
      struct
        type t = [ `Caption | `Td | `Th | `Tr ]
        type block = [ `Table ]
        type flow = block
      end

    let list_of_option = function
      | Some x -> [x]
      | None -> []

    let list_of_list_option = function
      | Some x -> x
      | None -> []

    module Basic_Tables =
      struct
        let a_align = a_align
        let a_scope = a_scope
        let a_valign = a_valign
        let caption = star "caption"
        let table ?caption ?a elt elts =
          XML.node ?a "table" (list_of_option caption @ elt :: elts)
        let td = star "td"
        let th = star "th"
        let tr = plus "tr"
      end

    let caption = star "caption"

    let cols_option = function
      | Some (`Cols c) -> c
      | Some (`Colgroups c) -> c
      | None -> []

    let table ?caption ?columns ?a elt elts =
      XML.node ?a "table"
        (list_of_option caption @ cols_option columns @ elt :: elts)

    let tablex ?caption ?columns ?thead ?tfoot ?a elt elts =
      XML.node ?a "table"
        (list_of_option caption @ cols_option columns @
         list_of_option thead @ list_of_option tfoot @ elt :: elts)

    let td = star "td"
    let th = star "th"
    let tr = plus "tr"

    let col = terminal "col"
    let colgroup = star "colgroup"
    let thead = plus "thead"
    let tbody = plus "tbody"
    let tfoot = plus "tfoot"

    let object_ = star "object"
    let param ~name ?(a = []) () =
      XML.leaf ~a:(a_name name :: a) "param"

    let img ~src ~alt ?(a = []) () =
      XML.leaf ~a:(a_src src :: a_alt alt :: a) "img"

    let frameset ?noframes ?a elt elts =
      XML.node ?a "frameset"
        (elt :: elts @ (match noframes with None -> [] | Some e -> [e]))
    let frame ~src ?(a = []) () =
      XML.leaf ~a:(a_src src :: a) "frame"
    let noframes = unary "noframes"
    let iframe = star "iframe"

    module METAINFORMATION =
      struct
        type t = [ `Meta ]
      end

    let meta ~content ?(a = []) () =
      XML.leaf ~a:(a_content content :: a) "meta"

    module STYLE_SHEET =
      struct
        type t = [ `Style ]
      end

    let style ~contenttype ?(a = []) elts =
      XML.node ~a:(a_type contenttype :: a) "style" elts

    module LINK =
      struct
        type t = [ `Link ]
      end

    let link = terminal "link"

    module BASE =
      struct
        type t = [ `Base ]
      end

    let base ~href ?(a = []) ()=
      XML.leaf ~a:(a_href href :: a) "base"

    let ruby_simple1 = binary "ruby"
    let ruby_simple2 = quadry "ruby"
    let ruby_complex = binary "ruby"

    let rbc = plus "rbc"
    let rtc = plus "rtc"
    let rtc_complex= plus "rtc"
    let rb = star "rb"
    let rt = star "rt"
    let rt_complex = star "rt"
    let rp = star "rp"

    let a_rbspan = int_attrib "rbspan"


(* VB *)
    type edit = [ `Ins | `Del ]
    type scripttag = [ `Script | `Noscript ]
    type misc = [ edit | scripttag ]

    module SPECIAL = struct
      type inline = [ `Img | `Map | `Object ]
      type block = [ `Table | `Form | `Fieldset ]
      type flow = [ inline | block ]
    end

(* VB *)

(* CH *)
    module RUBY = struct
      type inline = [ `Ruby_simple1 | `Ruby_simple2 | `Ruby_complex ]
      type flow =  inline 
    end

    type no_ruby_inline = [ TEXT.inline | PRESENTATION.inline | HYPERTEXT.inline | SPECIAL.inline | FORMS.inline | i18nclass ]
    type no_ruby_content = [ `PCDATA | no_ruby_inline | misc ]
(* CH *)

    type block =
        [ TEXT.block | PRESENTATION.block | FORMS.block | TABLES.block | SPECIAL.block | TEXT.heading | LIST.list | misc ]
    type block_sans_form =
        [ TEXT.block | PRESENTATION.block | TABLES.block | TEXT.heading | LIST.list | misc ]

    type flow =
        [ TEXT.flow | HYPERTEXT.flow | LIST.flow | FORMS.flow | TABLES.flow | PRESENTATION.flow | SPECIAL.flow | i18nclass | misc | RUBY.flow ]
    type flow_sans_table =
        [ TEXT.flow | HYPERTEXT.flow | LIST.flow | FORMS.flow | PRESENTATION.flow | SPECIAL.flow | i18nclass | misc | RUBY.flow ]

    type inline =
        [ TEXT.inline | HYPERTEXT.inline | PRESENTATION.inline
        | FORMS.inline | SPECIAL.inline | i18nclass | misc | RUBY.inline ]

    type inline_sans_a_mix =
        [ TEXT.inline | PRESENTATION.inline
        | FORMS.inline | SPECIAL.inline | i18nclass | misc | RUBY.inline ]

    type buttoncontent = (* VB *)
        [ TEXT.inline | PRESENTATION.inline
        | SPECIAL.inline | i18nclass | block_sans_form ]
    type precontent = inline
    type inline_sans_label =
        [ TEXT.inline | HYPERTEXT.inline | PRESENTATION.inline
        | FORMS.inline_sans_label | SPECIAL.inline | i18nclass | misc ]

    type heading = TEXT.heading


    (* I/O *)

    let compose_doctype dt args =
      "<!DOCTYPE " ^ dt ^ " PUBLIC " ^
      String.concat " " (List.map (fun a -> "\"" ^ a ^ "\"") args) ^ ">\n"

    type doctypes = 
        [ `HTML_v03_02 | `HTML_v04_01 | `XHTML_01_00 | `XHTML_01_01
        | `XHTML_05_00 | `Doctype of string ]

    let doctype = function
      | `HTML_v03_02 ->
          compose_doctype "html" ["-//W3C//DTD HTML 3.2 Final//EN"]
      | `HTML_v04_01 ->
          compose_doctype "html" ["-//W3C//DTD HTML 4.01//EN";
                                  "http://www.w3.org/TR/html4/strict.dtd"]
      | `XHTML_01_00 ->
          compose_doctype "html" ["-//W3C//DTD XHTML 1.0 Strict//EN";
                                  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"]
      | `XHTML_01_01 ->
          compose_doctype "html" ["-//W3C//DTD XHTML 1.1//EN";
                                  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"]
(*VVV Check *)
      | `XHTML_05_00 -> "<!DOCTYPE html>"
      | `Doctype s -> s

    let no_break =
      ["title";
       "h1"; "h2"; "h3"; "h4"; "h5"; "h6";
       "address"; "blockquote"; "div"; "p";
       "li"; "dd"; "dt"; "td"; "th"]

    let preformatted =
      ["pre"]

(*
    let output version ?encode ?encoding outs page =
      (* XML.decl ?encoding outs (); Does not work with IE *)
      outs (doctype version);
      XML.output ~preformatted ~no_break ?encode outs page

    let pretty_print version ?width ?encode ?encoding outs page =
      (* XML.decl ?encoding outs (); Does not work with IE *)
      outs (doctype version);
      XML.pretty_print ?width ~preformatted ~no_break ?encode outs page
*)

    (* Tools *)

    let version = function
      | `XHTML_01_00 -> "XHTML 1.0"
      | `XHTML_01_01 -> "XHTML 1.1"
      | `XHTML_05_00 -> "XHTML 5.0"

    let standard = function
      | `XHTML_01_00 -> uri_of_string "http://www.w3.org/TR/xhtml1/"
      | `XHTML_01_01 -> uri_of_string "http://www.w3.org/TR/xhtml11/"
      | `XHTML_05_00 -> uri_of_string "http://www.w3.org/TR/xhtml5"

(*
    let validator =
      "http://validator.w3.org/check/referer"

    let compose_validator_icon icon alt =
      a ~a:[a_href validator]
        [img ~src:icon ~alt ~a:[a_height (`Pixels 31); a_width (`Pixels 88)] ()]

    let validator_icon = function
      | `XHTML_01_00 -> compose_validator_icon
            "http://www.w3.org/Icons/valid-xhtml10" "Valid XHTML 1.0!"
      | `XHTML_01_01 -> compose_validator_icon
            "http://www.w3.org/Icons/valid-xhtml11" "Valid XHTML 1.1!"
        *)

(*
    let addto_class name =
      XML.amap (fun _ a -> XML.add_space_sep_attrib "class" name a)

    let addto_class1 name =
      XML.amap1 (fun _ a -> XML.add_space_sep_attrib "class" name a)

    let set_rowspan n =
      XML.amap1 (fun _ a -> XML.add_int_attrib "rowspan" n a)

    let rewrite_hrefs f =
      XML.amap (fun _ a -> XML.map_string_attrib ((=) "href") f a)

    let amap = XML.amap
    let amap1 = XML.amap1

    let rm_attrib = XML.rm_attrib
    let rm_attrib_from_list = XML.rm_attrib_from_list
*)

    (******************************************************************)
    (* In the following, my own stuffs for Ocsigen -- Vincent: *)

    let tot x = x
    let totl x = x
    let toelt x = x
    let toeltl x = x

  end

module M_01_00 : T_01_00 =
  struct
    module M = Version
    include M
    let xhtml_version = `XHTML_01_00
    let version = M.version xhtml_version
    let standard = M.standard xhtml_version
(*    let output = M.output xhtml_version
    let pretty_print = M.pretty_print xhtml_version *)
(*    let validator_icon () = M.validator_icon xhtml_version*)
  end

module M_01_01 : T_01_01 =
  struct
    module M = Version
    include M
    let xhtml_version = `XHTML_01_01
    let version = M.version xhtml_version
    let standard = M.standard xhtml_version
(*    let output = M.output xhtml_version
    let pretty_print = M.pretty_print xhtml_version *)
(*    let validator_icon () = M.validator_icon xhtml_version*)
  end

module M = M_01_01



