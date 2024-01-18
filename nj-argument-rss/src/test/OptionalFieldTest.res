
type foo = {
  x?: int
}

type bar = {
  y: option<int>
}

Console.log({}: foo)
Console.log({x: ?None})

let blah: option<int> = Some(7)
Console.log({x: ?blah})

let blah: option<int> = None
Console.log({
  "arg": {x: ?blah}
})

let b = { y: None }
Console.log({x: ?b.y})

