type errorPayload = {err: string, msg: string, details: string}
type endpointError = {status: int, payload: errorPayload}
type endpointResponse = {status: int, payload: string}

type t = Belt.Result.t<endpointResponse, endpointError>
