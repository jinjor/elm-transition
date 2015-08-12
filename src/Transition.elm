module Transition (Action, init, Model, update, start, reverse, toggle) where

import String exposing (..)
import Signal exposing (Address)
import Time exposing (..)
import Effects exposing (..)

type Action = Start | Reverse | Toggle | Next Time Time Bool

type alias Model =
  { duration : Time
  , ratio : Float
  }

init : Time -> Model
init duration =
  { duration = duration
  , ratio = 0.0
  }

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Start ->
      let
        effects =
          if | model.ratio <= 0 -> Effects.tick (\currentTime -> Next currentTime currentTime True)
             | otherwise -> Effects.none
      in
        (model, effects)
    Reverse ->
      let
        effects =
          if | model.ratio >= 1 -> Effects.tick (\currentTime -> Next currentTime currentTime False)
             | otherwise -> Effects.none
      in
        (model, effects)
    Toggle ->
      let
        effects =
          if | model.ratio <= 0 -> Effects.tick (\currentTime -> Next currentTime currentTime True)
             | model.ratio >= 1 -> Effects.tick (\currentTime -> Next currentTime currentTime False)
             | otherwise -> Effects.none
      in
        (model, effects)
    Next startTime currentTime opening ->
      let
        toNext currentTime = Next startTime currentTime opening
        effects =
          if | opening && model.ratio < 1 -> Effects.tick toNext
             | (not opening) && model.ratio > 0 -> Effects.tick toNext
             | otherwise -> Effects.none
        newRatio =
          let
            newRatio' = Basics.min 1 <| Basics.max 0 <| (currentTime - startTime) / (model.duration * 1000)
          in
            if opening then newRatio' else 1 - newRatio'
        newModel =
          { model |
            ratio <- newRatio
          }
      in
        (newModel, effects)

start : Action
start = Start

reverse : Action
reverse = Reverse

toggle : Action
toggle = Toggle
