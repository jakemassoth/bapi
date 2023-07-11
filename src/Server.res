open NodeJs

type responseToWrite = {
  status: int,
  payload: string,
}

let writeResponse = (result: EndpointResult.t, response) => {
  let data = switch result {
  | Belt.Result.Ok(response) => {status: response.status, payload: response.payload}
  | Belt.Result.Error(response) =>
    response.payload
    ->JSON.stringifyAny
    ->Option.mapWithDefault({status: 500, payload: "Malformed response"}, a => {
      status: response.status,
      payload: a,
    })
  }
  response
  ->Http.ServerResponse.writeHead(
    data.status,
    {"x-powered-by": "BApi", "content-type": "application/json"},
  )
  ->Http.ServerResponse.endWithData(data.payload->Buffer.fromString)
}

let serve = (middleware, port, host) => {
  Http.createServer((request, response) => {
    request
    ->Http.IncomingMessage.method__
    ->Method.make
    ->Belt.Result.flatMap(method => {
      request->Http.IncomingMessage.url->Router.resolve(method, middleware)
    })
    ->Belt.Result.flatMap(f => f())
    ->writeResponse(response)
  })->Http.Server.listen(
    ~port,
    ~host,
    ~callback=() => {
      Js.log("starting BApi server")
    },
    (),
  )
}

Middleware.make()->serve(8000, "localhost")->ignore
