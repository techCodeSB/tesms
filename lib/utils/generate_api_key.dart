import 'dart:math';

String generateApiKey() {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      'abcdefghijklmnopqrstuvwxyz'
      '0123456789';

  final random = Random.secure();

  return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
}
