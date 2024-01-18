
let {then, thenResolve, resolve} = module(Promise)
let alen = Array.length
let afe = Array.forEach
let ofe = Option.forEach
let log = Console.log
let x = Belt.Option.getExn
let oToArray = o => switch o { | None => [] | Some(x) => [x] }

let todo = () => Exn.raiseError("Not implemented")
  
open Model

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

let webcastURL = "https://www.njcourts.gov/public/webcast-archive"

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

let listArgs: () => promise<Js.Array.t<arg>> = async () => {
  let htmlText = (await Axios.get(webcastURL)).data
  let parsed = parseHTML(htmlText)
  
  let p5s = parsed->HtmlElement.querySelectorAll("p.h5")

  let res = p5s->Array.flatMap(p5 => {
    p5->HtmlElement.querySelector("u")->oToArray->Array.flatMap(u => {
      let caption = u->HtmlElement.innerText

      p5->HtmlElement.nextElementSibling->oToArray->Array.flatMap(followingDiv => {
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
        mp3URL->oToArray->Array.flatMap(mp3URL => {
          let dateMatch = RegExp.exec(%re("/(\d+)\+((?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*)\+(\d{4,})/"), mp3URL)
          let ymd = dateMatch->Option.flatMap(dateMatch => {
            switch dateMatch->RegExp.Result.matches {
              | [dayStr, monthStr, yearStr] => {
                let day = dayStr->Int.fromString->Option.getExn
                let month = monthStr->stringToMonth1->Option.getExn
                let year = yearStr->Int.fromString->Option.getExn
                Some((year, month, day))
              }
              | _ => None
            }
          })

          let date = ymd->Option.map(((year, month, day)) => {
            Date.makeWithYMD(
              ~year,
              ~month = month - 1,
              ~date = day
            )
          })
          
          [{
            caption,
            date,
            description: None,
            mp3URL
          }]
        })
      })
    })
  })
  
  res->Array.sort((a, b) => {
    switch (a.date, b.date) {
      | (Some(a), Some(b)) => {
        let a = a->Js.Date.getUTCMilliseconds
        let b = b->Js.Date.getUTCMilliseconds
        if a < b {
          Ordering.less
        }
        else {
          Ordering.greater
        }
      }
      | (None, Some(_)) => Ordering.greater
      | _ => Ordering.less
    }
  })
  
  res
}

