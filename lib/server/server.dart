import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:flutter_send_sms/flutter_send_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmsServer {
  HttpServer? _server;

  Future<void> start() async {
    final router = Router();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final apiKey = pref.getString("api-key");
    final apiKeyStatus = pref.getString("api-key-status");

    router.get('/api/status', (Request request) {
      return Response.ok(
        '{"success":true,"server":"running"}',
        headers: {'content-type': 'application/json'},
      );
    });

    router.post('/api/send-sms', (Request request) async {
      try {
        final body = await request.readAsString();
        final parseData = jsonDecode(body);
        final authHeader = request.headers['x-tesms'];

        final String? number = parseData['phone']?.toString();
        final String? data = parseData['data']?.toString();

        if (number == null || number.trim().isEmpty) {
          return Response.badRequest(
            body: jsonEncode({
              'success': false,
              'message': 'Phone number is required',
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        if (data == null || data.trim().isEmpty) {
          return Response.badRequest(
            body: jsonEncode({
              'success': false,
              'message': 'SMS message is required',
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        if (apiKeyStatus == "true") {
          if (apiKey != authHeader) {
            return Response.badRequest(
              body: jsonEncode({
                'success': false,
                'message': 'Authorization failed',
              }),
              headers: {'content-type': 'application/json'},
            );
          }
        }

        var status = await Permission.sms.status;

        // Request SMS permission
        if (status.isDenied) {
          Permission.sms.request();
        } else {
          // Send SMS
          await FlutterSendSms.sendSms(number, data);
        }

        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'SMS sent successfully',
            'phone': number,
          }),
          headers: {'content-type': 'application/json'},
        );
      } catch (err) {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'message': 'SMS sending failed',
            'error': err.toString(),
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    _server = await shelf_io.serve(router.call, InternetAddress.anyIPv4, 8080);
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }
}
