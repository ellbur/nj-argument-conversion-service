
type item = {
  x?: int
}

let x1 = None
let x2 = if Math.random() < 2.0 { None } else { Some(3) }

// {}
Console.log({x: ?x1})

// {x: undefined}
Console.log({x: ?x2})

