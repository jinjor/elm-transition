import Html exposing (Html)
import Svg exposing (svg, rect, g, text, text')
import Svg.Attributes exposing (..)
import Svg.Events exposing (onClick)
import Signal exposing (..)
import Task exposing (..)
import Transition
import Effects exposing (..)
import Easing exposing (ease, easeOutBounce, float)
import StartApp

type Action
  = TransitionAction Transition.Action

type alias Model =
  { transition : Transition.Model
  , angle : Float
  }

init : (Model, Effects Action)
init =
  (,) { transition = Transition.init
  , angle = 0
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
          transition <- if newModel.ratio >= 1 then Transition.init else newModel
        , angle <- if newModel.ratio >= 1 then model.angle + 90 else model.angle
        } (Effects.map TransitionAction effects)

view : Address Action -> Model -> Html
view address model =
  let
    offset =
      ease easeOutBounce float 0 90 1.0 model.transition.ratio
    angle =
      model.angle + offset
  in
    svg
      [ width "200", height "200", viewBox "0 0 200 200" ]
      [ g [ transform ("translate(100, 100) rotate(" ++ toString angle ++ ")")
          , onClick (Signal.message (forwardTo address TransitionAction) (Transition.start 1.0))
          ]
          [ rect
              [ x "-50"
              , y "-50"
              , width "100"
              , height "100"
              , rx "15"
              , ry "15"
              , style "fill: #60B5CC;"
              ]
              []
          , text' [ fill "white", textAnchor "middle" ] [ text "Click me!" ]
          ]
      ]

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
