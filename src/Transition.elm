module Transition (Action, init, Model, update, start, reverse, toggle) where

import String exposing (..)
import Signal exposing (Address)
import Task exposing (..)
import TaskTutorial exposing (..)
import Time exposing (..)

type Action = Start | Reverse | Toggle | Next Time Time Bool

type alias Model =
  { duration : Time
  , fps : Int
  , ratio : Float
  }

init : Time -> Int -> Model
init duration fps =
  { duration = duration
  , fps = fps
  , ratio = 0.0
  }

update : Address Action -> Action -> Model -> (Model, Maybe (Task () ()))
update address action model =
  let
    interval = 1000 / (Basics.toFloat model.fps)
    sendNext startTime opening =
      let
        sendNext' startTime currentTime opening =
          afterSleep interval <| Signal.send address (Next startTime currentTime opening)
      in
        Just (getCurrentTime `andThen` (\time -> sendNext' (if startTime > 0 then startTime else time) time opening))
  in
    case action of
      Start ->
        let
          maybeTask =
            if | model.ratio <= 0 -> sendNext 0 True
               | otherwise -> Nothing
        in
          (model, maybeTask)
      Reverse ->
        let
          maybeTask =
            if | model.ratio >= 1 -> sendNext 0 False
               | otherwise -> Nothing
        in
          (model, maybeTask)
      Toggle ->
        let
          maybeTask =
            if | model.ratio <= 0 -> sendNext 0 True
               | model.ratio >= 1 -> sendNext 0 False
               | otherwise -> Nothing
        in
          (model, maybeTask)
      Next startTime currentTime opening ->
        let
          maybeTask =
            if | opening && model.ratio < 1 -> sendNext startTime True
               | (not opening) && model.ratio > 0 -> sendNext startTime False
               | otherwise -> Nothing

          newRatio' = Basics.min 1 <| Basics.max 0 <| (currentTime - startTime) / (model.duration * 1000)
          newRatio = if opening then newRatio' else 1 - newRatio'
          newModel =
            { model |
              ratio <- newRatio
            }
        in
          (newModel, maybeTask)


afterSleep : Float -> Task x y -> Task x y
afterSleep time task = Task.sleep time `andThen` always task

start : Action
start = Start

reverse : Action
reverse = Reverse

toggle : Action
toggle = Toggle
