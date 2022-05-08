
@send external pushBool: (NodeJs.Stream.Readable.t<'r>, 'r) => bool = "push"
@send external pushNull: (NodeJs.Stream.Readable.t<'r>, Js.Null.t<NodeJs.Buffer.t>) => bool = "push"
@send external subarray: (NodeJs.Buffer.t, ~start: int, ~end: int) => NodeJs.Buffer.t = "subarray"

let makeThrottled = (source, ~bps, ~windowSizeS) => {
  module Ar = Js.Array2
  module B = NodeJs.Buffer
  let {pause, resume, destroy, onData, onEnd} = module(NodeJs.Stream)
  let {make, makeOptions} = module(NodeJs.Stream.Readable)
  let {setTimeout, clearTimeout} = module(Js.Global)
  let {forEach} = module(Belt.Option)
  let {max_int, floor, ceil} = module(Js.Math)
  let {now} = module(Js.Date)
  let {toFloat} = module(Belt.Int)
  
  let timer = ref(None)
  let internalBuffer = [ ]
  let lastMark = ref(now() /. 1e3)
  let bytesSinceLastMark = ref(0.0)
  
  let rec process = s => {
    let rec processLoop = () => {
      if internalBuffer->Ar.length == 0 {
        source->resume->ignore
      }
      else {
        let now = now() /. 1e3
        if now > lastMark.contents +. windowSizeS {
          bytesSinceLastMark := bytesSinceLastMark.contents -. (now -. lastMark.contents -. windowSizeS) *. bps
          lastMark := now -. windowSizeS
        }
        
        let maxAllowed = floor((now -. lastMark.contents) *. bps -. bytesSinceLastMark.contents)
        
        if maxAllowed > 0 {
          let head = internalBuffer[0]
          
          if head->B.length < maxAllowed {
            internalBuffer->Ar.pop->ignore
            bytesSinceLastMark := bytesSinceLastMark.contents +. head->B.length->toFloat
            if !(s->pushBool(head)) {
              source->pause->ignore
            }
            else {
              processLoop()
            }
          }
          else {
            let chunk1 = head->subarray(~start=0, ~end=maxAllowed)
            let chunk2 = head->subarray(~start=maxAllowed, ~end=head->B.length)
            internalBuffer[0] = chunk2
            bytesSinceLastMark := bytesSinceLastMark.contents +. chunk1->B.length->toFloat
            s->pushBool(chunk1)->ignore
            source->pause->ignore
            timer := Some(setTimeout(() => {
              timer := None
              process(s)
            }, max_int(ceil(windowSizeS /. 3.0 *. 1e3), 1)))
          }
        }
        else {
          source->pause->ignore
          timer := Some(setTimeout(() => {
            timer := None
            process(s)
          }, max_int(ceil(windowSizeS /. 3.0 *. 1e3), 1)))
        }
      }
    }
    processLoop()
  }
  
  let enterProcess = s => {
    timer.contents->forEach(timer => {
      clearTimeout(timer)
    })
    timer := None
    process(s)
  }
  
  let s = make(makeOptions(
    ~read = @this (s, ~size) => {
      enterProcess(s)
    },

    ~destroy = @this (s, ~error, ~callback) => {
      source->destroy->ignore
      timer.contents->forEach(timer => {
        clearTimeout(timer)
      })
    },

    ()
  ))
  
  source->onData(chunk => {
    internalBuffer->Ar.push(chunk)->ignore
    enterProcess(s)
  })->ignore
  
  source->onEnd(() => {
    Js.Console.log("Got end event")
    s->pushNull(Js.Null.empty)->ignore
  })->ignore
  
  s
}


