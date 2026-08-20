import 'js_security_stub.dart';
import 'js_security_stub.dart'
    if (dart.library.html) 'js_security_web.dart'
    as impl;

class JsSecurityServiceBridge {
  static final JsSecurityService _instance = impl.getService();

  static JsSecurityService get instance => _instance;
}
