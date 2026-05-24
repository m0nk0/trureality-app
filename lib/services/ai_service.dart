import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/verification_result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  // ⚠️ Твои данные (или используй .env)
  static String get apiKey => dotenv.env['YANDEX_API_KEY'] ?? ''; 
  static const String folderId = "b1g9f0d2b33nco43vqg3";
  static const String apiUrl = "https://llm.api.cloud.yandex.net/foundationModels/v1/completion";

  /// 🔍 Основной метод проверки
  /// [input] - это может быть утверждение пользователя ИЛИ текст статьи/ссылки
  static Future<VerificationResult> checkStatement(String input) async {
    
    // 🧠 Умный промпт для авто-поиска фактов
    final systemPrompt = '''
Ты — эксперт по проверке фактов и аналитик данных. Тебе на вход подается текст (это может быть утверждение пользователя или полный текст статьи).

Твоя задача:
1. Проанализировать входной текст.
2. Если пользователь задал КОНКРЕТНЫЙ вопрос (например, "Правда ли, что Земля плоская?") — проверь только его.
3. Если конкретный вопрос НЕ задан (пользователь просто ввел текст или контент статьи):
   - Выдели 2-3 самых главных факта/тезиса из текста (сжми информацию).
   - Проверь достоверность этих ключевых тезисов.
   - Верни общий вердикт по тексту.

Формат ответа (СТРОГО JSON без markdown):
{
  "status": "verified" | "disputed" | "pending",
  "summary": "Краткое содержание (сжатие) текста, если он длинный. Если это один факт — дублируй его суть.",
  "explanation": "Развернутая проверка фактов. Если ты выделял несколько тезисов — проверь каждый.",
  "sources": ["Надежный источник 1", "Надежный источник 2"]
}

Правила:
- "verified" — факты подтверждены.
- "disputed" — в тексте есть ложь или фейки.
- "pending" — это мнение, прогноз или информации недостаточно.
''';

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
            "maxTokens": 2000 // Увеличили лимит, чтобы ИИ мог "сжать" текст
          },
          "messages": [
            {"role": "system", "text": systemPrompt},
            {"role": "user", "text": input}
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
          statement: input.length > 100 ? "${input.substring(0, 100)}..." : input, // Обрезаем длинный ввод для отображения
          status: _parseStatus(data['status']),
          explanation: data['explanation'] ?? data['summary'] ?? 'Нет объяснения',
          sources: List<String>.from(data['sources'] ?? []),
        );
      } else {
        return VerificationResult(
          statement: input,
          status: VerificationStatus.pending,
          explanation: 'Ошибка сервера: ${response.statusCode}',
        );
      }
    } catch (e) {
      return VerificationResult(
        statement: input,
        status: VerificationStatus.pending,
        explanation: 'Ошибка соединения: $e',
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