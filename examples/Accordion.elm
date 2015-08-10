import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import String exposing (..)
import Signal exposing (..)
import Task exposing (..)
import Transition

type Action = NoOp | TransitionAction Transition.Action
type alias Model =
  { transition : Transition.Model
  }

init : Model
init =
  { transition = Transition.init 0.5 60
  }

actions : Mailbox Action
actions = Signal.mailbox NoOp

update : Address Action -> Action -> Model -> (Model, Maybe (Task () ()))
update address action model =
  case action of
    TransitionAction action ->
      let
        (newModel, maybeTask) =
          Transition.update (forwardTo address TransitionAction) action model.transition
      in
        (,) { model |
          transition <- newModel
        } maybeTask

pickTask : Maybe (Task () ()) -> Task () ()
pickTask maybeTask =
  case maybeTask of
    Just task -> task
    Nothing -> Task.succeed ()

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

state : Signal (Model, Maybe (Task () ()))
state = foldp (\action (model, _) -> update actions.address action model) (init, Nothing) actions.signal

port runState : Signal (Task () ())
port runState = Signal.map (\(_, maybeTask) -> pickTask maybeTask) state

main : Signal Html
main = Signal.map (\(model, _) -> view actions.address model) state
