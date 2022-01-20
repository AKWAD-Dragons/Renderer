import 'package:flutter/material.dart';

///Internal use only
///
///Used to build a correspondent widget to a specific state
abstract class StateBuilder {
  Widget? render({Widget? primaryWidget, Widget? alternativeWidget}) {
    assert(
        primaryWidget != null || alternativeWidget != null,
        'Either [primaryWidget] or [alternativeWidget] MUST be provided'
        ' to renderer StateBuilder');

    return primaryWidget ?? alternativeWidget;
  }
}

///Internal use only. Builds the correspondent widget of a success state
class SuccessState extends StateBuilder {}

///Internal use only. Builds the correspondent widget of an error state
class ErrorState extends StateBuilder {}

///Internal use only. Builds the correspondent widget of a loading state
class LoadingState extends StateBuilder {}
