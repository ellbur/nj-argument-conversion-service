
ArgsListing.listArgs()->Promise.thenResolve(args => {
  Js.Console.log(RSSGeneration.generateRSS(args))
})->ignore

