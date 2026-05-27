import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/verification_result.dart';
import 'search_service.dart';

class AiService {
  static String get yandexApiKey => dotenv.env['YANDEX_API_KEY'] ?? '';
  static const String yandexModelUri = 'llm.api.cloud.yandex.net';
  static const String folderId = 'b1g9f0d2b33nco43vqg3';

  static Future<VerificationResult> checkStatement(String text, {String type = 'text'}) async {
    if (yandexApiKey.isEmpty) {
      return _errorResult(text, 'Yandex API ключ не установлен в .env');
    }

    final date = DateTime.now().toIso8601String().split('T')[0];
    List<String> context = [];

    if (type != 'url') {
      debugPrint(' Запуск поиска для: "$text"');
      context = await SearchService.searchWeb(text);
    }

    final prompt = _buildVerifyPrompt(text, type, date, context);
    
    try {
      debugPrint('🚀 Отправка запроса в YandexGPT...');
      final response = await _sendToGPT(prompt);
      return _parseVerifyResponse(response, text);
    } catch (e) {
      debugPrint('❌ Ошибка AI/Network: $e');
      return _errorResult(text, 'Ошибка обработки: $e');
    }
  }

  static String _buildVerifyPrompt(String input, String type, String date, List<String> ctx) {
    final contextStr = ctx.isEmpty 
        ? 'КОНТЕКСТ ОТСУТСТВУЕТ (поиск не вернул данных).' 
        : 'КОНТЕКСТ ИЗ ИНТЕРНЕТА:\n${ctx.join('\n\n')}';

    debugPrint('📄 Контекст для ИИ:\n$contextStr');

    return '''
Ты — профессиональный фактчекер. Текущая дата: $date.

$contextStr

🗣️ УТВЕРЖДЕНИЕ ПОЛЬЗОВАТЕЛЯ: "$input"

 ПРАВИЛА АНАЛИЗА (выбери ОДИН тип):
1. 🔢 ЧИСЛОВОЙ ФАКТ: содержит цифры, даты, курсы, проценты, параметры.
   → Сравни с контекстом. Разница >10% или противоречие → "disproven". Совпадает → "verified".
2.  КАЧЕСТВЕННЫЙ/НАУЧНЫЙ ФАКТ: утверждение о природе, медицине, истории, технологиях (напр. "Земля плоская", "Кофеин продлевает жизнь").
   → НЕ ТРЕБУЙ ЧИСЕЛ. Опираться на научный консенсус, официальные позиции (ВОЗ, NASA, РАН) и данные из контекста.
   → Подтверждено наукой/историей → "verified". Опровергнуто наукой → "disproven".
3. 💭 МНЕНИЕ: субъективная оценка, эмоция, предпочтение ("лучший", "ужасный", "я думаю").
   → Всегда возвращай "opinion".
4. ❓ ГИПОТЕЗА/СЛУХ: теория без окончательных доказательств, противоречивые данные.
   → Возвращай "hypothesis".
5. ⚪ НЕЯСНО: контекст пуст, данные устарели или утверждение бессмысленно.
   → Возвращай "unclear". НЕ ПРИДУМЫВАЙ данные.

🔗 ИСТОЧНИКИ: В массив sources клади ТОЛЬКО полные URL из контекста. Если контекст пуст → [].

📤 ФОРМАТ ОТВЕТА (СТРОГО JSON, без markdown, без пояснений вне JSON):
{
  "status": "verified|disproven|hypothesis|opinion|unclear",
  "explanation": "Кратко на русском (макс 100 символов). Для фактов укажи суть: 'Научный консенсус подтверждает...' или 'Опровергнуто данными...'",
  "sources": ["https://url1.com", "https://url2.com"]
}

✅ ПРИМЕРЫ:
Утв: "Курс доллара 100 рублей" | Контекст: "[ЦБ РФ] 71.05 рублей"
Ответ: {"status":"disproven","explanation":"Заявлено 100₽, Факт 71.05₽ (ЦБ РФ)","sources":["https://cbr.ru/"]}

Утв: "Земля плоская" | Контекст: "[NASA] Земля имеет форму геоида, подтверждено спутниками..."
Ответ: {"status":"disproven","explanation":"Опровергнуто научными данными и космическими снимками","sources":["https://nasa.gov/"]}

Утв: "Кофеин продлевает жизнь" | Контекст: "[ВОЗ] Умеренное потребление снижает риски, но не является гарантией..."
Ответ: {"status":"hypothesis","explanation":"Частично подтверждено исследованиями, но не абсолютный факт","sources":["https://who.int/"]}

Утв: "Этот фильм лучший в истории" | Контекст: []
Ответ: {"status":"opinion","explanation":"Субъективная оценка, не подлежит фактчекингу","sources":[]}
''';
  }

  static Future<Map<String, dynamic>> _sendToGPT(String prompt) async {
    final res = await http.post(
      Uri.https(yandexModelUri, '/foundationModels/v1/completion'),
      headers: {
        'Authorization': 'Api-Key $yandexApiKey', 
        'Content-Type': 'application/json', 
        'x-folder-id': folderId
      },
      body: jsonEncode({
        "modelUri": "gpt://$folderId/yandexgpt-lite",
        "completionOptions": {"stream": false, "temperature": 0.1, "maxTokens": 1000},
        "messages": [
          {"role": "system", "text": "Output ONLY valid JSON. No markdown. No extra text."},
          {"role": "user", "text": prompt}
        ]
      }),
    ).timeout(const Duration(seconds: 15));
    
    if (res.statusCode != 200) {
      throw Exception('YandexGPT API Error: ${res.statusCode} - ${res.body}');
    }
    
    final data = jsonDecode(res.body);
    return data['result']['alternatives'][0]['message'];
  }

  static VerificationResult _parseVerifyResponse(Map<String, dynamic> msg, String orig) {
    try {
      String txt = msg['text'].toString();
      txt = txt.replaceAll('```json', '').replaceAll('```', '').trim();
      
      debugPrint('✅ Raw JSON: $txt');
      final json = jsonDecode(txt);
      
      return VerificationResult(
        statement: orig,
        status: _mapStatus(json['status']),
        explanation: json['explanation']?.toString() ?? '',
        sources: List<String>.from(json['sources'] ?? []),
      );
    } catch (e) {
      debugPrint('❌ Ошибка парсинга JSON: $e');
      return _errorResult(orig, 'Некорректный формат ответа ИИ');
    }
  }

  static VerificationResult _errorResult(String txt, String err) =>
      VerificationResult(statement: txt, status: VerificationStatus.unclear, explanation: err, sources: []);

  static VerificationStatus _mapStatus(String? s) {
    switch (s?.toLowerCase()) {
      case 'verified':   return VerificationStatus.verified;
      case 'disproven':  return VerificationStatus.disproven;
      case 'hypothesis': return VerificationStatus.hypothesis;
      case 'opinion':    return VerificationStatus.opinion;
      default:           return VerificationStatus.unclear;
    }
  }
}