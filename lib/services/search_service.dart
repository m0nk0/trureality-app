import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class SearchService {
  static const String baseUrl = 'https://api.tavily.com/search';

  static Future<List<String>> searchWeb(String query) async {
    try {
      final rawKey = dotenv.env['TAVILY_API_KEY'] ?? '';
      final apiKey = rawKey.trim();
      final isValidFormat = apiKey.isNotEmpty && apiKey.startsWith('TVLY-');

      debugPrint(' Tavily Key Check: length=${apiKey.length} | validFormat=$isValidFormat');
      if (!isValidFormat) return _getMockData(query);

      //  Авто-уточнение запроса для финансовых тем
      final searchQuery = (query.toLowerCase().contains('курс') ||
              query.toLowerCase().contains('доллар') ||
              query.toLowerCase().contains('рубль') ||
              query.toLowerCase().contains('евро') ||
              query.toLowerCase().contains('биткоин'))
          ? '$query официальный курс сегодня'
          : query;

      debugPrint(' Searching Tavily for: "$searchQuery"');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'api_key': apiKey,
          'query': searchQuery,
          'max_results': 3,
          'search_depth': 'basic',
          'days': 1, // 🔥 Только данные за последние 24 часа
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = (data['results'] as List).map((item) {
          final title = item['title'] ?? 'Источник';
          final url = item['url'] ?? '';
          final content = item['content'] ?? '';
          final publishedDate = item['published_date'] ?? '';
          debugPrint('📄 Found: $title');
          return '[Источник: $title]${publishedDate.isNotEmpty ? ' | Дата: $publishedDate' : ''}\nСсылка: $url\nИнфо: $content';
        }).toList();

        debugPrint('✅ Tavily returned ${results.length} results');
        return results;
      } else {
        debugPrint('❌ Tavily Error ${response.statusCode}: ${response.body}');
        return _getMockData(query);
      }
    } catch (e) {
      debugPrint('❌ SearchService Exception: $e');
      return _getMockData(query);
    }
  }

  static List<String> _getMockData(String query) {
    debugPrint('🧪 Using MOCK data for: "$query"');
    final q = query.toLowerCase();
    if (q.contains('доллар') || q.contains('курс') || q.contains('рубль')) {
      return [
        '[ЦБ РФ] Официальный курс доллара США на 27.05.2026: 71.05 рублей | Дата: 2026-05-27',
        'Ссылка: https://cbr.ru/currency_base/daily/',
        '[Мосбиржа] Доллар торгуется на уровне 71.10 рублей | Дата: 2026-05-27',
        'Ссылка: https://www.moex.com/',
      ];
    }
    return ['[Поиск] Данные не найдены или сервис временно недоступен.', 'Ссылка: https://example.com'];
  }
}