(* TyXML
 * http://www.ocsigen.org/tyxml
 * Copyright (C) 2004 by Thorsten Ohl <ohl@physik.uni-wuerzburg.de>
 * Copyright (C) 2007 by Vincent Balat, Gabriel Kerneis
 * Copyright (C) 2010 by Cecile Herbelin
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
 * Foundation, Inc., 51 Franklin Street, Suite 500, Boston, MA 02111-1307, USA.
 *)

(** Typesafe constructors for HTML5 documents (Functorial interface) *)

module Make(XML : XML_sigs.T)(SVG : SVG_sigs.T with module XML := XML)
  : HTML5_sigs.T with module XML := XML
		  and module SVG := SVG
