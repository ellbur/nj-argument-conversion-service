
type request<'a> = {
  "path": string,
  "url": string,
  "params": 'a
}
type response
type httpFunction<'a> = (request<'a>, response) => ()
type app
type express = (.unit) => app

@module external express: express = "express"
@send external get: (app, string, httpFunction<'a>) => () = "get"
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
  let realUpstreamServer = process->env->Js.Dict.get("UPSTREAM")->getWithDefault("https://www.njcourts.gov/videos/")
  let testUpstreamServer = process->env->Js.Dict.get("TEST_UPSTREAM")->getWithDefault("https://nj-arg-dummy-server-3y3zfcwkiq-ue.a.run.app/")
}
let {port, realUpstreamServer, testUpstreamServer} = module(Environment)

let app = express(.())

let encode = text => 
  NodeJs.Buffer.fromString(text)->NodeJs.Buffer.toStringWithEncoding(NodeJs.StringEncoding.base64)
  
let decode = text => 
  NodeJs.Buffer.fromStringWithEncoding(text, NodeJs.StringEncoding.base64)->NodeJs.Buffer.toString

app->get("/:upstream/:key/:file", (req, res) => {
  let params = req["params"]
  let upstream: string = params["upstream"]
  let key: string = params["key"]
  let file: string = params["file"]
  
  Js.Console.log4("Got request for", upstream, key, file)
  
  (switch upstream {
    | "real" => Some(realUpstreamServer)
    | "test" => Some(testUpstreamServer)
    | other => {
      Js.Console.log2("Got request for unknown upstream", other)
      res->status(400)
      res->send("Upstream must be 'real' or 'test'")
      None
    }
  })->Belt.Option.forEach(upstreamServer => {
    Js.Console.log2("Using upstream", upstreamServer)
    
    let {spawnWith, spawnOptions, stdout} = module(NodeJs.ChildProcess)
    let {pipe} = module(NodeJs.Stream.Readable)
    let {getExn} = module(Belt.Option)

    let upstreamURL = upstreamServer ++ decode(key)
    
    Js.Console.log2("Upstream mp4", upstreamURL)
    
    let proc = spawnWith(
      "/usr/bin/ffmpeg",
      [
        "-i",
        upstreamURL,
        "-f",
        "mp3",
        "-"
      ],
      spawnOptions(())
    )

    let procOut = proc->stdout->getExn
    
    res->status(200)
    res->set("Content-Type", "audio/mp3")
    procOut->pipe(res->responseStream)->ignore
  })
})

Js.Console.log2("Starting server on port", port)
app->listen(port)

