type routePart = Variable(string) | Constant(string)
type t = list<routePart>

let resolve = (route, allRoutes: list<t>) => {
  let split = route->Js.String2.split("/")->Belt.List.fromArray->Belt.List.keep(a => a !== "")

  let isMatch = t => {
    let isSameLength = split->Belt.List.length == t->Belt.List.length

    let couldBeMatch = (a, b) => {
      switch a {
      // If it is a variable, we have no idea
      | Variable(x) => true
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
