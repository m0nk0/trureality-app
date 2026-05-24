import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class UrlParser {
  static Future<String> extractContent(String url) async {
    try {
      // Добавляем user-agent, чтобы некоторые сайты не блокировали
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'Mozilla/5.0 (TrueTalk Bot)'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        return 'Не удалось загрузить страницу (код ${response.statusCode})';
      }
      
      final document = parser.parse(response.body);
      
      // 1. Пробуем Open Graph (универсальный формат)
      final ogTitle = document.querySelector('meta[property="og:title"]')?.attributes['content'];
      final ogDesc = document.querySelector('meta[property="og:description"]')?.attributes['content'];
      
      if (ogTitle != null && ogTitle.isNotEmpty) {
        return '$ogTitle. ${ogDesc ?? ''}'.trim();
      }
      
      // 2. fallback: title + description
      final title = document.querySelector('title')?.text ?? '';
      final metaDesc = document.querySelector('meta[name="description"]')?.attributes['content'] ?? '';
      
      if (title.isNotEmpty) {
        return '$title. $metaDesc'.trim();
      }
      
      // 3. последний шанс: первый абзац
      final firstParagraph = document.querySelector('p')?.text ?? '';
      return firstParagraph.length > 200 
        ? firstParagraph.substring(0, 200) + '...' 
        : firstParagraph;
        
    } catch (e) {
      return 'Ошибка при загрузке: $e';
    }
  }
}