import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';

class Utils {
  String sanitizeValue(String value) {
    return value.replaceAll(".", "-")
        .replaceAll("#", "")
        .replaceAll("\$", "")
        .replaceAll("/", "-")
        .replaceAll("[", "")
        .replaceAll("]", "")
        .replaceAll(",", "")
        .replaceAll("{", "")
        .replaceAll("}", "");

  }

  String getFormattedTimestamp() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss:SSS');
    return formatter.format(now);
  }

  Future<String> getWebDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceData = <String, dynamic>{};

    try {
      // Fetch device information
      final webBrowserInfo = await deviceInfoPlugin.webBrowserInfo;
      deviceData.addAll({
        'browserName': webBrowserInfo.browserName.name,
        'appCodeName': webBrowserInfo.appCodeName,
        'appName': webBrowserInfo.appName,
        'appVersion': webBrowserInfo.appVersion,
        'deviceMemory': webBrowserInfo.deviceMemory,
        'language': webBrowserInfo.language,
        'languages': webBrowserInfo.languages,
        'platform': webBrowserInfo.platform,
        'product': webBrowserInfo.product,
        'userAgent': webBrowserInfo.userAgent,
        'vendor': webBrowserInfo.vendor,
        'hardwareConcurrency': webBrowserInfo.hardwareConcurrency,
        'maxTouchPoints': webBrowserInfo.maxTouchPoints,
      });

      // Fetch IP address

    } catch (e) {
      deviceData['error'] = 'Failed to get device info: $e';
    }
    final ipInfo = await _getIpInfo();

    String value = '$ipInfo ${sanitizeValue(deviceData.toString())}';
    print(value);

    return value;
  }

  Future<Map<String, dynamic>> _getIpInfo() async {
    try {
      final response = await http.get(Uri.parse('https://api64.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'ip': data['ip']};
      } else {
        return {'ip_error': 'Failed to get IP address'};
      }
    } catch (e) {
      return {'ip_error': 'Failed to get IP address: $e'};
    }
  }
}
