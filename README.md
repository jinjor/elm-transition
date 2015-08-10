# elm-transition

A transition library for Elm

## Usage

Following the Elm Architecture (+Task)

### initialize

```elm
Transition.init 0.5 60
```

### update

```elm
(newModel, maybeTask) =
  Transition.update address action model
```

### view

```elm
model.transition.ratio
```

### event

```elm
onClick address Transition.toggle
```
