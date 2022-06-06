
let log = Js.Console.log

type rss = {
  "rss": {
    "$": {
      "version": string
    },
    "channel": {
      "title": string,
      "description": string,
      "item": array<{
        "title": string,
        "description": string,
        "link": string,
        "pubDate": string
      }>
    }
  }
}

type builder
@new @module("xml2js") external newBuilder: () => builder = "Builder"
@send external buildObjectRSS: (builder, rss) => string = "buildObject"

type arg = Model.arg

let generateRSS: array<arg> => string = args => {
  let builder = newBuilder()
  builder->buildObjectRSS({"rss": {
    "$": {
      "version": "2.0"
    },
    "channel": {
      "title": "NJ Supreme Court Oral Arguments",
      "description": "Oral argument mp3s from the NJ States Supreme Court",
      "item": args->Js.Array2.map(arg => {
        {
          "title": arg.caption,
          "description": arg.description,
          "link": arg.mp3URL,
          "pubDate": arg.date->Js.Date.toUTCString
        }
      })
    }
  } })
}

