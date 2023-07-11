let resolve = (route, method, middleware: Middleware.t) => {
  let notFoundError: EndpointResult.endpointError = {
    status: 404,
    payload: {
      err: "endpoint-not-found",
      msg: "The endpoint requested was not found",
      details: "{}",
    },
  }

  let invalidMethodError = (allowed): EndpointResult.endpointError => {
    status: 405,
    payload: {
      err: "method-not-allowed",
      msg: `Method is not allowed`,
      details: {"accepted_methods": allowed->Method.toString}->JSON.stringifyAny->Option.getUnsafe,
    },
  }

  let getHandler = route => {
    let config = middleware->Belt.Map.String.getExn(route->Route.toString)
    switch method == config.method {
    | false => config.method->invalidMethodError->Belt.Result.Error
    | true => config.handler->Belt.Result.Ok
    }
  }

  route
  ->Route.resolve(
    middleware->Belt.Map.String.keysToArray->Belt.List.fromArray->Belt.List.map(Route.fromString),
  )
  ->Option.mapWithDefault(Belt.Result.Error(notFoundError), getHandler)
}
