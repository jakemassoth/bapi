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
  let middleware = Middleware.make()->Middleware.route(list{Route.Constant("test")}, Method.GET, (
    ~params,
  ) => Belt.Result.Ok({
    status: 200,
    payload: "test",
  }))

  let f = middleware->Middleware.resolve("/test", Method.GET)

  Tests.run(
    __POS_OF__("testing middleware (simple)"),
    f,
    resultIsOkAndMatches,
    {payload: "test", status: 200},
  )
}

let testParams = () => {
  let middleware = Middleware.make()->Middleware.route(
    list{Route.Variable("var1"), Route.Variable("var2")},
    Method.GET,
    (~params) => {
      let var1 = params->Belt.Map.String.getExn("var1")
      let var2 = params->Belt.Map.String.getExn("var2")
      Belt.Result.Ok({
        status: 200,
        payload: `${var1}:${var2}`,
      })
    },
  )

  let f = middleware->Middleware.resolve("/test1/test2", Method.GET)

  Tests.run(
    __POS_OF__("testing middleware (params)"),
    f,
    resultIsOkAndMatches,
    {payload: "test1:test2", status: 200},
  )
}

let testMethodNotAllowedError = () => {
  let middleware = Middleware.make()->Middleware.route(list{Route.Constant("test")}, Method.GET, (
    ~params,
  ) => Belt.Result.Ok({
    status: 200,
    payload: "test",
  }))

  let f = middleware->Middleware.resolve("/test", Method.POST)

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
  let middleware = Middleware.make()->Middleware.route(list{Route.Constant("test")}, Method.GET, (
    ~params,
  ) => Belt.Result.Ok({
    status: 200,
    payload: "test",
  }))

  let f = middleware->Middleware.resolve("/test1", Method.GET)

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
  testParams()
}
