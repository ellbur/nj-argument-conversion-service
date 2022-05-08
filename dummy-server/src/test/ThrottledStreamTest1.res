
open Js.Console
open TickerStream
open ThrottledStream
open NodeJs.Stream.Readable

let s1 = makeTicker(~periodMS=500, ~payloadSize=100)
let s2 = makeThrottled(s1, ~bps=10.0, ~windowSizeS=1.0)

s2->onData(chunk => {
  log2("chunk", chunk)
})->ignore

