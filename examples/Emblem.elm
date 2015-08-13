import String exposing (..)
import Signal exposing (..)
import Task exposing (..)
import Color exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Graphics.Input exposing (..)
import Window
import Transition
import Effects exposing (..)
import StartApp
import Html exposing (Html)

type Action
  = NoOp
  | TransitionAction Transition.Action
  | Dimensions (Int, Int)

type alias Model =
  { transition : Transition.Model
  , dimensions : (Int, Int)
  }

init : (Model, Effects Action)
init =
  (,) { transition = Transition.init
  , dimensions = (0, 0)
  } Effects.none

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Dimensions dimensions ->
      (,) { model |
        dimensions <- dimensions
      } Effects.none
    TransitionAction action ->
      let
        (newModel, effects) =
          Transition.update action model.transition
      in
        (,) { model |
          transition <- newModel
        } (Effects.map TransitionAction effects)

view : Address Action -> Model -> Html
view address { transition, dimensions } =
  collage (fst dimensions) (snd dimensions)
    [ square 300
        |> filled (rgba 53 55 55  <|  transition.ratio * 3 - 2)
    , square 100
        |> filled (rgb 175 141 69)
        |> move (-100, 100)
    , square 100
        |> filled (rgb 180 179 179)
        |> move (100, -100)
    , circle ((sqrt <| 50^2 + 150^2)-0.5)
        |> filled (rgba 255 255 255 1)
    , circle ((*) (Basics.max 0 <| Basics.min 1 <| transition.ratio*3 - 1) <| sqrt (50^2 + 150^2) + 0.5)
        |> filled (rgb 53 55 55)
    , rect (Basics.max 0 (transition.ratio*(-3)+1) * 100) 300
        |> filled (rgb 53 55 55)
    , rect (Basics.max 0 (transition.ratio*3-2) * 100) 301
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
    |> clickable (Signal.message (forwardTo address TransitionAction) (Transition.toggle 0.8))
    |> Html.fromElement

app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs =
      [ Signal.map Dimensions Window.dimensions ]
    }

port tasks : Signal (Task Effects.Never ())
port tasks = app.tasks

main : Signal Html
main = app.html
