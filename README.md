### Introduction
##### What is Renderer?
A Falcon micro-framework package to manage UI states reactively based on custom BLoC and reactive extenstions.

##### Why Renderer?
Renderer came to be able to inject the refeshing UI states reactively in flutter widget tree with minimum effort.

### Installation

```yaml
dependencies:
  renderer: [latest-version]
```

### Setup and Usage

---
#### Preparing BLoC
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

4- Finally, to notify Renderers about a new state, all you need to do is calling the already inherited function `notifyRenderers()` and pass your great state object to it as an argument.

```dart
class AuthBloc extends RendererBLoC<AuthEvent, AuthState> {
  @override
  void dispatch(AuthEvent event) async {
    if (event is LoginEvent) {
      notifyRenderers(LoginSuccess('User Logged In'));
    }
  }

  @override
  void dispose() {
    closeSubject();
  }
}
```
#### Preparing Widgets
Renderer carries the burden of using always a Stateful Widget to repaint your UI states away of your shoulders. It helps get rid of the extensive boilerplate code used to be added inside `initState()` as will as cancelling any state stream subscriptions inside `dispose()`.

1. Inside your Stateless Widget let your class implements `RendererFire` mixin.
```dart
class HomeScreen extends StatelessWidget with RendererFire {}
```

2. In your `build()` widget tree, wrap the widget that expects data from a state inside a `Renderer` widget. A `Renderer<B, S>` is a generic widget that expects both a ***BLoC*** and success ***State*** types respectively. The Renderer will NOT allow its child widget to refresh until it receives one of the 3 pre-defined (Success, Error or Loading) states.

```dart
class HomeScreen extends StatelessWidget with RendererFire {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        fireEvent<AuthBloc, AuthEvent>(LoginEvent(status: 'User Logged In'));
      }),
      body: Center(
        child: Renderer<AuthBloc, LoginSuccess>(
          onInit: (timeStamp, context) => showDialog(context: context, builder: (...))
          errorWhen: (errorState) => errorState is LoginError,
          loadingWhen: (loadingState) => loadingState is LoginLoading,
          stateBuilder: (state) => Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.green, fontSize: 40),
            ),
          ),
          loading: const CircularProgressIndicator(),
          errorBuilder: (RendererError error) => Center(
            child: Column(
              children: [
                Text(
                  error.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 60),
                ),
                Text(
                  '${error.message}, CODE: ${error.code}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 60),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}
```
3. A Renderer now has `onInit` field to help you override the usage of `initState` when you need to call/execute a function immediately on a widget starts. `onInit` guarantees to execute your code right after the last frame of a "renderer widget" has been drawn and setteled on screen. `onInit` provides a timestamp that indicates when exactly the Renderer has been mounted and a `BuildContext` instance to be used to show Dialogs, Snackbars,...etc.

4. For each renderer widget, you're required to guide the renderer when to replace the success state UI with an error or loading UI using `errorWhen`, `loadingWhen` callbacks.

5. For a loading state, you're required to provide the `onLoading` widget to render when the renderer receives the loading state using the defined earlier `loadingWhen`.

6. For an error state, you're required to provide one of the following:
- `error`: A widget to statically render an error widget.
-  `errorBuilder`: A callback to get a `RendererError` object (containts error data: title, message and code) when the renderer receives its error state. You may use the error data to show your custom error widget.
-  `onError`: A  callback to get both `RendererError` object and the current `buildContext` object. This callback is useful in case you need to show Dialog, Snackbar, ...etc that require a `buildContext` to build.<br><br>
**PLEASE NOTE:** If you intend to use `errorBuilder` or `onError` callbacks then you MUST provide an error state object that contains ***AT LEAST*** a `RendererError` field to `errorWhen`.<br>

```dart
class LoginError extends AuthState {
  final RendererError rendererError; //Must be exatcly named
  final Oject1 someObject;
  final Object2 someOtherObject;
}
```

7. Finally, Firing the event is no longer needs an instance of a BLoC as usual. You just need to call `fireEvent()` function that is already inherited from `RendererFire` mixin. `fireEvent<B, V>` is a generic function that expects both ***BLoC*** and ***Event*** types respectively.

```dart
fireEvent<AuthBloc, AuthEvent>(LoginEvent(status: 'User Logged In'));
```
