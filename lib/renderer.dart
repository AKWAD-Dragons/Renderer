import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:renderer/bloc/exports.dart';
import 'package:renderer/state_builder.dart';
import 'renderer_types.dart';

class Renderer<B extends RendererBLoC, S extends RendererState>
    extends StatefulWidget {
  final RendererBLoC fromBloc = GetIt.instance<B>();
  final RendererInitializer? onInit;
  final Widget? initial;
  final RendererBuilder<S> stateBuilder;
  final RendererErrorCallback errorWhen;
  final Widget? error;
  final RendererErrorBuilder? errorBuilder;
  final RendererErrorNotifier? onError;
  final RendererLoadingCallback? loadingWhen;
  final Widget? loading;

  Renderer({
    Key? key,
    this.onInit,
    this.initial,
    required this.stateBuilder,
    required this.errorWhen,
    required this.loadingWhen,
    required this.loading,
    this.error,
    this.errorBuilder,
    this.onError,
  })  : assert(() {
          if (error == null && errorBuilder == null && onError == null) {
            throw 'Either [onError], [error] or [errorBuilder] callbacks'
                ' MUST be provided to renderer';
          }

          if (error != null && errorBuilder != null && onError != null) {
            throw 'Only one callback of [onError], [error] or [errorBuilder]'
                ' MUST be provided to renderer';
          }

          if (loadingWhen == null && loading != null) {
            throw '[loadingWhen] cannot equal null as Renderer does NOT know '
                'when to render the provided [loading] widget. ';
          }

          if (loadingWhen != null && loading == null) {
            throw '[loading] cannot equal null as Renderer does NOT know what '
                'widget to render when it receives a loading state';
          }
          return true;
        }()),
        super(key: key);

  @override
  _RendererState createState() => _RendererState<B, S>();
}

class _RendererState<B extends RendererBLoC, S extends RendererState>
    extends State<Renderer<B, S>> {
  StreamSubscription? _stream;
  dynamic _currentState;

  @override
  void initState() {
    _doAfterLastFrame();
    _subscribeToRenderer();
    super.initState();
  }

  void _doAfterLastFrame() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final RendererInitializer? initializer = widget.onInit;
      if (initializer == null) return;

      initializer(timeStamp, context);
    });
  }

  void _subscribeToRenderer() {
    _stream = widget.fromBloc.getSubject(widget)?.listen((state) {
      if (_protectState(state)) return;
      setState(() {
        _currentState = state;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentState == null) return _initState();
    return _successState() ?? _errorState() ?? _loadingState() ?? _initState();
  }

  Widget _initState() {
    return widget.initial ?? Container();
  }

  Widget? _loadingState() {
    if (widget.loadingWhen == null) return null;
    final bool loadingState = widget.loadingWhen!(_currentState);

    if (!loadingState) return null;
    return LoadingState().render(primaryWidget: widget.loading);
  }

  Widget? _errorState() {
    final bool errorState = widget.errorWhen(_currentState);
    if (!errorState) return null;

    return ErrorState().render(
        primaryWidget: widget.error,
        alternativeWidget: widget.errorBuilder!(_currentState.rendererError));
  }

  Widget? _successState() {
    final bool successState = _currentState is S;
    if (!successState) return null;

    return SuccessState()
        .render(primaryWidget: widget.stateBuilder(_currentState));
  }

  bool _avoidState(dynamic state) {
    final RendererLoadingCallback? loadingCallback = widget.loadingWhen;
    bool loadingState = false;

    if (loadingCallback != null) {
      loadingState = loadingCallback(state);
    }

    return !(state is S || widget.errorWhen(state) || loadingState);
  }

  bool _nonRenderableErrorState(dynamic state) {
    final bool errorState = widget.errorWhen(state);
    if (!errorState) return false;

    if (widget.error == null && widget.errorBuilder == null) return true;
    return false;
  }

  bool _protectState(dynamic state) {
    if (_avoidState(state)) {
      return true;
    }

    if (_nonRenderableErrorState(state)) {
      widget.onError!(state.rendererError, context);
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    _stream?.cancel();
    super.dispose();
  }
}
