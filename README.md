# elm-transition

A simple transition library for Elm

## Usage

Just follow the Elm Architecture.

```elm
type Action = TransitionAction Transition.Action

type alias Model = Transition.Model

init : (Model, Effects Action)
init = (Transition.init, Effects.none)

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    TransitionAction action ->
      let
        (newModel, effects) =
          Transition.update action model
      in
        (newModel, Effects.map TransitionAction effects)

view : Address Action -> Model -> Html
view address model =
  button
    [ onClick
        (forwardTo address TransitionAction)
        (Transition.toggle 1.0) -- type(start, reverse, toggle) and duration(sec)
    ]
    [ model.ratio -- from start(0.0) to end(1.0)
        |> toString
        |> text
    ]
```
