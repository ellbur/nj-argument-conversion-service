
type request = {
  "path": string,
  "url": string
}
type response
type httpFunction = (request, response) => ()
type app
type express = (.unit) => app

@module external express: express = "express"
@send external get: (app, string, httpFunction) => () = "get"
@send external listen: (app, int) => () = "listen"
@send external send: (response, string) => () = "send"
@send external set: (response, string, string) => () = "set"
@send external status: (response, int) => () = "status"
external responseStream: response => NodeJs.Stream.subtype<NodeJs.Stream.writable<NodeJs.Buffer.t>> = "%identity"

module Environment = {
  let {flatMap, getWithDefault} = module(Belt.Option)
  let {fromString} = module(Belt.Int)
  let {process, env} = module(NodeJs.Process)
  
  let port = process->env->Js.Dict.get("PORT")->flatMap(fromString)->getWithDefault(8000)
  let upstreamServer = process->env->Js.Dict.get("UPSTREAM")->getWithDefault("http://localhost:8333/")
}
let {port, upstreamServer} = module(Environment)

let app = express(.())

app->get("/foo.mp4", (_req, res) => {
  res->status(200)
  res->set("Content-Type", "video/mp4")
})

app->listen(port)

