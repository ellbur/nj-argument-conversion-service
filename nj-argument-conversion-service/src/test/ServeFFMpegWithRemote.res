
let {log, log2} = module(Js.Console)

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

app->get("/foo.mp3", (_req, res) => {
  let {spawnWith, spawnOptions, stdout} = module(NodeJs.ChildProcess)
  let {pipe} = module(NodeJs.Stream.Readable)
  let {getExn} = module(Belt.Option)
  
  log("Got connection")
  
  res->status(200)
  res->set("Content-Type", "audio/mp3")
  
  let proc = spawnWith(
    "/usr/bin/ffmpeg",
    [
      "-i",
      "http://localhost:8333/foo.mp4",
      "-f",
      "mp3",
      "-"
    ],
    spawnOptions(())
  )
  
  let procOut = proc->stdout->getExn
  
  procOut->pipe(res->responseStream)->ignore
})

let port = {
  let {flatMap, getWithDefault} = module(Belt.Option)
  let {fromString} = module(Belt.Int)
  let {process, env} = module(NodeJs.Process)
  
  process->env->Js.Dict.get("PORT")->flatMap(fromString)->getWithDefault(8111)
}

log2("Starting server on port", port)
app->listen(port)

