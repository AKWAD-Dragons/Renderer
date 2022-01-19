### Introduction
##### What is Renderer?
A Falcon micro-framework package to manage UI states reactively based on custom BLoC and reactive extenstions.

##### Why Fluent?
Fluent came to be able to inject the refeshing UI states reactively in flutter widget tree with minimum effort.

### Installation

```yaml
dependencies:
  renderer: [latest-version]
```

### Setup and Usage

---
##### Preparing BLoC
1. Create your BLoC event abstract class and let it inherit from `RendererEvent`
```dart
abstract class AuthEvent extends RendererEvent {}
```
2. Create your BLoC state abstract class and let it inherit from `RendererState`
```dart
abstract class AuthState extends RendererState {}
```
3. Create a BLoC class to include your logic and let it inherit from `RendererBLoC` abstract class. `RendererBLoC<V, S>` is a generic class so it expects to start with both ***Event*** and ***State*** types respectively. Finally, implement both `dispatch()` and `dispose()` functions, noting that `dispose()` only needs to call the already inherited `closeSubject()` function.
```dart
class AuthBloc extends RendererBLoC<AuthEvent, AuthState> {
  @override
  void dispatch(AuthEvent event) async {}

  @override
  void dispose() {
    closeSubject();
  }
}
```
##### Preparing Widgets
Renderer carries the burden of using always a Stateful Widget to repaint your UI states away of your shoulders. It helps get rid of the extensive boilerplate code used to be added inside `initState()` as will as cancelling any state stream subscriptions inside `dispose()`.

1. Inside your Stateless Widget let your class implements `RendererFire` mixin.
```dart
class HomeScreen extends StatelessWidget with RendererFire {}
```

2. In your `build()` widget tree, wrap the widget that expects data from a state inside a `Renderer` widget. A `Renderer<B, S>` is a generic widget that expects both a ***BLoC*** and success ***State*** types respectively. The Renderer will NOT allow its child widget to refresh until it receives one of the 3 pre-defined (Success, Error or Loading) states.

```dart
    Renderer<AuthBloc, LoginSuccess>(
          errorWhen: (errorState) => errorState is LoginError,
          loadingWhen: (state) => state is LoginLoading,
          stateBuilder: (state) => Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.green, fontSize: 40),
            ),
          ),
          onLoading: const CircularProgressIndicator(),
          errorBuilder: (String message, int code) => Center(
            child: Text('$message, CODE: $code',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 60)),
          ),
        )
```

3. For each renderer widget, you're required to guide the renderer when to replace the success state UI with an error or loading UI using `errorWhen`, `loadingWhen` callbacks.

4. For a loading state, you're required to provide the `onLoading` widget to render when the renderer receives the loading state using the defined earlier `loadingWhen`.

5. For an error state, you're required to provide either the `onError` widget to statically render an error widget or `errorBuilder` to get the exact error message and error code when the renderer receives the error state using the defined earlier `errorWhen`.

6. Finally, Firing the event is no longer needs an instance of a BLoC as usual. You just need to call `fireEvent()` function that is already inherited from `RendererFire` mixin. `fireEvent<B, V>` is a generic function that expects both ***BLoC*** and ***Event*** types respectively.

```dart
fireEvent<AuthBloc, LoginEvent>(LoginEvent(status: 'User Logged In'));
```

