import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension NavigationExtensions on BuildContext {
  void pushNamed(
    String name, {
    Object? extra,
    Map<String, String>? pathParameters,
  }) {
    GoRouter.of(
      this,
    ).pushNamed(name, extra: extra, pathParameters: pathParameters ?? {});
  }

  void goNamed(
    String name, {
    Object? extra,
    Map<String, String>? pathParameters,
  }) {
    GoRouter.of(
      this,
    ).goNamed(name, extra: extra, pathParameters: pathParameters ?? {});
  }

  void pushReplacement(String location, {Object? extra}) {
    GoRouter.of(this).pushReplacement(location, extra: extra);
  }

  void go(String location, {Object? extra}) {
    GoRouter.of(this).go(location, extra: extra);
  }

  void pop([Object? result]) {
    GoRouter.of(this).pop(result);
  }

  bool get canPop => Navigator.of(this).canPop();

  void push(String location, {Object? extra}) {
    GoRouter.of(this).push(location, extra: extra);
  }

  void reloadCurrentScreen() {
    final currentLocation =
        GoRouter.of(this).routeInformationProvider.value.uri.toString();
    GoRouter.of(this).go(currentLocation);
  }
}
