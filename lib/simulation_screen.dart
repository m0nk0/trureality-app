import 'package:flutter/material.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  // Этапы анимации
  bool _showPost = false;
  bool _isChecking = false;
  bool _showMarkers = false;
  bool _isHighlighting = false;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _runSimulation();
  }

  Future<void> _runSimulation() async {
    // 1. Появляется пост
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _showPost = true);

    // 2. Через 1 сек появляется статус проверки
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isChecking = true);

    // 3. Через 2.5 сек появляются маркеры
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _showMarkers = true);

    // 4. Через 1 сек один маркер увеличивается и краснеет
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isHighlighting = true);

    // 5. Через 0.8 сек появляется финальное сообщение
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _showResult = true);
  }

  void _replay() {
    setState(() {
      _showPost = false;
      _isChecking = false;
      _showMarkers = false;
      _isHighlighting = false;
      _showResult = false;
    });
    _runSimulation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        title: const Text('TrueTalk: Симуляция'),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 📝 Пост (стиль Telegram)
              AnimatedOpacity(
                opacity: _showPost ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFF00D4AA),
                            child: Icon(Icons.newspaper, color: Colors.black, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Наука и Факты', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('14:32', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '🚨 СРОЧНО: Ученые доказали, что ежедневный прием кофеина снижает продолжительность жизни на 10 лет. Источник: "Journal of Health", 2024.',
                        style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Icon(Icons.image, color: Colors.grey, size: 40)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔍 Статус проверки
              if (_isChecking)
                Row(
                  children: [
                    SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xFF00D4AA)),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Идет оценка достоверности информации с помощью ИИ, анализирую текст...',
                      style: TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // 🔵 Визуальные маркеры (5 кружочков)
              if (_showMarkers)
                AnimatedOpacity(
                  opacity: _showMarkers ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final isTarget = index == 2; // 3-й кружок станет красным
                      final size = isTarget && _isHighlighting ? 48.0 : 32.0;
                      final color = isTarget && _isHighlighting ? Colors.redAccent : const Color(0xFF00D4AA);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutBack,
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: isTarget && _isHighlighting ? 0.5 : 0.3),
                                blurRadius: isTarget && _isHighlighting ? 12 : 6,
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              const SizedBox(height: 20),

              // ⚠️ Финальный вердикт
              if (_showResult)
                AnimatedOpacity(
                  opacity: _showResult ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Информация недостоверна',
                                style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Утверждение не подтверждается доступными проверенными источниками. Научные исследования показывают отсутствие прямой корреляции между умеренным потреблением кофеина и снижением продолжительности жизни.',
                                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}