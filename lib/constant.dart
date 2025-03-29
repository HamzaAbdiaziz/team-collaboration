import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String openAIKey = dotenv.env['OPENAI_API_KEY'] ?? '';
}

