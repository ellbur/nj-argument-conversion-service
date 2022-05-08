
let s1 = NodeJs.Fs.createReadStream("resources/d_156_20.mp4")
let s2 = ThrottledStream.makeThrottled(s1, ~bps=100e3, ~windowSizeS=1.0)

s2->NodeJs.Stream.Readable.onData(chunk => {
  Js.Console.log3("Got chunk of", chunk->NodeJs.Buffer.length, "bytes")
})->ignore

