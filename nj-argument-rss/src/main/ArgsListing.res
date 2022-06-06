
let {then, thenResolve, resolve} = module(Promise)
let alen = Js.Array.length
let afe = Js.Array2.forEach
let ofe = Belt.Option.forEach
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
  data: Js.Json.t,
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

type doc = {
  "webcast": array<{
    "ScheduledDate": string,
    "Title": string,
    "Desc": string,
    "Video": option<array<{
      "AudioURL": option<string>
    }>>
  }>
}

external jsonToDoc: Js.Json.t => doc = "%identity"

let encodeSpaces: string => string = text => {
  text->Js.String2.replaceByRe(%re("/ /g"), "%20")
}

let listArgs: () => promise<Js.Array.t<arg>> = () => {
  axiosGet("https://www.njcourts.gov/public/assets/js/objects/webcast/webcast.json")->then(resp => {
    let res = [ ]
    let doc = resp.data->jsonToDoc
    let webcast = doc["webcast"]
    webcast->afe(wc => {
      wc["Video"]->ofe(videos => {
        videos->afe(video => {
          video["AudioURL"]->ofe(mp3Path => {
            let mp3URL = "https://www.njcourts.gov" ++ (mp3Path->encodeSpaces)
            let (year, month, date) = switch wc["ScheduledDate"]->Js.String2.split("/") {
              | [monthString, dayString, yearString] => {
                let year = yearString->Belt.Float.fromString->Belt.Option.getExn
                let month = monthString->Belt.Float.fromString->Belt.Option.getExn -. 1.0
                let date = dayString->Belt.Float.fromString->Belt.Option.getExn
                (year, month, date)
              }
              | others => (0.0, 0.0, 0.0)
            }
            res->Js.Array2.push({
              caption: wc["Title"],
              date: Js.Date.makeWithYMD(
                ~year = year,
                ~month = month,
                ~date = date,
                ()
              ),
              description: wc["Desc"],
              mp3URL
            })->ignore
          })
        })
      })
    })
    res->Js.Array2.sortInPlaceWith((a, b) => {
      let a = a.date->Js.Date.getUTCMilliseconds
      let b = b.date->Js.Date.getUTCMilliseconds
      if a < b {
        -1
      }
      else {
        1
      }
    })->ignore
    resolve(res)
  })
}

