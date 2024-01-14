
let {then, thenResolve, resolve} = module(Promise)
let alen = Js.Array.length
let afe = Js.Array2.forEach
let ofe = Belt.Option.forEach
let log = Js.Console.log
let x = Belt.Option.getExn
type promise<'a> = Promise.t<'a>
open Model

type htmlElement = {
  text: string
}
@module("node-html-parser") external parseHTML: string => htmlElement = "parse"
@send external getElementsByTagName: (htmlElement, string) => array<htmlElement> = "getElementsByTagName"
@send external querySelectorAll: (htmlElement, string) => array<htmlElement> = "querySelectorAll"
@send external getAttribute: (htmlElement, string) => string = "getAttribute"

let encodeSpaces: string => string = text => {
  text->Js.String2.replaceByRe(%re("/ /g"), "%20")
}

