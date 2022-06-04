
let proc = NodeJs.ChildProcess.spawnWith(
  "/usr/bin/ffmpeg",
  [
    "-i",
    "http://localhost:8333/foo.mp4",
    "-f",
    "mp3",
    "-"
  ],
  NodeJs.ChildProcess.spawnOptions(())
)

let procOut = proc->NodeJs.ChildProcess.stdout

switch procOut {
  | None => {
    Js.Console.log("No stdout :(")
  }
  | Some(procOut) => {
    procOut->NodeJs.Stream.Readable.onData(chunk => {
      Js.Console.log2("Got chunk of length", chunk->NodeJs.Buffer.length)
    })->ignore
  }
}

proc->NodeJs.ChildProcess.onExit(code => {
  Js.Console.log2("Exited with code", code)
})->ignore

