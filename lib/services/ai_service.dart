import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/verification_result.dart';

class AiService {
  // ⚠️ ВСТАВЬ СЮДА СВОИ ДАННЫЕ
  static const String apiKey = String.fromEnvironment('YANDEX_API_KEY', defaultValue: 'YOUR_API_KEY_HERE'); // Твой API-ключ
  static const String folderId = "b1g9f0d2b33nco43vqg3";          // Твой Folder ID

  static const String apiUrl = "https://llm.api.cloud.yandex.net/foundationModels/v1/completion";

  static const String systemPrompt = '''
Ты — эксперт по проверке фактов. Пользователь может говорить голосом, поэтому текст может содержать слова-паразиты ("э", "ну", "типа") или обрывки фраз.
Твоя задача:
1. Проигнорировать речевой шум и выделить СУТЬ утверждения.
2. Проанализировать факт и вернуть СТРОГО JSON без markdown-тегов.

Допустимые статусы (status):
- "verified" (истина)
- "disputed" (ложь)
- "pending" (мнение/недостаточно данных)

Формат ответа:
{
  "status": "verified",
  "explanation": "Краткое объяснение на русском языке.",
  "sources": ["Надежный источник 1", "Надежный источник 2"]
}
''';

  static Future<VerificationResult> checkStatement(String statement) async {
    if (apiKey == "YOUR_API_KEY_HERE") {
      throw Exception('API ключ не установлен');
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Api-Key $apiKey',
        },
        body: jsonEncode({
          "modelUri": "gpt://$folderId/yandexgpt/latest",
          "completionOptions": {
            "stream": false,
            "temperature": 0.1,
            "maxTokens": 1000
          },
          "messages": [
            {"role": "system", "text": systemPrompt},
            {"role": "user", "text": statement}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final resultText = body['result']['alternatives'][0]['message']['text'];
        
        final cleanJson = resultText
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
            
        final Map<String, dynamic> data = jsonDecode(cleanJson);

        return VerificationResult(
          statement: statement,
          status: _parseStatus(data['status']),
          explanation: data['explanation'] ?? 'Нет объяснения',
          sources: List<String>.from(data['sources'] ?? []),
        );
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      return VerificationResult(
        statement: statement,
        status: VerificationStatus.pending,
        explanation: 'Ошибка: $e',
      );
    }
  }

  static VerificationStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'verified': return VerificationStatus.verified;
      case 'disputed': return VerificationStatus.disputed;
      default: return VerificationStatus.pending;
    }
  }
}