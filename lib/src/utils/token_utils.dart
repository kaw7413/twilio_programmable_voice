import 'package:jwt_decoder/jwt_decoder.dart';

Duration getDurationBeforeTokenExpires(String token) {
  DateTime expirationDate = JwtDecoder.getExpirationDate(token);
  return expirationDate.difference(DateTime.now());
}
