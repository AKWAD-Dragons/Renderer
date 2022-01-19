import 'package:flutter/material.dart';

abstract class StateBuilder {
  Widget? render({Widget? primaryWidget, Widget? alternativeWidget}) {
    assert(
        primaryWidget != null || alternativeWidget != null,
        'Either [primaryWidget] or [alternativeWidget] MUST be provided'
        ' to renderer StateBuilder');

    return primaryWidget ?? alternativeWidget;
  }
}

class SuccessState extends StateBuilder {}

class ErrorState extends StateBuilder {}

class LoadingState extends StateBuilder {}
