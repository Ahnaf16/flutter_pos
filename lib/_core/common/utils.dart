import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pos/main.export.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Returns `null` and ignores the input.
///
/// Shortcut function to return null and ignore input parameter:
Null identityNull<T>(T a) => null;

class Copier {
  const Copier._();
  static copy(String? text) {
    if (text == null) return;
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
  }
}

ColorFilter colorFilter(Color color) => ColorFilter.mode(color, BlendMode.srcIn);

class URLHelper {
  const URLHelper._();

  static FVoid url(String url) async {
    if (!url.startsWith(RegExp('(http(s)://.)'))) url = 'https://$url';

    await launchUrlString(url);
    return;
  }

  static FVoid call(String number) async {
    await launchUrl(Uri(scheme: 'tel', path: number));
    return;
  }

  static FVoid whatsApp(String number) async {
    final query = {'phone': number, 'type': 'phone_number', 'app_absent': '0'};
    final uri = Uri(scheme: 'https', host: 'api.whatsapp.com', path: 'send/', queryParameters: query);

    await launchUrl(uri);
    return;
  }

  static FVoid mail(String mail) async {
    if (mail.isValidEmail) {
      await launchUrl(Uri(scheme: 'mailto', path: mail));
    }
    return;
  }

  static FVoid sms(String number, String message) async {
    await launchUrl(
      Uri(scheme: 'sms', path: number, queryParameters: <String, String>{'body': Uri.encodeComponent(message)}),
    );
    return;
  }
}

class InputUtils {
  static void hideKeyboard() {
    SystemChannels.textInput.invokeMethod<String>('TextInput.hide');
  }

  static bool get isMouseConnected => RendererBinding.instance.mouseTracker.mouseIsConnected;

  static void unFocus() {
    primaryFocus?.unfocus();
  }
}

String decodeUri(String uri) => Uri.decodeComponent(uri);
String? tryDecodeUri(dynamic uri) {
  try {
    return decodeUri(uri);
  } catch (e) {
    return null;
  }
}

String encodeUri(String uri) => Uri.encodeComponent(uri);

final decimalRegExp = RegExp(r'^\d*\.?\d*$');
