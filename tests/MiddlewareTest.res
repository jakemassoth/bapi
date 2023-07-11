let resultIsOkAndMatches = (result, expected) => {
  let matches = f =>
    switch f() {
    | Belt.Result.Ok(res) => res == expected
    | Belt.Result.Error(_) => false
    }

  switch result {
  | Belt.Result.Ok(f) => matches(f)
  | Belt.Result.Error(_) => false
  }
}

let resultIsErrorAndMatches = (result, expected) => {
  switch result {
  | Belt.Result.Ok(_) => false
  | Belt.Result.Error(res) => res == expected
  }
}

let testSimple = () => {
  let middleware = Middleware.make()->Middleware.route(
    list{Route.Constant("test")},
    Method.GET,
    () => Belt.Result.Ok({
      status: 200,
      payload: "test",
    }),
  )

  let f = "/test"->Router.resolve(Method.GET, middleware)

  Tests.run(
    __POS_OF__("testing middleware (1)"),
    f,
    resultIsOkAndMatches,
    {payload: "test", status: 200},
  )
}

let testMethodNotAllowedError = () => {
  let middleware = Middleware.make()->Middleware.route(
    list{Route.Constant("test")},
    Method.GET,
    () => Belt.Result.Ok({
      status: 200,
      payload: "test",
    }),
  )

  let f = "/test"->Router.resolve(Method.POST, middleware)

  Tests.run(
    __POS_OF__("testing middleware (method not allowed)"),
    f,
    resultIsErrorAndMatches,
    {
      payload: {
        err: "method-not-allowed",
        msg: "Method is not allowed",
        details: `{"accepted_methods":"GET"}`,
      },
      status: 405,
    },
  )
}

let testRouteNotFoundError = () => {
  let middleware = Middleware.make()->Middleware.route(
    list{Route.Constant("test")},
    Method.GET,
    () => Belt.Result.Ok({
      status: 200,
      payload: "test",
    }),
  )

  let f = "/test1"->Router.resolve(Method.GET, middleware)

  Tests.run(
    __POS_OF__("testing middleware (endpoint not found)"),
    f,
    resultIsErrorAndMatches,
    {
      payload: {
        err: "endpoint-not-found",
        msg: "The endpoint requested was not found",
        details: "{}",
      },
      status: 404,
    },
  )
}

let run = () => {
  testSimple()
  testMethodNotAllowedError()
  testRouteNotFoundError()
}
