// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

import 'dart:io';

Future<String> getDeviceIp() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
    includeLoopback: false,
  );

  for (final interface in interfaces) {
    for (final address in interface.addresses) {
      final ip = address.address;

      if (_isPrivateIp(ip)) {
        return ip;
      }
    }
  }

  return 'Not found';
}

bool _isPrivateIp(String ip) {
  final parts = ip.split('.');

  if (parts.length != 4) return false;

  final a = int.tryParse(parts[0]);
  final b = int.tryParse(parts[1]);

  if (a == null || b == null) return false;

  // 10.0.0.0/8
  if (a == 10) return true;

  // 172.16.0.0/12
  if (a == 172 && b >= 16 && b <= 31) {
    return true;
  }

  // 192.168.0.0/16
  if (a == 192 && b == 168) {
    return true;
  }

  return false;
}