import 'package:flutter/material.dart';
import 'package:renderer/bloc/exports.dart';
import 'package:renderer/models/renderer_error.dart';

typedef RendererBuilder<S extends RendererState> = Widget Function(S state);
typedef RendererLoadingCallback<S extends RendererState> = bool Function(
    S state);
typedef RendererErrorCallback<E extends RendererState> = bool Function(E state);
typedef RendererErrorBuilder = Widget Function(RendererError);
typedef RendererErrorNotifier<E extends RendererState> = void Function(
    RendererError, BuildContext);
typedef RendererInitializer = void Function(
    Duration rendererTimestamp, BuildContext context);
