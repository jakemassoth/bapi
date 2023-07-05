let stringEquals = (a: string, b) => {
  a == b
}

let testToString = () => {
  Tests.run(
    __POS_OF__("testing Route.toString"),
    list{Route.Variable("varOne"), Route.Constant("constantOne")}->Route.toString,
    stringEquals,
    "/:varOne/constantOne",
  )
}

let testResolve1 = () => {
  let possibleRoutes = list{
    list{Route.Variable("varOne"), Route.Constant("constantOne")},
    list{Route.Variable("varTwo"), Route.Constant("constantTwo")},
  }

  Tests.run(
    __POS_OF__("testing Route.resolve"),
    "/something/constantTwo"->Route.resolve(possibleRoutes)->Belt.Option.getUnsafe->Route.toString,
    stringEquals,
    "/:varTwo/constantTwo",
  )
  Tests.run(
    __POS_OF__("testing Route.resolve"),
    "/something/constantOne"->Route.resolve(possibleRoutes)->Belt.Option.getUnsafe->Route.toString,
    stringEquals,
    "/:varOne/constantOne",
  )
}

let testResolve2 = () => {
  let possibleRoutes = list{
    list{Route.Variable("varOne"), Route.Constant("constantOne")},
    list{Route.Variable("varOne"), Route.Constant("constantOne"), Route.Variable("varTwo")},
  }

  Tests.run(
    __POS_OF__("testing Route.resolve"),
    "/something/constantOne/somethingElse"
    ->Route.resolve(possibleRoutes)
    ->Belt.Option.getUnsafe
    ->Route.toString,
    stringEquals,
    "/:varOne/constantOne/:varTwo",
  )
  Tests.run(
    __POS_OF__("testing Route.resolve"),
    "/something/constantOne"->Route.resolve(possibleRoutes)->Belt.Option.getUnsafe->Route.toString,
    stringEquals,
    "/:varOne/constantOne",
  )
}

let run = () => {
  testToString()
  testResolve1()
  testResolve2()
}
