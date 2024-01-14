
module HtmlElement = {
  type t
  
  @send external getElementsByTagName: (t, string) => array<t> = "getElementsByTagName"
  @send external getAttribute: (t, string) => option<string> = "getAttribute"
  @send external querySelectorAll: (t, string) => array<t> = "querySelectorAll"
}

@module("node-html-parser") external parseHTML: string => HtmlElement.t = "parse"

module Node = {
  module Fs = {
    type readFileSyncOptions = {
      "encoding": string
    }
    @module("fs") external readFileSync: (string, readFileSyncOptions) => string = "readFileSync"
    
    let readFileAsUtf8Sync = path => readFileSync(path, {"encoding": "utf-8"})
  }
}

let html = Node.Fs.readFileAsUtf8Sync("temp/webcast-archive")

let parsed = parseHTML(html)

let p5s = parsed->HtmlElement.querySelectorAll("p.h5")
let p5sFirst = p5s[0]

Js.Console.log(p5sFirst)

