type routePart = Variable(string) | Constant(string)
type t = list<routePart>

let resolve = (route, allRoutes: list<t>) => {
  let split = route->Js.String2.split("/")->Belt.List.fromArray->Belt.List.keep(a => a !== "")

  let isMatch = t => {
    let isSameLength = split->Belt.List.length == t->Belt.List.length

    let couldBeMatch = (a, b) => {
      switch a {
      // If it is a variable, we have no idea
      | Variable(_) => true
      // We can check if the constant name is the same
      | Constant(name) => name == b
      }
    }

    switch isSameLength {
    | false => false
    | true =>
      Belt.List.zipBy(t, split, couldBeMatch)->Belt.List.reduce(true, (acc, curr) => acc && curr)
    }
  }

  allRoutes->Belt.List.keep(isMatch)->Belt.List.get(0)
}

let mapVariables = (route, strRoute) => {
  let split = strRoute->Js.String2.split("/")->Belt.List.fromArray->Belt.List.keep(a => a !== "")
  Belt.List.zip(route, split)->Belt.List.reduce(Belt.Map.String.empty, (
    acc,
    (routePart, strRoutePart),
  ) => {
    switch routePart {
    | Variable(x) => acc->Belt.Map.String.set(x, strRoutePart)
    | Constant(_) => acc
    }
  })
}

let toString = t => {
  t->Belt.List.reduce("", (acc, curr) =>
    acc ++
    "/" ++
    switch curr {
    | Variable(s) => `:${s}`
    | Constant(s) => s
    }
  )
}

let fromString = s => {
  s
  ->Js.String2.split("/")
  ->Belt.List.fromArray
  ->Belt.List.keep(a => a !== "")
  ->Belt.List.map(elem => {
    let startsWithColon = elem->Js.String2.startsWith(":")
    switch startsWithColon {
    | true => Variable(elem->Js.String2.substringToEnd(~from=1))
    | false => Constant(elem)
    }
  })
}
