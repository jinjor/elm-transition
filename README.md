# elm-transition

A transition library for Elm

## Usage

Just follow the Elm Architecture

### initialize

```elm
model = Transition.init 0.5 -- duration(sec)
```

### update

```elm
(newModel, effects) =
  Transition.update action model
```

### view

```elm
model.ratio -- from start(0.0) to end(1.0)
```

### event

```elm
onClick address Transition.toggle -- start, reverse, toggle
```
