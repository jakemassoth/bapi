type routeConfig = {
  route: Route.t,
  method: Method.t,
  handler: unit => EndpointResult.t,
}
type t = Belt.Map.String.t<routeConfig>

let make = () => Belt.Map.String.empty

let route = (t, route, method, handler) =>
  t->Belt.Map.String.set(route->Route.toString, {route, method, handler})
