import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'search_service.dart';

class InfoSearchResult {
  final String query;
  final String answer;        // Краткий ответ (например, "92.45 рублей")
  final List<String> sources; // 2-3 источника текстом
  final DateTime fetchedAt;

  InfoSearchResult({
    required this.query,
    required this.answer,
    required this.sources,
    DateTime? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();
}

class InfoSearchService {
  static String get yandexApiKey => dotenv.env['YANDEX_API_KEY'] ?? '';
  static String get tavilyApiKey => dotenv.env['TAVILY_API_KEY'] ?? '';
  
  static const String yandexModelUri = 'llm.api.cloud.yandex.net';
  static const String folderId = 'b1g9f0d2b33nco43vqg3';

  /// 🔍 Поиск информации без оценки истинности
  static Future<InfoSearchResult> searchInfo(String query) async {
    if (yandexApiKey.isEmpty) {
      throw Exception('Yandex API ключ не установлен');
    }

    // 1. Ищем в интернете
    final searchResults = await SearchService.searchWeb(query);
    final context = searchResults.isEmpty
        ? 'Данные не найдены.'
        : searchResults.map((r) => '- $r').join('\n');

    // 2. Формируем промпт для ИЗВЛЕЧЕНИЯ фактов
    final prompt = _buildSearchPrompt(query, context);

    // 3. Отправляем в YandexGPT
    final aiResponse = await _sendToYandexGPT(prompt);
    
    return _parseSearchResponse(aiResponse, query);
  }

  ///  Промпт ТОЛЬКО для извлечения информации (без вердиктов)
  static String _buildSearchPrompt(String query, String context) {
    return '''
Ты — помощник по поиску фактов. Твоя задача: найти и кратко изложить информацию по запросу.

🌐 КОНТЕКСТ ИЗ ИНТЕРНЕТА:
$context

❓ ЗАПРОС ПОЛЬЗОВАТЕЛЯ: "$query"

 ИНСТРУКЦИИ:
1. Найди в контексте прямой ответ на запрос.
2. Если это число (курс, температура, дата) — укажи точное значение.
3. Если информации несколько — выбери наиболее актуальную (свежую).
4. Если контекст пуст или не содержит ответа — напиши "Информация не найдена".
5. Укажи 2-3 источника, на которые опираешься.

📤 ФОРМАТ ОТВЕТА (СТРОГО JSON, без markdown):
{
  "answer": "Краткий ответ на русском (1-2 предложения, макс. 100 символов)",
  "sources": ["Источник 1", "Источник 2"]
}

 ПРИМЕРЫ:
Запрос: "Курс доллара сегодня"
Контекст: ["ЦБ РФ: курс доллара 92.45 рублей на 27.05.2026"]
Ответ: {"answer": "92.45 рублей (ЦБ РФ, 27.05.2026)", "sources": ["Центральный банк РФ"]}

Запрос: "Столица Австралии"
Контекст: ["Канберра — столица Австралии с 1927 года"]
Ответ: {"answer": "Канберра", "sources": ["Википедия", "Британника"]}
''';
  }

  /// 📡 Отправка в YandexGPT
  static Future<Map<String, dynamic>> _sendToYandexGPT(String prompt) async {
    final url = Uri.https(yandexModelUri, '/foundationModels/v1/completion');
    
    final body = jsonEncode({
      "modelUri": "gpt://$folderId/yandexgpt-lite",
      "completionOptions": {
        "stream": false,
        "temperature": 0.1,
        "maxTokens": 800
      },
      "messages": [
        {"role": "system", "text": "You are a JSON-only responder. Output ONLY valid JSON."},
        {"role": "user", "text": prompt}
      ]
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Api-Key $yandexApiKey',
        'x-folder-id': folderId,
      },
      body: body,
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['result']['alternatives'][0]['message'];
    } else {
      throw Exception('YandexGPT Error: ${response.statusCode}');
    }
  }

  ///  Парсинг ответа
  static InfoSearchResult _parseSearchResponse(Map<String, dynamic> aiMessage, String originalQuery) {
    try {
      String text = aiMessage['text'] ?? '';
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final json = jsonDecode(text);
      
      return InfoSearchResult(
        query: originalQuery,
        answer: json['answer'] ?? 'Информация не найдена.',
        sources: List<String>.from(json['sources'] ?? []),
      );
    } catch (e) {
      debugPrint('❌ Parse error: $e');
      return InfoSearchResult(
        query: originalQuery,
        answer: 'Не удалось обработать ответ.',
        sources: [],
      );
    }
  }
}