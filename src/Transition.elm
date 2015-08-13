module Transition (Action, init, Model, update, start, reverse, toggle) where

import String exposing (..)
import Signal exposing (Address)
import Time exposing (..)
import Effects exposing (..)

type Action
  = Start Time
  | Reverse Time
  | Toggle Time
  | Next Time Time Time Bool

type alias Model =
  { ratio : Float
  }

init : Model
init =
  { ratio = 0.0
  }

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

start : Float -> Action
start = Start

reverse : Float -> Action
reverse = Reverse

toggle : Float -> Action
toggle = Toggle
