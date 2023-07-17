import 'package:flutter_dotenv/flutter_dotenv.dart';

class Enviorment {
  static String apiUrl = dotenv.env["API_URL"] ?? "No está configurada la API";

  static initEnviornment() async {
    await dotenv.load(fileName: ".env");
  }
}
