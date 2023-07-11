// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Http = require("http");
var Curry = require("rescript/lib/js/curry.js");
var Belt_Result = require("rescript/lib/js/belt_Result.js");
var Method$BApi = require("./Method.bs.js");
var Router$BApi = require("./Router.bs.js");
var Core__Option = require("@rescript/core/src/Core__Option.bs.js");
var Middleware$BApi = require("./Middleware.bs.js");

function writeResponse(result, response) {
  var data;
  if (result.TAG === /* Ok */0) {
    var response$1 = result._0;
    data = {
      status: response$1.status,
      payload: response$1.payload
    };
  } else {
    var response$2 = result._0;
    data = Core__Option.mapWithDefault(JSON.stringify(response$2.payload), {
          status: 500,
          payload: "Malformed response"
        }, (function (a) {
            return {
                    status: response$2.status,
                    payload: a
                  };
          }));
  }
  response.writeHead(data.status, {
          "x-powered-by": "BApi",
          "content-type": "application/json"
        }).end(Buffer.from(data.payload));
}

function serve(middleware, port, host) {
  return Http.createServer(function (request, response) {
                writeResponse(Belt_Result.flatMap(Belt_Result.flatMap(Method$BApi.make(request.method), (function (method) {
                                return Router$BApi.resolve(request.url, method, middleware);
                              })), (function (f) {
                            return Curry._1(f, undefined);
                          })), response);
              }).listen(port, host, (function (param) {
                console.log("starting BApi server");
              }));
}

serve(Middleware$BApi.make(undefined), 8000, "localhost");

exports.writeResponse = writeResponse;
exports.serve = serve;
/*  Not a pure module */
