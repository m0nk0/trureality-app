import 'package:flutter/material.dart';

class CrossVerificationSimulation extends StatefulWidget {
  const CrossVerificationSimulation({super.key});

  @override
  State<CrossVerificationSimulation> createState() => _CrossVerificationSimulationState();
}

class _CrossVerificationSimulationState extends State<CrossVerificationSimulation> {
  int _confirmedCount = 0;
  bool _showVerdict = false;
  final List<Map<String, dynamic>> _verifiers = [];

  @override
  void initState() {
    super.initState();
    _runSimulation();
  }

  Future<void> _runSimulation() async {
    // 1. Появление поста
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // 2. Пошаговая "верификация" (симуляция прихода 100 пользователей)
    for (int i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 40)); // ~4 секунды на все 100
      if (!mounted) return;
      setState(() {
        _confirmedCount = i;
        // Показываем только первые 12 аватаров для производительности
        if (_verifiers.length < 12) {
          _verifiers.add({
            'rating': 85 + (i % 15), // Рейтинг от 85 до 99
            'initial': String.fromCharCode(65 + (i % 26)), // A-Z
          });
        }
      });
    }

    // 3. Задержка перед вердиктом
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _showVerdict = true);
  }

  void _replay() {
    setState(() {
      _confirmedCount = 0;
      _showVerdict = false;
      _verifiers.clear();
    });
    _runSimulation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        title: const Text('TrueTalk: Перекрёстная верификация'),
        backgroundColor: const Color(0xFF0F1115),
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _replay,
            icon: const Icon(Icons.replay, color: Color(0xFF00D4AA)),
            label: const Text('Повторить', style: TextStyle(color: Color(0xFF00D4AA))),
          )
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
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

              // 📊 Счётчик и прогресс
              Row(
                children: [
                  SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      value: _confirmedCount / 100,
                      strokeWidth: 2,
                      color: _confirmedCount >= 100 ? const Color(0xFF00D4AA) : Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Подтверждено: $_confirmedCount / 100 независимых экспертов',
                      style: TextStyle(
                        color: _confirmedCount >= 100 ? const Color(0xFF00D4AA) : Colors.amber,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 📈 Прогресс-бар
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _confirmedCount / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _confirmedCount >= 100 ? const Color(0xFF00D4AA) : Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 👥 Сетка верификаторов
              Text(
                'Последние подтвердившие:',
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
              if (_showVerdict)
                AnimatedOpacity(
                  opacity: _showVerdict ? 1.0 : 0.0,
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
                      children: [
                        const Icon(Icons.shield_rounded, color: Color(0xFF00D4AA), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '✅ Подтверждено сообществом',
                                style: TextStyle(color: Color(0xFF00D4AA), fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '100 независимых пользователей с рейтингом правды ≥85 подтвердили факт. Информация помечена как достоверная.',
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