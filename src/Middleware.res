type routeConfig = {
  route: Route.t,
  method: Method.t,
  handler: (~params: Belt.Map.String.t<string>) => EndpointResult.t,
}
type t = Belt.Map.String.t<routeConfig>

let make = () => Belt.Map.String.empty

let route = (t, route, method, handler) =>
  t->Belt.Map.String.set(route->Route.toString, {route, method, handler})

let resolve = (t, strRoute, method) => {
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

  let getHandler = (strRoute, route) => {
    let config = t->Belt.Map.String.getExn(route->Route.toString)
    switch method == config.method {
    | false => config.method->invalidMethodError->Belt.Result.Error
    | true => Belt.Result.Ok(() => config.handler(~params=Route.mapVariables(route, strRoute)))
    }
  }

  strRoute
  ->Route.resolve(
    t->Belt.Map.String.keysToArray->Belt.List.fromArray->Belt.List.map(Route.fromString),
  )
  ->Option.mapWithDefault(Belt.Result.Error(notFoundError), route => getHandler(strRoute, route))
}
