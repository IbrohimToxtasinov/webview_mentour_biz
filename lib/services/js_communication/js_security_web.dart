import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'js_security_stub.dart';

class JsSecurityServiceImpl implements JsSecurityService {
  VoidCallback? _onFreezeTriggered;
  VoidCallback? _onViolationTriggered;

  html.EventListener? _visibilityListener;
  html.EventListener? _blurListener;

  @override
  void initialize({
    required VoidCallback onFreezeTriggered,
    required VoidCallback onViolationTriggered,
  }) {
    _onFreezeTriggered = onFreezeTriggered;
    _onViolationTriggered = onViolationTriggered;

    // Bind window.examFreeze to trigger local freeze
    js.context['examFreeze'] = () {
      _onFreezeTriggered?.call();
    };

    // Observe document.visibilitychange
    _visibilityListener = (html.Event event) {
      if (html.document.visibilityState == 'hidden') {
        _sendViolationToHost();
        _onViolationTriggered?.call();
      }
    };
    html.document.addEventListener('visibilitychange', _visibilityListener!);

    // Observe window.blur
    _blurListener = (html.Event event) {
      _sendViolationToHost();
      _onViolationTriggered?.call();
    };
    html.window.addEventListener('blur', _blurListener!);
  }

  void _sendViolationToHost() {
    try {
      final channel = js.context['ExamSecurityChannel'];
      if (channel != null) {
        js.context.callMethod('eval', [
          "if (window.ExamSecurityChannel) { window.ExamSecurityChannel.postMessage('violation'); }"
        ]);
      }
    } catch (e) {
      debugPrint('Error sending violation to host: $e');
    }
  }

  @override
  void dispose() {
    if (_visibilityListener != null) {
      html.document.removeEventListener('visibilitychange', _visibilityListener!);
      _visibilityListener = null;
    }
    if (_blurListener != null) {
      html.window.removeEventListener('blur', _blurListener!);
      _blurListener = null;
    }
    js.context['examFreeze'] = null;
  }
}

JsSecurityService getService() => JsSecurityServiceImpl();
