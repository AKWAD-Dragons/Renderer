import 'package:get_it/get_it.dart';
import 'package:renderer/bloc/exports.dart';

///Implement this class to any [StatelessWidget] or a [State]
///of a StatefulWidget
mixin RendererFire {
  ///Called to trigger an event of type [V] which belongs to a BLoC to type [B]
  fireEvent<B extends RendererBLoC, V extends RendererEvent>(V rendererEvent) {
    GetIt.instance<B>().dispatch(rendererEvent);
  }
}
