module Transition (Action, init, Model, update, start, reverse, toggle) where
{-| A simple transition library for Elm.
# Definition
@docs Action, Model
# Architecture
@docs init, update
# Actions
@docs start, reverse, toggle
-}

import String exposing (..)
import Signal exposing (Address)
import Time exposing (..)
import Effects exposing (..)

{-| All actions should be passed to the `update` function following the Elm Architecture.
-}
type Action
  = Start Time
  | Reverse Time
  | Toggle Time
  | Next Time Time Time Bool

{-| The ratio is the value of elapsed time per duration which varies from 0 to 1.
-}
type alias Model =
  { ratio : Float
  }

{-| The initial ratio is 0.0.
-}
init : Model
init =
  { ratio = 0.0
  }

{-| All actions should be passed to this function following the Elm Architecture.
-}
update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Start duration ->
      let
        effects =
          if | model.ratio <= 0 -> Effects.tick (\currentTime -> Next duration currentTime currentTime False)
             | otherwise -> Effects.none
      in
        (model, effects)
    Reverse duration ->
      let
        effects =
          if | model.ratio >= 1 -> Effects.tick (\currentTime -> Next duration currentTime currentTime True)
             | otherwise -> Effects.none
      in
        (model, effects)
    Toggle duration ->
      let
        effects =
          if | model.ratio <= 0 -> Effects.tick (\currentTime -> Next duration currentTime currentTime False)
             | model.ratio >= 1 -> Effects.tick (\currentTime -> Next duration currentTime currentTime True)
             | otherwise -> Effects.none
      in
        (model, effects)
    Next duration startTime currentTime reverse ->
      let
        toNext currentTime = Next duration startTime currentTime reverse
        effects =
          if | (not reverse) && newModel.ratio < 1 -> Effects.tick toNext
             | reverse && model.ratio > 0 -> Effects.tick toNext
             | otherwise -> Effects.none
        newRatio =
          let
            newRatio' = Basics.min 1 <| Basics.max 0 <| (currentTime - startTime) / (duration * 1000)
          in
            if (not reverse) then newRatio' else 1 - newRatio'
        newModel =
          { model |
            ratio <- newRatio
          }
      in
        (newModel, effects)

{-| Start changing the `ratio` from 0 to 1.
The first argument is the duration between start and end.
Interruption is not allowed during the transition.
-}
start : Float -> Action
start = Start

{-| Start changing the `ratio` from 1 to 0.
The first argument is the duration between start and end.
Interruption is not allowed during the transition.
-}
reverse : Float -> Action
reverse = Reverse

{-| Start changing the `ratio` from 0 to 1 when current ratio is 0, from 1 to 0 when current ratio is 1.
The first argument is the duration between start and end.
Interruption is not allowed during the transition.
-}
toggle : Float -> Action
toggle = Toggle
