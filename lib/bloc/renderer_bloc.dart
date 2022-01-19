import 'package:renderer/bloc/exports.dart';
import 'package:rxdart/rxdart.dart';

abstract class RendererBLoC<V extends RendererEvent, S extends RendererState> {
  final PublishSubject<S> rendererSubject = PublishSubject();

  void dispatch(V event);

  void closeSubject() => rendererSubject.close();
}
