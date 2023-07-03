open NodeJs

module Server = {
  let serve = (port, host) => {
    Http.createServer((request, response) => {
      let method = request->Http.IncomingMessage.method__
      let url = request->Http.IncomingMessage.url
      Js.log(`Incoming ${method} request from URL ${url}`)

      response
      ->Http.ServerResponse.writeHead(
        200,
        {"x-powered-by": "BApi", "content-type": "application/json"},
      )
      ->Http.ServerResponse.endWithData(
        {"msg": "Hello, world"}->JSON.stringifyAny->Belt.Option.getUnsafe->Buffer.fromString,
      )
    })->Http.Server.listen(
      ~port,
      ~host,
      ~callback=() => {
        Js.log("starting BApi server")
      },
      (),
    )
  }
}

Server.serve(8000, "127.0.0.1")->ignore
