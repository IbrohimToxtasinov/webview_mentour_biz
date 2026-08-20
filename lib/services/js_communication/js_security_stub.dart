import 'package:flutter/foundation.dart';

abstract class JsSecurityService {
  void initialize({
    required VoidCallback onFreezeTriggered,
    required VoidCallback onViolationTriggered,
  });

  void dispose();
}

class JsSecurityServiceStub implements JsSecurityService {
  @override
  void initialize({
    required VoidCallback onFreezeTriggered,
    required VoidCallback onViolationTriggered,
  }) {}

  @override
  void dispose() {}
}

JsSecurityService getService() => JsSecurityServiceStub();
