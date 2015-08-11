# elm-transition

A transition library for Elm

## Usage

Following the Elm Architecture (+Task)

### initialize

```elm
model = Transition.init 0.5 60 -- time(sec) and fps
```

### update

```elm
(newModel, maybeTask) =
  Transition.update address action model
```

### view

```elm
model.ratio -- from start(0.0) to end(1.0)
```

### event

```elm
onClick address Transition.toggle -- start, reverse, toggle
```
