
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

let app = express(.())

app->get("/foo.mp4", (_req, res) => {
  let connId = Js.Math.random_int(0, 100)
  Js.Console.log2("Got connection", connId)
  
  let s1 = NodeJs.Fs.createReadStream("resources/d_156_20.mp4")
  
  s1->NodeJs.Fs.ReadStream.onError(e => {
    Js.Console.log2("Erroring connection", connId)
    Js.Console.log(e)
    res->status(500)
    res->set("Content-Type", "text/plain")
    res->send(e->Js.String2.make)
  })->ignore
  
  s1->NodeJs.Fs.ReadStream.onReady(_ => {
    let s2 = ThrottledStream.makeThrottled(s1, ~bps=10e6, ~windowSizeS=1.0)
  
    Js.Console.log2("Satisfying connection", connId)
    res->status(200)
    res->set("Content-Type", "video/mp4")
  
    s2->NodeJs.Stream.Readable.pipe(res->responseStream)->ignore
  })->ignore
})

let port = {
  let {flatMap, getWithDefault} = module(Belt.Option)
  let {fromString} = module(Belt.Int)
  let {process, env} = module(NodeJs.Process)
  
  process->env->Js.Dict.get("PORT")->flatMap(fromString)->getWithDefault(8333)
}

Js.Console.log2("Starting server on port", port)
app->listen(port)

