
let encode = text => 
  NodeJs.Buffer.fromString(text)->NodeJs.Buffer.toStringWithEncoding(NodeJs.StringEncoding.base64)
  
let decode = text => 
  NodeJs.Buffer.fromStringWithEncoding(text, NodeJs.StringEncoding.base64)->NodeJs.Buffer.toString


Js.Console.log("http://localhost:8000/test/" ++ encode("foo.mp4") ++ "/test.mp3")

Js.Console.log("http://localhost:8000/real/" ++ encode("2022/04%20April%202022/26%20April%202022/a_4_21.mp4") ++ "/a_4_21.mp3")

