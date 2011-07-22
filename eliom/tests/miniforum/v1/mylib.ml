open Eliom_predefmod.Xhtml
open XHTML.M
open Eliom_services

let create_page sp mytitle mycontent =
  Lwt.return
    (html
       (head 
          (title (pcdata mytitle)) 
          [css_link (make_uri ~service:(static_dir sp) ~sp ["style.css"]) ()])
       (body ((h1 [pcdata mytitle])::mycontent)))



(* Messages database *)

(* For the example, I'm storing messages in memory.
   I should use a database instead.
   Here are some predefined messages: *)
let table = ref ["Welcome to Eliom's world.";
                 "Hello! This is the second message.";
                 "I am the third message of the forum."]

let display_message_list () =
  match !table with
  | [] -> p [em [pcdata "No message"]]
  | m::l ->
      ul
        (li [pcdata m])
        (List.map (fun m -> li [pcdata m]) l)

let display_message n =
  try
    let m = List.nth !table n in
    p [pcdata m]
  with 
  | Failure _
  | Invalid_argument _ -> p [em [pcdata "no such message"]]

let register_message msg = table := !table@[msg]

