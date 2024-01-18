
ArgsListing2.listArgs()->Promise.thenResolve(args => {
  Console.log(RSSGeneration.generateRSS(args))
})->ignore

