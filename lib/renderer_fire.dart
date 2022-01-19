import 'package:get_it/get_it.dart';
import 'package:renderer/bloc/exports.dart';

mixin RendererFire {
  fireEvent<B extends RendererBLoC, V extends RendererEvent>(V rendererEvent) {
    GetIt.instance<B>().dispatch(rendererEvent);
  }
}
