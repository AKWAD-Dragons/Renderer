import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:renderer/bloc/exports.dart';
import 'package:renderer/state_builder.dart';
import 'renderer_types.dart';

class Renderer<B extends RendererBLoC, S extends RendererState>
    extends StatefulWidget {
  final RendererBLoC fromBloc = GetIt.instance<B>();
  final RendererBuilder<S> stateBuilder;
  final RendererError errorWhen;
  final RendererLoading loadingWhen;
  final Widget loading;
  final Widget? error;
  final RendererErrorBuilder? errorBuilder;
  final RendererInitializer? onInit;

  Renderer(
      {Key? key,
      required this.stateBuilder,
      required this.errorWhen,
      required this.loadingWhen,
      required this.loading,
      this.error,
      this.errorBuilder,
      this.onInit})
      : assert(() {
          if (error == null && errorBuilder == null) {
            throw 'Either [onError] or [errorBuilder] MUST be provided to renderer';
          }

          if (error != null && errorBuilder != null) {
            throw 'Only [onError] or [errorBuilder] MUST be provided to renderer';
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
      if (_suspendRefresh(state)) return;
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
    return Container();
  }

  Widget? _loadingState() {
    final bool loadingState = widget.loadingWhen(_currentState);
    if (!loadingState) return null;
    return LoadingState().render(primaryWidget: widget.loading);
  }

  Widget? _errorState() {
    final bool errorState = widget.errorWhen(_currentState);
    if (!errorState) return null;

    return ErrorState().render(
        primaryWidget: widget.error,
        alternativeWidget: widget.errorBuilder!(_currentState.errorTitle,
            _currentState.errorMessage, _currentState.errorCode));
  }

  Widget? _successState() {
    final bool successState = _currentState is S;
    if (!successState) return null;

    return SuccessState()
        .render(primaryWidget: widget.stateBuilder(_currentState));
  }

  bool _suspendRefresh(dynamic state) {
    return !(state is S ||
        widget.errorWhen(state) ||
        widget.loadingWhen(state));
  }

  @override
  void dispose() {
    _stream?.cancel();
    super.dispose();
  }
}
