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
  
type alias Model =
  { transition : Transition.Model
  }

init : (Model, Effects Action)
init =
  (,) { transition = Transition.init 0.5
  } Effects.none

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    TransitionAction action ->
      let
        (newModel, effects) =
          Transition.update action model.transition
      in
        (,) { model |
          transition <- newModel
        } (Effects.map TransitionAction effects)

view : Address Action -> Model -> Html
view address model =
  let
    height = 100 + 300 * model.transition.ratio
    styles = [("height", toString height ++ "px"), ("background", "#8da")]
  in
    div
      [ style styles
      , onClick (forwardTo address TransitionAction) Transition.toggle
      ]
      []

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
