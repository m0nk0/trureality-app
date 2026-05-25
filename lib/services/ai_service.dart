import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/verification_result.dart';

class AiService {
  // ⚠️ Вставь свой API ключ сюда или используй .env
  static String get apiKey => dotenv.env['YANDEX_API_KEY'] ?? '';
  
  // Используем YandexGPT Lite (дешевле и быстрее)
  static const String modelUri = 'llm.api.cloud.yandex.net';
  static const String folderId = 'b1g9f0d2b33nco43vqg3'; // Нужен для YandexGPT

  /// 🔍 Основной метод проверки
  /// [type]: 'text', 'voice' или 'url'
  static Future<VerificationResult> checkStatement(String text, {String type = 'text'}) async {
    if (apiKey == 'YOUR_API_KEY_HERE') {
      return VerificationResult(
        statement: text,
        status: VerificationStatus.pending,
        explanation: 'Ошибка: API ключ не установлен.',
        sources: [],
      );
    }

    // 📅 Получаем текущую дату для контекста
    final currentDate = DateTime.now().toIso8601String().split('T')[0];

    // 📝 Формируем промпт в зависимости от типа
    final prompt = _buildPrompt(text, type, currentDate);

    try {
      final response = await _sendToYandexGPT(prompt);
      return _parseResponse(response, text);
    } catch (e) {
      debugPrint('❌ Ошибка API: $e');
      return VerificationResult(
        statement: text,
        status: VerificationStatus.pending,
        explanation: 'Сервис временно недоступен. Попробуйте позже.',
        sources: [],
      );
    }
  }

  ///  Генератор промптов
  static String _buildPrompt(String input, String type, String date) {
    // Базовая инструкция
    String baseInstruction = '''
Ты — независимый эксперт по проверке фактов (Fact-Checker). 
Текущая дата: $date.

Твоя задача: проанализировать входящие данные и вернуть результат в формате JSON.

ПРАВИЛА:
1. Если утверждение касается политиков, законов или событий — ОБЯЗАТЕЛЬНО сверяй с актуальностью на $date.
   - Пример: Если спрашивают про президента США, а дата после янв 2025, учитывай результаты выборов 2024.
2. Если ты НЕ УВЕРЕН на 100% или данных недостаточно — ставь статус "pending". Не выдумывай факты.
3. Всегда приводи источники (URL или название), на которые опираешься.
''';

    if (type == 'url') {
      return '''
$baseInstruction

ЗАДАЧА: Проанализируй ссылку "$input".
1. Оцени домен: это известный надежный источник или подозрительный сайт?
2. Предположи, о чем может быть статья, исходя из URL.
3. Вердикт: Насколько этому источнику можно доверять?

ФОРМАТ ОТВЕТА (JSON):
{
  "status": "verified" | "disputed" | "pending",
  "explanation": "Анализ домена и надежности источника...",
  "sources": ["$input"]
}
''';
    } else {
      // Текст или Голос
      return '''
$baseInstruction

ЗАДАЧА: Проверь истинность утверждения: "$input".

ФОРМАТ ОТВЕТА (JSON):
{
  "status": "verified" | "disputed" | "pending",
  "explanation": "Краткое пояснение (2-3 предложения) с учетом даты $date...",
  "sources": ["URL источника 1", "URL источника 2"]
}
''';
    }
  }

  /// 📡 Отправка запроса в YandexGPT
  static Future<Map<String, dynamic>> _sendToYandexGPT(String prompt) async {
    final url = Uri.https(modelUri, '/foundationModels/v1/completion');
    
    // Формируем тело запроса для YandexGPT
    final body = jsonEncode({
      "modelUri": "gpt://$folderId/yandexgpt-lite",
      "completionOptions": {
        "stream": false,
        "temperature": 0.3, // Низкая температура для фактов
        "maxTokens": "1000"
      },
      "messages": [
        {"role": "system", "text": "You are a JSON-only responder."},
        {"role": "user", "text": prompt}
      ]
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Api-Key $apiKey',
        'x-folder-id': folderId,
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['result']['alternatives'][0]['message'];
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  /// 📦 Парсинг ответа
  static VerificationResult _parseResponse(Map<String, dynamic> aiMessage, String originalText) {
    try {
      String text = aiMessage['text'] ?? '';
      
      // Очистка от markdown-обертки (```json ... ```)
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final json = jsonDecode(text);
      
      return VerificationResult(
        statement: originalText,
        status: _mapStatus(json['status']),
        explanation: json['explanation'] ?? 'Анализ завершен.',
        sources: List<String>.from(json['sources'] ?? []),
      );
    } catch (e) {
      debugPrint('❌ Ошибка парсинга JSON: $e');
      return VerificationResult(
        statement: originalText,
        status: VerificationStatus.pending,
        explanation: 'ИИ вернул некорректный формат. Требуется ручная проверка.',
        sources: [],
      );
    }
  }

  static VerificationStatus _mapStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'verified': return VerificationStatus.verified;
      case 'disputed': return VerificationStatus.disputed;
      default: return VerificationStatus.pending;
    }
  }
}