import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrossVerificationSimulation extends StatefulWidget {
  const CrossVerificationSimulation({super.key});

  @override
  State<CrossVerificationSimulation> createState() => _CrossVerificationSimulationState();
}

class _CrossVerificationSimulationState extends State<CrossVerificationSimulation> {
  int _confirmedCount = 0;
  bool _hasVoted = false;
  bool _isThresholdReached = false;
  final int _threshold = 70; // Порог для верификации
  final List<Map<String, dynamic>> _verifiers = [];
  bool _isSimulating = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCount = prefs.getInt('cv_count') ?? 0;
    final savedVoted = prefs.getBool('cv_voted') ?? false;

    if (mounted) {
      setState(() {
        _confirmedCount = savedCount;
        _hasVoted = savedVoted;
        _isThresholdReached = _confirmedCount >= _threshold;
        _isSimulating = savedCount == 0;
      });
    }

    if (savedCount == 0 && mounted) {
      _runSimulation();
    }
  }

  Future<void> _runSimulation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // 🛑 Считаем только до (порог - 1), чтобы ждать твой голос
    final stopAt = _threshold - 1;
    
    for (int i = _confirmedCount + 1; i <= stopAt; i++) {
      await Future.delayed(const Duration(milliseconds: 70));
      if (!mounted) return;
      
      setState(() {
        _confirmedCount = i;
        if (_verifiers.length < 12) {
          _verifiers.add({
            'rating': 85 + (i % 15),
            'initial': String.fromCharCode(65 + (i % 26)),
          });
        }
      });
    }
    // Останавливаем симуляцию и разблокируем кнопку
    if (mounted) setState(() => _isSimulating = false);
  }

  Future<void> _userVote() async {
    if (_hasVoted || _isSimulating) return;
    
    setState(() {
      _hasVoted = true;
      _confirmedCount++; // Твой голос = решающий +1
      if (_verifiers.length < 12) {
        _verifiers.insert(0, {'rating': 95, 'initial': 'Я'});
      }
      
      if (_confirmedCount >= _threshold) {
        _isThresholdReached = true;
      }
    });
    await _saveData();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cv_count', _confirmedCount);
    await prefs.setBool('cv_voted', _hasVoted);
  }

  Future<void> _resetSimulation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cv_count');
    await prefs.remove('cv_voted');
    
    if (mounted) {
      setState(() {
        _confirmedCount = 0;
        _hasVoted = false;
        _isThresholdReached = false;
        _verifiers.clear();
        _isSimulating = true;
      });
      _runSimulation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _confirmedCount / 100;
    final isGreen = _isThresholdReached;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        title: const Text('TrueTalk: Перекрёстная верификация'),
        backgroundColor: const Color(0xFF0F1115),
        elevation: 0,
        actions: [
          // 🔄 Кнопка "Повторить"
          TextButton.icon(
            onPressed: _resetSimulation,
            icon: const Icon(Icons.replay, color: Color(0xFF00D4AA)),
            label: const Text('Повторить', style: TextStyle(color: Color(0xFF00D4AA))),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 📝 Проверяемый факт
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🔍 Утверждение:', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Text(
                      '«Центробанк РФ повысил ключевую ставку до 21% в октябре 2024 года»',
                      style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 📊 Прогресс + Счётчик
              Row(
                children: [
                  SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2,
                      color: isGreen ? const Color(0xFF00D4AA) : Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$_confirmedCount / 100 подтверждений',
                      style: TextStyle(
                        color: isGreen ? const Color(0xFF00D4AA) : Colors.amber,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isGreen ? const Color(0xFF00D4AA) : Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🗳️ Кнопка голосования
              ElevatedButton(
                onPressed: (_hasVoted || _isSimulating) ? null : _userVote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasVoted ? Colors.grey[800] : const Color(0xFF00D4AA),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _hasVoted
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Ваш голос учтён', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : const Text(
                        '✅ Я подтверждаю этот факт',
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 20),

              // 👥 Сетка верификаторов
              Text(
                'Подтвердили эксперты:',
                style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _verifiers.map((u) => _VerifierChip(u['initial'], u['rating'])).toList(),
              ),
              const SizedBox(height: 24),

              // ✅ Финальный вердикт
              if (_isThresholdReached)
                AnimatedOpacity(
                  opacity: _isThresholdReached ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4AA).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00D4AA).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.shield_rounded, color: Color(0xFF00D4AA), size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '✅ Подтверждено сообществом',
                                style: TextStyle(color: Color(0xFF00D4AA), fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Порог в 70 независимых подтверждений достигнут. Информация помечена как достоверная.',
                                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _VerifierChip(String initial, int rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: rating >= 90 ? const Color(0xFF00D4AA) : Colors.grey[700]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: rating >= 90 ? const Color(0xFF00D4AA) : Colors.grey[700],
            child: Text(initial, style: const TextStyle(fontSize: 10, color: Colors.black)),
          ),
          const SizedBox(width: 6),
          Text(
            '⭐ $rating',
            style: TextStyle(
              color: rating >= 90 ? const Color(0xFF00D4AA) : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}