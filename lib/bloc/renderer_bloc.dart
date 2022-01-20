import 'package:renderer/bloc/exports.dart';
import 'package:renderer/renderer.dart';
import 'package:rxdart/rxdart.dart';

abstract class RendererBLoC<V extends RendererEvent, S extends RendererState> {
  final PublishSubject<S> _rendererSubject = PublishSubject();

  void dispatch(V event);

  void notifyRenderers(S state) => _rendererSubject.add(state);

  PublishSubject? getSubject(Object consumer) {
    if (consumer is! Renderer) {
      throw 'Illegal action:: Consuming getSubject() inside ${consumer.runtimeType} is forbidden.'
          ' If you\'re trying to add a state use notifyRenderers() instead';
    }
    return _rendererSubject;
  }

  void closeSubject() => _rendererSubject.close();

  void dispose();
}
