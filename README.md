# elm-transition

## Usage

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
