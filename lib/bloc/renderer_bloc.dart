import 'package:renderer/bloc/exports.dart';
import 'package:renderer/renderer.dart';
import 'package:renderer/renderer_fire.dart';
import 'package:rxdart/rxdart.dart';

///The Parent class of all BLoCs in a project. It has all the required functions
///to make any BLoC function reactively
///It must be provided with both [RendererEvent] and [RendererState] types

abstract class RendererBLoC<V extends RendererEvent, S extends RendererState> {
  ///A generic subject responsible for the reactive communication between
  ///a BLoC an Renderer widget
  final PublishSubject<S> _rendererSubject = PublishSubject();

  ///Called internally from [RendererFire] only to trigger a certain
  ///event of type [V]
  void dispatch(V event);

  ///Called from any BLoC instance to notify all Renderers about
  ///a new UI State of type [S]
  void notifyRenderers(S state) => _rendererSubject.add(state);

  ///Called internally from [Renderer] widget only to subscribe
  ///to [_rendererSubject] and start receiving new relative UI States
  ///
  ///Declare the [consumer] class as an argument to protect the function
  ///against general use.
  ///
  ///This getter will throw an exception if the provided [consumer] is not of
  ///[Renderer] type.
  PublishSubject? getSubject(Object consumer) {
    if (consumer is! Renderer) {
      throw 'Illegal action:: Consuming getSubject() inside ${consumer.runtimeType} is forbidden.'
          ' If you\'re trying to add a state use notifyRenderers() instead';
    }
    return _rendererSubject;
  }

  ///called inside [dispose] implementation in any BLoC class to provide a way
  ///to close the publish subject safely and avoid memory leaks.
  ///
  ///Avoid to call this function anywhere else as it will close the
  ///communication between all your project BLoCs and all Renderers till the
  ///app restarts.
  void closeSubject() => _rendererSubject.close();

  ///To be implemented inside BLoC class to close/stop/dispose any subscribed
  ///resources.
  void dispose();
}
