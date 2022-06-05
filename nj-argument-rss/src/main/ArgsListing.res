
let {then, thenResolve, resolve} = module(Promise)
let alen = Js.Array.length
let afe = Js.Array2.forEach
let log = Js.Console.log
let x = Belt.Option.getExn
type promise<'a> = Promise.t<'a>
open Model

type axiosRes = {
  responseUrl: string
}
type axiosRequest = {
  res: axiosRes
}
type axiosResponse = {
  data: string,
  request: axiosRequest
}
@module("axios") external axiosGet: string => Promise.t<axiosResponse> = "get"

type htmlElement = {
  text: string
}
@module("node-html-parser") external parseHTML: string => htmlElement = "parse"
@send external getElementsByTagName: (htmlElement, string) => array<htmlElement> = "getElementsByTagName"
@send external querySelectorAll: (htmlElement, string) => array<htmlElement> = "querySelectorAll"
@send external getAttribute: (htmlElement, string) => string = "getAttribute"

let listArgs: () => promise<Js.Array.t<arg>> = () => {
  resolve([])
}

