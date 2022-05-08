
open Js.Console
open TickerStream
open NodeJs.Stream.Readable

let ticker = makeTicker(~periodMS=500, ~payloadSize=5)

ticker->onData(chunk => {
  log2("chunk", chunk)
})->ignore

