
module HtmlElement = {
  type t
  
  @send external getElementsByTagName: (t, string) => array<t> = "getElementsByTagName"
  @send external getAttribute: (t, string) => option<string> = "getAttribute"
  @send external querySelectorAll: (t, string) => array<t> = "querySelectorAll"
  @send external querySelector: (t, string) => option<t> = "querySelector"
  @get external nextElementSibling: t => option<t> = "nextElementSibling"
  @get external rawTagName: t => string = "rawTagName"
  @get external outerHTML: t => string = "outerHTML"
  @get external innerText: t => string = "innerText"
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

let stringToMonth1 = t => {
  let sw = String.startsWith
  let t = t->String.toLowerCase
  let f = p => t->sw(p)
  
  if      f("jan") { Some(1) }
  else if f("feb") { Some(2) }
  else if f("mar") { Some(3) }
  else if f("apr") { Some(4) }
  else if f("may") { Some(5) }
  else if f("jun") { Some(6) }
  else if f("jul") { Some(7) }
  else if f("aug") { Some(8) }
  else if f("sep") { Some(9) }
  else if f("oct") { Some(10) }
  else if f("nov") { Some(11) }
  else if f("dec") { Some(12) }
  else { None}
}

let html = Node.Fs.readFileAsUtf8Sync("temp/webcast-archive")

let parsed = parseHTML(html)

let p5s = parsed->HtmlElement.querySelectorAll("p.h5")

p5s->Array.forEach(p5 => {
  p5->HtmlElement.querySelector("u")->Option.forEach(u => {
    let caption = u->HtmlElement.innerText

    p5->HtmlElement.nextElementSibling->Option.forEach(followingDiv => {
      let divAs = followingDiv->HtmlElement.querySelectorAll("a")
      let mp3URL = divAs->Array.findMap(a => {
        a->HtmlElement.getAttribute("href")->Option.flatMap(href => {
          if href->String.endsWith(".mp3") {
            Some(href)
          }
          else {
            None
          }
        })
      })
      mp3URL->Option.forEach(mp3URL => {
        let dateMatch = RegExp.exec(%re("/(\d+)\+((?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*)\+(\d{4,})/"), mp3URL)
        let date = dateMatch->Option.flatMap(dateMatch => {
          switch dateMatch->RegExp.Result.matches {
            | [dayStr, monthStr, yearStr] => {
              let day = dayStr->Int.fromString->Option.getExn
              let month = monthStr->stringToMonth1
              let year = yearStr->Int.fromString->Option.getExn
              Some((year, month, day))
            }
            | _ => None
          }
        })

        Js.Console.log3(caption, date, mp3URL)
      })
    })
  })
})

