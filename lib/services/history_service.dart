import 'package:flutter/material.dart'; // ✅ ИМПОРТ ДЛЯ Color
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/verification_result.dart';

class HistoryService {
  static const String _key = 'trureality_history';
  static const int _maxItems = 50;

  static Future<void> saveVerification(VerificationResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await _loadHistory();
    
    history.insert(0, {
      'timestamp': DateTime.now().toIso8601String(),
      'statement': result.statement,
      'status': result.status.toString().split('.').last,
      'explanation': result.explanation,
      'sources': result.sources,
    });
    
    if (history.length > _maxItems) {
      history.removeRange(_maxItems, history.length);
    }
    
    await prefs.setString(_key, jsonEncode(history));
  }

  static Future<List<Map<String, dynamic>>> loadHistory() async {
    return await _loadHistory();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<List<Map<String, dynamic>>> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);
      if (json == null) return [];
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'verified': return const Color(0xFF00D4AA);
      case 'disputed': return Colors.redAccent;
      default: return Colors.amber;
    }
  }
}