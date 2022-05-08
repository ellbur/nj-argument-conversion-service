
@send external pushBool: (NodeJs.Stream.Readable.t<'r>, 'r) => bool = "push"

let makeTicker = (~periodMS: int, ~payloadSize: int) => {
  open NodeJs.Stream.Readable
  open Js.Global
  open Belt.Option
  let now = Js.Date.now
  let toInt = Belt.Float.toInt
  
  let x = ref(0)
  let makePayload = () => {
    let res = [ ]
    let rec loop = i => {
      if i < payloadSize {
        res->Js.Array2.push(x.contents)->ignore
        x := x.contents + 1
        loop(i + 1)
      }
    }
    loop(0)
    NodeJs.Buffer.fromArray(res)
  }
  
  let timer = ref(None)
  let lastPushTime = ref(now()->toInt)
  let full = ref(false)
  
  make(makeOptions(
    ~read = @this (s, ~size) => {
      full := false
      
      if timer.contents == None {
        let t1 = lastPushTime.contents
        let t2 = now()->toInt
        let numToPush = (t2 - t1) / periodMS
        
        if numToPush > 0 {
          let rec loop = i => {
            if i < numToPush {
              switch s->pushBool(makePayload()) {
                | true => loop(i + 1)
                | false => {
                  full := true
                }
              }
            }
          }
          loop(0)
          
          lastPushTime := t2
        }
        else {
          let remaining = t1 + periodMS - t2
          timer := Some(setTimeout(() => {
            timer := None
            if !full.contents {
              if !(s->pushBool(makePayload())) {
                full := true
              }
              lastPushTime := now()->toInt
            }
          }, remaining))
        }
      }
      
      ()
    },

    ~destroy = @this (s, ~error, ~callback) => {
      timer.contents->forEach(timer => {
        clearTimeout(timer)
      })
    },

    ()
  ))
}

