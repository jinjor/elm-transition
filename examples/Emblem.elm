import String exposing (..)
import Signal exposing (..)
import Task exposing (..)
import Color exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Graphics.Input exposing (..)
import Window
import Transition

type Action = NoOp | TransitionAction Transition.Action
type alias Model =
  { transition : Transition.Model
  }

init : Model
init =
  { transition = Transition.init 0.8 60
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

view : Address Action -> Model -> (Int, Int) -> Element
view address model (dimX, dimY) =
  collage dimX dimY
    [ square 300
        |> filled (rgba 53 55 55  <|  model.transition.ratio * 3 - 2)
    , square 100
        |> filled (rgb 175 141 69)
        |> move (-100, 100)
    , square 100
        |> filled (rgb 180 179 179)
        |> move (100, -100)
    , circle ((sqrt <| 50^2 + 150^2)-0.5)
        |> filled (rgba 255 255 255 1)
    , circle ((*) (Basics.max 0 <| Basics.min 1 <| model.transition.ratio*3 - 1) <| sqrt (50^2 + 150^2) + 0.5)
        |> filled (rgb 53 55 55)
    , rect (Basics.max 0 (model.transition.ratio*(-3)+1) * 100) 300
        |> filled (rgb 53 55 55)
    , rect (Basics.max 0 (model.transition.ratio*3-2) * 100) 301
        |> filled (rgba 255 255 255 1)
    , circle 50
        |> filled (rgb 214 21 24)
        |> move (100, 100)
    , square 300
        |> filled white
        |> move (0, 300)
    , square 300
        |> filled white
        |> move (0, -300)
    , square 300
        |> filled white
        |> move (300, 0)
    , square 300
        |> filled white
        |> move (-300, 0)
    ]
    |> clickable (Signal.message (forwardTo address TransitionAction) Transition.toggle)

state : Signal (Model, Maybe (Task () ()))
state = foldp (\action (model, _) -> update actions.address action model) (init, Nothing) actions.signal

port runState : Signal (Task () ())
port runState = Signal.map (\(_, maybeTask) -> pickTask maybeTask) state

main : Signal Element
main = (\(model, _) dim -> view actions.address model dim) <~ state ~ Window.dimensions
