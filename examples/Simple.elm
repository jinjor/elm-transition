import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import String exposing (..)
import Signal exposing (..)
import Task exposing (..)
import Transition
import Effects exposing (..)
import StartApp

type Action
  = NoOp
  | TransitionAction Transition.Action

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
    [ onClick (forwardTo address TransitionAction) (Transition.toggle 1.0) ]
    [ model.ratio |> toString |> text ]

app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }

port tasks : Signal (Task Never ())
port tasks = app.tasks

main : Signal Html
main = app.html
