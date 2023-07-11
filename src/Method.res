type t = GET | PUT | POST | PATCH | DELETE

let make = s => {
  let uppercase = s->Js.String.toUpperCase
  let malformedMethodError: EndpointResult.endpointError = {
    status: 405,
    payload: {
      err: "unknown-method",
      msg: `Unknown method: ${uppercase}`,
      details: "{}",
    },
  }
  switch uppercase {
  | "GET" => Belt.Result.Ok(GET)
  | "PUT" => Belt.Result.Ok(PUT)
  | "POST" => Belt.Result.Ok(POST)
  | "PATCH" => Belt.Result.Ok(PATCH)
  | "DELETE" => Belt.Result.Ok(DELETE)
  | _ => Belt.Result.Error(malformedMethodError)
  }
}

let toString = t => {
  switch t {
  | GET => "GET"
  | POST => "POST"
  | PUT => "PUT"
  | PATCH => "PATCH"
  | DELETE => "DELETE"
  }
}
