{shared{
  let width = 700
  let height = 400
}}

{client{
  let draw ctx (color, size, (x1, y1), (x2, y2)) =
    ctx##strokeStyle <- (Js.string color);
    ctx##lineWidth <- float size;
    ctx##beginPath();
    ctx##moveTo(float x1, float y1);
    ctx##lineTo(float x2, float y2);
    ctx##stroke()
}}
module H = XHTML5.M

module App = Eliom_output.Eliom_appl (struct
  let application_name = "client"
  let params = Eliom_output.default_appl_params
end)

let main_service =
  App.register_service ~path:[""] ~get_params:Eliom_parameters.unit
    (fun () () ->
      Eliom_services.onload {{
        let canvas = Dom_html.createCanvas Dom_html.document in
        let ctx = canvas##getContext (Dom_html._2d_) in
        canvas##width <- width; 
        canvas##height <- height;
        ctx##lineCap <- Js.string "round";

        Dom.appendChild Dom_html.document##body canvas;

        draw ctx ("#ffaa33", 12, (10, 10), (200, 100))
      }};
      Lwt.return [H.h1 [H.pcdata "Graffiti"]]
    )
