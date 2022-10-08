import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import '../in_app_webview/webview.dart';
import '../in_app_browser/in_app_browser.dart';
import '../util.dart';
import '../types/main.dart';
import '../in_app_webview/in_app_webview_settings.dart';
import 'pull_to_refresh_settings.dart';
import '../debug_logging_settings.dart';

///A standard controller that can initiate the refreshing of a scroll view’s contents.
///This should be used whenever the user can refresh the contents of a WebView via a vertical swipe gesture.
///
///All the methods should be called only when the WebView has been created or is already running
///(for example [WebView.onWebViewCreated] or [InAppBrowser.onBrowserCreated]).
///
///**NOTE for Android**: to be able to use the "pull-to-refresh" feature, [InAppWebViewSettings.useHybridComposition] must be `true`.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
class PullToRefreshController {
  @Deprecated("Use settings instead")
  // ignore: deprecated_member_use_from_same_package
  late PullToRefreshOptions options;
  late PullToRefreshSettings settings;
  MethodChannel? _channel;

  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  ///Event called when a swipe gesture triggers a refresh.
  final void Function()? onRefresh;

  PullToRefreshController(
      {
      // ignore: deprecated_member_use_from_same_package
      @Deprecated("Use settings instead") PullToRefreshOptions? options,
      PullToRefreshSettings? settings,
      this.onRefresh}) {
    // ignore: deprecated_member_use_from_same_package
    this.options = options ?? PullToRefreshOptions();
    this.settings = settings ?? PullToRefreshSettings();
  }

  void initMethodChannel(dynamic id) {
    this._channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_pull_to_refresh_$id');
    this._channel?.setMethodCallHandler((call) async {
      try {
        return await _handleMethod(call);
      } on Error catch (e) {
        print(e);
        print(e.stackTrace);
      }
    });
  }

  _debugLog(String method, dynamic args) {
    if (PullToRefreshController.debugLoggingSettings.enabled) {
      for (var regExp
      in PullToRefreshController.debugLoggingSettings.excludeFilter) {
        if (regExp.hasMatch(method)) return;
      }
      var maxLogMessageLength =
          PullToRefreshController.debugLoggingSettings.maxLogMessageLength;
      String message = "PullToRefreshController " +
          " calling \"" +
          method.toString() +
          "\" using " +
          args.toString();
      if (maxLogMessageLength >= 0 && message.length > maxLogMessageLength) {
        message = message.substring(0, maxLogMessageLength) + "...";
      }
      if (!PullToRefreshController.debugLoggingSettings.usePrint) {
        developer.log(message, name: this.runtimeType.toString());
      } else {
        print("[${this.runtimeType.toString()}] $message");
      }
    }
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    _debugLog(call.method, call.arguments);

    switch (call.method) {
      case "onRefresh":
        if (onRefresh != null) onRefresh!();
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  ///Sets whether the pull-to-refresh feature is enabled or not.
  Future<void> setEnabled(bool enabled) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('enabled', () => enabled);
    await _channel?.invokeMethod('setEnabled', args);
  }

  Future<void> _setRefreshing(bool refreshing) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('refreshing', () => refreshing);
    await _channel?.invokeMethod('setRefreshing', args);
  }

  ///Tells the controller that a refresh operation was started programmatically.
  ///
  ///Call this method when an external event source triggers a programmatic refresh of your scrolling view.
  ///This method updates the state of the refresh control to reflect the in-progress refresh operation.
  ///When the refresh operation ends, be sure to call the [endRefreshing] method to return the controller to its default state.
  Future<void> beginRefreshing() async {
    return await _setRefreshing(true);
  }

  ///Tells the controller that a refresh operation has ended.
  ///
  ///Call this method at the end of any refresh operation (whether it was initiated programmatically or by the user)
  ///to return the refresh control to its default state.
  ///If the refresh control is at least partially visible, calling this method also hides it.
  ///If animations are also enabled, the control is hidden using an animation.
  Future<void> endRefreshing() async {
    await _setRefreshing(false);
  }

  ///Returns whether a refresh operation has been triggered and is in progress.
  Future<bool> isRefreshing() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel?.invokeMethod('isRefreshing', args);
  }

  ///Sets the color of the refresh control.
  Future<void> setColor(Color color) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('color', () => color.toHex());
    await _channel?.invokeMethod('setColor', args);
  }

  ///Sets the background color of the refresh control.
  Future<void> setBackgroundColor(Color color) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('color', () => color.toHex());
    await _channel?.invokeMethod('setBackgroundColor', args);
  }

  ///Set the distance to trigger a sync in dips.
  ///
  ///**NOTE**: Available only on Android.
  Future<void> setDistanceToTriggerSync(int distanceToTriggerSync) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('distanceToTriggerSync', () => distanceToTriggerSync);
    await _channel?.invokeMethod('setDistanceToTriggerSync', args);
  }

  ///Sets the distance that the refresh indicator can be pulled beyond its resting position during a swipe gesture.
  ///
  ///**NOTE**: Available only on Android.
  Future<void> setSlingshotDistance(int slingshotDistance) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('slingshotDistance', () => slingshotDistance);
    await _channel?.invokeMethod('setSlingshotDistance', args);
  }

  ///Gets the default distance that the refresh indicator can be pulled beyond its resting position during a swipe gesture.
  ///
  ///**NOTE**: Available only on Android.
  Future<int> getDefaultSlingshotDistance() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel?.invokeMethod('getDefaultSlingshotDistance', args);
  }

  ///Use [setIndicatorSize] instead.
  @Deprecated("Use setIndicatorSize instead")
  Future<void> setSize(AndroidPullToRefreshSize size) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('size', () => size.toNativeValue());
    await _channel?.invokeMethod('setSize', args);
  }

  ///Sets the size of the refresh indicator. One of [PullToRefreshSize.DEFAULT], or [PullToRefreshSize.LARGE].
  ///
  ///**NOTE**: Available only on Android.
  Future<void> setIndicatorSize(PullToRefreshSize size) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('size', () => size.toNativeValue());
    await _channel?.invokeMethod('setSize', args);
  }

  ///Use [setStyledTitle] instead.
  @Deprecated("Use setStyledTitle instead")
  Future<void> setAttributedTitle(IOSNSAttributedString attributedTitle) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('attributedTitle', () => attributedTitle.toMap());
    await _channel?.invokeMethod('setStyledTitle', args);
  }

  ///Sets the styled title text to display in the refresh control.
  ///
  ///**NOTE**: Available only on iOS.
  Future<void> setStyledTitle(AttributedString attributedTitle) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('attributedTitle', () => attributedTitle.toMap());
    await _channel?.invokeMethod('setStyledTitle', args);
  }
}
