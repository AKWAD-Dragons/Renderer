import 'package:flutter/material.dart';
import 'package:renderer/bloc/exports.dart';

typedef RendererBuilder<S extends RendererState> = Widget Function(S state);
typedef RendererLoading<S extends RendererState> = bool Function(S state);
typedef RendererError<E extends RendererState> = bool Function(E state);
typedef RendererErrorBuilder = Widget Function(
    String title, String message, int code);
typedef RendererInitializer = void Function(Duration rendererTimestamp);
