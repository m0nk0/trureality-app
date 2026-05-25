import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ Добавь в pubspec: flutter pub add intl
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await HistoryService.loadHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1C21),
        title: const Text('Очистить историю?', style: TextStyle(color: Colors.white)),
        content: const Text('Все сохранённые проверки будут удалены', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена', style: TextStyle(color: Colors.grey))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), child: const Text('Удалить', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      await HistoryService.clearHistory();
      _loadHistory();
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd.MM HH:mm').format(date);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        title: const Text('История TrueReality'),
        backgroundColor: const Color(0xFF0F1115),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Очистить историю',
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA)))
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey[600]),
                      const SizedBox(height: 16),
                      Text('История пуста', style: TextStyle(color: Colors.grey[400], fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Проверенные факты появятся здесь', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  color: const Color(0xFF00D4AA),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      final status = item['status'] as String;
                      final color = HistoryService.getStatusColor(status);
                      
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Заголовок: статус + дата
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                    const SizedBox(width: 8),
                                    Text(
                                      status == 'verified' ? '✅ Подтверждено' : 
                                      status == 'disputed' ? '❌ Опровергнуто' : '⏳ На проверке',
                                      style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                Text(_formatDate(item['timestamp']), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            
                            // Утверждение
                            Text(
                              item['statement'] as String,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            
                            // Объяснение (сокращённо)
                            if (item['explanation'] != null)
                              Text(
                                item['explanation'] as String,
                                style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.4),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            
                            // Источники (если есть)
                            if (item['sources'] != null && (item['sources'] as List).isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: (item['sources'] as List).take(3).map((s) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(6)),
                                  child: Text(s.toString(), style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 11)),
                                )).toList(),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}