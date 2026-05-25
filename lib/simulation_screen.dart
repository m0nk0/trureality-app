import 'package:flutter/material.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  int _currentScenario = 0;
  bool _isRunning = false;
  final List<String> _titles = [
    '🤖 Сценарий 1: Оценка ИИ',
    '👥 Сценарий 2: Перекрёстная верификация',
    '🔗 Сценарий 3: Цепочка доверия',
    '⚡ Сценарий 4: Гибридная верификация',
  ];
  
  final List<Map<String, String>> _posts = [
    {
      'author': 'Наука и Факты',
      'time': 'сегодня в 14:32',
      'title': '🚨 СРОЧНО: Новое исследование',
      'text': 'Учёные из Международного института здравоохранения доказали, что ежедневный прием кофеина снижает продолжительность жизни на 10 лет.\n\nИсследование проводилось в течение 15 лет с участием более 50,000 человек.',
      'image': 'assets/images/coffee-lab.jpg',
      'likes': '12.5K',
      'comments': '3.2K',
      'shares': '8.1K',
    },
    {
      'author': 'Фактчекинг Сообщество',
      'time': 'сегодня в 15:45',
      'title': '📊 Требуется проверка фактов',
      'text': 'Новое исследование о кофеине вызвало бурные обсуждения. 69 независимых экспертов уже подтвердили данные, но для консенсуса нужно 100 голосов.\n\nПрисоединяйтесь к проверке!',
      'image': 'assets/images/experts-team.jpg',
      'likes': '8.3K',
      'comments': '1.7K',
      'shares': '4.2K',
    },
    {
      'author': 'Социальная Сеть Доверия',
      'time': 'сегодня в 16:20',
      'title': '🔗 Как работает доверие в сети',
      'text': 'Вы доверяете Пете (эксперт, рейтинг 99). Петя проверил источник и подтвердил факт. Теперь вы можете доверять этой информации через цепочку доверия.\n\nДоверие передаётся!',
      'image': 'assets/images/trust-network.jpg',
      'likes': '15.1K',
      'comments': '2.8K',
      'shares': '9.5K',
    },
    {
      'author': 'TrueReality AI',
      'time': 'сегодня в 17:00',
      'title': '✅ Гибридная верификация завершена',
      'text': 'ИИ провёл предварительный анализ → Сообщество подтвердило факт → Цепочка доверия передала верификацию.\n\nРезультат: 99.2% точности. Информация достоверна.',
      'image': 'assets/images/hybrid-ai.jpg',
      'likes': '22.7K',
      'comments': '4.1K',
      'shares': '12.3K',
    },
  ];

  // 🟦 Состояния
  bool _aiPost = false, _aiCheck = false, _aiMarkers = false, _aiVerdict = false, _aiDone = false;
  bool _crossMsg = false, _crossLoading = false, _crossVoted = false, _crossVerdict = false, _crossDone = false;
  int _crossCount = 0;
  bool _trustNode1 = false, _trustNode2 = false, _trustNode3 = false, _trustVerdict = false, _trustDone = false;
  bool _hybridDone = false;

  @override
  void initState() {
    super.initState();
    _runScenario();
  }

  Future<void> _runScenario() async {
    if (!mounted || _isRunning) return;
    setState(() => _isRunning = true);

    switch (_currentScenario) {
      case 0:
        await _delay(400); if (!mounted) return; setState(() => _aiPost = true);
        await _delay(1200); if (!mounted) return; setState(() => _aiCheck = true);
        await _delay(2000); if (!mounted) return; setState(() => _aiMarkers = true);
        await _delay(1000); if (!mounted) return; setState(() { _aiVerdict = true; _aiCheck = false; });
        await _delay(800); if (!mounted) return; setState(() => _aiDone = true);
        break;
      case 1:
        await _delay(400); if (!mounted) return; setState(() => _crossMsg = true);
        await _delay(1000); if (!mounted) return; setState(() => _crossLoading = true);
        for (int i = 1; i <= 69; i++) {
          await _delay(30); if (!mounted) return; setState(() => _crossCount = i);
        }
        if (!mounted) return; setState(() { _crossLoading = false; _crossDone = true; });
        break;
      case 2:
        await _delay(400); if (!mounted) return; setState(() => _trustNode1 = true);
        await _delay(1000); if (!mounted) return; setState(() => _trustNode2 = true);
        await _delay(1000); if (!mounted) return; setState(() => _trustNode3 = true);
        await _delay(800); if (!mounted) return; setState(() { _trustVerdict = true; _trustDone = true; });
        break;
      case 3:
        await _delay(400); if (!mounted) return; setState(() => _aiPost = true);
        await _delay(800); if (!mounted) return; setState(() => _aiCheck = true);
        await _delay(1000); if (!mounted) return; setState(() { _aiVerdict = true; _aiCheck = false; });
        await _delay(600); if (!mounted) return; setState(() { _crossMsg = true; _crossLoading = true; });
        await _delay(800); if (!mounted) return; setState(() { _crossCount = 70; _crossVerdict = true; });
        await _delay(500); if (!mounted) return; setState(() { _trustNode1 = true; _trustNode2 = true; _trustNode3 = true; });
        await _delay(800); if (!mounted) return; setState(() => _hybridDone = true);
        break;
    }
    if (mounted) setState(() => _isRunning = false);
  }

  void _nextScenario() {
    if (_currentScenario < 3) {
      setState(() { _currentScenario++; _resetStates(); _isRunning = false; });
      _runScenario();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎬 Демонстрация завершена!'), backgroundColor: Color(0xFF00D4AA)),
      );
      Navigator.pop(context);
    }
  }

  void _resetStates() {
    _aiPost = _aiCheck = _aiMarkers = _aiVerdict = _aiDone = false;
    _crossMsg = _crossLoading = _crossVoted = _crossVerdict = _crossDone = false;
    _crossCount = 0;
    _trustNode1 = _trustNode2 = _trustNode3 = _trustVerdict = _trustDone = false;
    _hybridDone = false;
  }

  Future<void> _delay(int ms) => Future.delayed(Duration(milliseconds: ms));

  void _castCrossVote() {
    if (_crossVoted || !_crossDone) return;
    setState(() { _crossVoted = true; _crossCount++; _crossVerdict = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        title: const Text('TrueReality: Демонстрация', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F1115),
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () { setState(() { _currentScenario = 0; _resetStates(); _isRunning = false; }); _runScenario(); },
            icon: const Icon(Icons.replay, color: Color(0xFF00D4AA)),
            label: const Text('Заново', style: TextStyle(color: Color(0xFF00D4AA), fontSize: 16)),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 📊 Индикатор прогресса
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: _currentScenario >= i ? 32 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _currentScenario >= i ? const Color(0xFF00D4AA) : Colors.grey[800],
                    borderRadius: BorderRadius.circular(5),
                  ),
                )),
              ),
              const SizedBox(height: 24),

              // 📝 Заголовок сценария
              Text(
                _titles[_currentScenario],
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // 🎬 Контент
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_currentScenario == 0) _buildAiScenario(),
                      if (_currentScenario == 1) _buildCrossScenario(),
                      if (_currentScenario == 2) _buildTrustChainScenario(),
                      if (_currentScenario == 3) _buildHybridScenario(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // 🔘 Кнопка
              ElevatedButton(
                onPressed: (_currentScenario == 0 && !_aiDone) ||
                           (_currentScenario == 1 && !_crossDone) ||
                           (_currentScenario == 2 && !_trustDone) ||
                           (_currentScenario == 3 && !_hybridDone) || _isRunning
                    ? null : _nextScenario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4AA),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                child: Text(
                  _currentScenario < 3 ? 'Следующий сценарий ➔' : '✅ Завершить демо',
                  style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 🟦 СЦЕНАРИЙ 1: ИИ
  Widget _buildAiScenario() {
    return Column(children: [
      AnimatedOpacity(opacity: _aiPost ? 1.0 : 0.0, duration: const Duration(milliseconds: 500),
        child: _buildRealisticPost(0)),
      const SizedBox(height: 20),
      if (_aiCheck) _buildLoader('🤖 ИИ анализирует утверждение...', size: 18),
      
      if (_aiVerdict)
        AnimatedOpacity(opacity: 1.0, duration: const Duration(milliseconds: 500),
          child: _buildAlert('❌ ИИ: Утверждение не подтверждается проверенными научными источниками', Colors.redAccent, fontSize: 18)),
      // 🔴 ИНДИКАТОР ВЕРДИКТА (копия из сценария 1, адаптированная)
      const SizedBox(height: 20),
      if (_aiDone)
        AnimatedOpacity(opacity: 1.0, duration: const Duration(milliseconds: 400),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) {
            final isLit = i == 0; // 🔴 Красный - крайний слева
            return Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: AnimatedContainer(duration: const Duration(milliseconds: 500),
              width: isLit ? 56.0 : 40.0, height: isLit ? 56.0 : 40.0,
              decoration: BoxDecoration(color: isLit ? Colors.redAccent : Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: isLit ? Colors.redAccent.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1), blurRadius: 12)])));
          }))),
    ]);
  }

  // 🟦 СЦЕНАРИЙ 2: Перекрёстная
  Widget _buildCrossScenario() {
    return Column(children: [
      AnimatedOpacity(opacity: _crossMsg ? 1.0 : 0.0, duration: const Duration(milliseconds: 500),
        child: _buildRealisticPost(1)),
      const SizedBox(height: 20),
      if (_crossMsg)
        AnimatedOpacity(opacity: 1.0, duration: const Duration(milliseconds: 400),
          child: _buildCard('👤 Ваша роль эксперта', 'Вы независимый эксперт нашей соцсети с высоким «рейтингом правды» (95/100). Ваше мнение влияет на формирование консенсуса.', fontSize: 18)),
      const SizedBox(height: 20),
      if (_crossMsg || _crossLoading || _crossVoted)
        Column(children: [
          Row(children: [SizedBox(width: 28, height: 28, child: CircularProgressIndicator(value: _crossCount/100, strokeWidth: 3, color: _crossCount >= 70 ? const Color(0xFF00D4AA) : Colors.amber)), const SizedBox(width: 16), Text('$_crossCount / 100 подтверждений', style: TextStyle(color: _crossCount >= 70 ? const Color(0xFF00D4AA) : Colors.amber, fontSize: 22, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: _crossCount/100, minHeight: 12, backgroundColor: Colors.grey[800], valueColor: AlwaysStoppedAnimation<Color>(_crossCount >= 70 ? const Color(0xFF00D4AA) : Colors.amber))),
        ]),
      if (!_crossLoading && _crossDone && !_crossVoted)
        Padding(padding: const EdgeInsets.only(top: 20), child: ElevatedButton(onPressed: _castCrossVote, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('✅ Я подтверждаю этот факт', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)))),
      if (_crossVerdict)
        AnimatedOpacity(opacity: 1.0, duration: const Duration(milliseconds: 500),
          child: _buildAlert('🛡️ Консенсус достигнут! Факт верифицирован сообществом независимых экспертов', const Color(0xFF00D4AA), fontSize: 18)),
      // 🟢 ИНДИКАТОР ВЕРДИКТА (копия из сценария 1, адаптированная)
      const SizedBox(height: 20),
      if (_crossDone)
        AnimatedOpacity(opacity: 1.0, duration: const Duration(milliseconds: 400),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) {
            final isLit = i == 4; // 🟢 Зелёный - крайний справа
            return Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: AnimatedContainer(duration: const Duration(milliseconds: 500),
              width: isLit ? 56.0 : 40.0, height: isLit ? 56.0 : 40.0,
              decoration: BoxDecoration(color: isLit ? const Color(0xFF00D4AA) : Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: isLit ? const Color(0xFF00D4AA).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1), blurRadius: 12)])));
          }))),
    ]);
  }

  // 🟦 СЦЕНАРИЙ 3: Цепочка доверия
  Widget _buildTrustChainScenario() {
    return Column(children: [
      AnimatedOpacity(opacity: _trustNode1 ? 1.0 : 0.0, duration: const Duration(milliseconds: 500),
        child: _buildRealisticPost(2)),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _buildTrustNode('Вы\n(эксперт)', _trustNode1, Colors.blueAccent, fontSize: 14),
        _buildTrustLine(_trustNode1 && _trustNode2),
        _buildTrustNode('Петя\n(рейтинг 99)', _trustNode2, Colors.amber, fontSize: 14),
        _buildTrustLine(_trustNode2 && _trustNode3),
        _buildTrustNode('Источник\nинформации', _trustNode3, const Color(0xFF00D4AA), fontSize: 14),
      ]),
      const SizedBox(height: 24),
      if (_trustNode1) AnimatedOpacity(opacity: 1.0, duration: const Duration(milliseconds: 400), child: _buildInfo('✓ Вы доверяете Пете как эксперту с рейтингом 99/100', fontSize: 18)),
      if (_trustNode2) AnimatedOpacity(opacity: 1.0, duration: const Duration(milliseconds: 400), child: _buildInfo('✓ Петя проверил источник и подтвердил достоверность факта', fontSize: 18)),
      if (_trustVerdict)
        AnimatedOpacity(opacity: 1.0, duration: const Duration(milliseconds: 500),
          child: _buildAlert('🔗 Доверие передано по цепочке. Информация признана достоверной', const Color(0xFF00D4AA), fontSize: 18)),
      // 🟢 ИНДИКАТОР ВЕРДИКТА (копия из сценария 1, адаптированная)
      const SizedBox(height: 20),
      if (_trustDone)
        AnimatedOpacity(opacity: 1.0, duration: const Duration(milliseconds: 400),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) {
            final isLit = i == 4; // 🟢 Зелёный - крайний справа
            return Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: AnimatedContainer(duration: const Duration(milliseconds: 500),
              width: isLit ? 56.0 : 40.0, height: isLit ? 56.0 : 40.0,
              decoration: BoxDecoration(color: isLit ? const Color(0xFF00D4AA) : Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: isLit ? const Color(0xFF00D4AA).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1), blurRadius: 12)])));
          }))),
    ]);
  }

  // 🟦 СЦЕНАРИЙ 4: Гибрид
  Widget _buildHybridScenario() {
    return Column(children: [
      AnimatedOpacity(opacity: _aiPost ? 1.0 : 0.0, duration: const Duration(milliseconds: 500),
        child: _buildRealisticPost(3)),
      const SizedBox(height: 20),
      if (_aiCheck) _buildLoader('🤖 ИИ проводит предварительный анализ...', size: 18),
      if (_aiVerdict) _buildInfo('⚠️ ИИ флаг: требуется дополнительная проверка сообществом', fontSize: 16),
      if (_crossMsg) _buildInfo('👥 Запуск перекрёстной верификации...', fontSize: 16),
      if (_crossCount > 0) _buildProgressMini(_crossCount),
      if (_trustNode1) _buildInfo('🔗 Подтверждение через цепочку доверия', fontSize: 16),
      if (_hybridDone)
        AnimatedOpacity(opacity: 1.0, duration: const Duration(milliseconds: 600),
          child: Container(margin: const EdgeInsets.only(top: 20), padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF00D4AA).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF00D4AA), width: 2)),
            child: const Column(children: [
              Icon(Icons.shield_rounded, color: Color(0xFF00D4AA), size: 64),
              SizedBox(height: 16),
              Text('✅ Гибридная верификация завершена', style: TextStyle(color: Color(0xFF00D4AA), fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('ИИ + Сообщество + Цепочка доверия', style: TextStyle(color: Colors.white70, fontSize: 18)),
              SizedBox(height: 6),
              Text('= 99.2% точность', style: TextStyle(color: Color(0xFF00D4AA), fontSize: 20, fontWeight: FontWeight.bold)),
            ]))),
      // 🟢 ИНДИКАТОР ВЕРДИКТА (копия из сценария 1, адаптированная)
      const SizedBox(height: 20),
      if (_hybridDone)
        AnimatedOpacity(opacity: 1.0, duration: const Duration(milliseconds: 400),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) {
            final isLit = i == 4; // 🟢 Зелёный - крайний справа
            return Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: AnimatedContainer(duration: const Duration(milliseconds: 500),
              width: isLit ? 56.0 : 40.0, height: isLit ? 56.0 : 40.0,
              decoration: BoxDecoration(color: isLit ? const Color(0xFF00D4AA) : Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: isLit ? const Color(0xFF00D4AA).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1), blurRadius: 12)])));
          }))),
    ]);
  }

  // 📱 РЕАЛИСТИЧНЫЙ ПОСТ (универсальный для всех сценариев)
  Widget _buildRealisticPost(int scenarioIndex) {
    final post = _posts[scenarioIndex];
    return Container(
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Шапка поста
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(backgroundColor: Color(0xFF00D4AA), radius: 28, child: Icon(Icons.newspaper, color: Colors.black, size: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(post['author']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(width: 8),
                        const Icon(Icons.verified, color: Color(0xFF00D4AA), size: 20),
                      ]),
                      Text(post['time']!, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.more_vert, color: Colors.grey), onPressed: () {}),
              ],
            ),
          ),
          // Текст поста
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                const SizedBox(height: 10),
                Text(
                  post['text']!,
                  style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Изображение
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[800], borderRadius: const BorderRadius.vertical(top: Radius.zero)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                post['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[850],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Изображение', style: TextStyle(color: Colors.grey, fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Метрики
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _buildMetric(Icons.favorite, post['likes']!, Colors.red),
                const SizedBox(width: 24),
                _buildMetric(Icons.chat_bubble_outline, post['comments']!, Colors.blue),
                const SizedBox(width: 24),
                _buildMetric(Icons.share, post['shares']!, Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🧩 Вспомогательные виджеты
  Widget _buildMetric(IconData icon, String count, Color color) => Row(children: [Icon(icon, color: color, size: 24), const SizedBox(width: 8), Text(count, style: TextStyle(color: Colors.grey[400], fontSize: 18, fontWeight: FontWeight.w600))]);
  Widget _buildCard(String title, String content, {double fontSize = 16}) => Container(margin: const EdgeInsets.symmetric(vertical: 8), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: Colors.grey[400], fontSize: fontSize - 2, fontWeight: FontWeight.w600)), const SizedBox(height: 8), Text(content, style: TextStyle(color: Colors.white, fontSize: fontSize, height: 1.5))]));
  Widget _buildLoader(String text, {double size = 16}) => Row(children: [SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3, color: const Color(0xFF00D4AA))), const SizedBox(width: 14), Text(text, style: TextStyle(color: Colors.grey[400], fontSize: size, fontStyle: FontStyle.italic))]);
  Widget _buildAlert(String text, Color color, {double fontSize = 16}) => Container(margin: const EdgeInsets.only(top: 16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.4), width: 2)), child: Text(text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w600, height: 1.4)));
  Widget _buildInfo(String text, {double fontSize = 16}) => Container(margin: const EdgeInsets.symmetric(vertical: 6), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.blue[900]?.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: Text(text, style: TextStyle(color: Colors.white70, fontSize: fontSize, height: 1.5, fontStyle: FontStyle.italic)));
  Widget _buildProgressMini(int count) => Column(children: [Row(children: [SizedBox(width: 24, height: 24, child: CircularProgressIndicator(value: count/100, strokeWidth: 3, color: const Color(0xFF00D4AA))), const SizedBox(width: 12), Text('$count/100', style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 20, fontWeight: FontWeight.bold))]), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: count/100, minHeight: 10, backgroundColor: Colors.grey[800], valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D4AA))))]);
  Widget _buildTrustNode(String label, bool active, Color color, {double fontSize = 12}) => AnimatedContainer(duration: const Duration(milliseconds: 500), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: active ? color.withValues(alpha: 0.3) : Colors.grey[900], borderRadius: BorderRadius.circular(12), border: Border.all(color: active ? color : Colors.grey[700]!, width: 3)), child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: active ? color : Colors.grey[400], fontSize: fontSize, fontWeight: FontWeight.bold)));
  Widget _buildTrustLine(bool active) => AnimatedContainer(duration: const Duration(milliseconds: 500), width: 50, height: 4, margin: const EdgeInsets.symmetric(horizontal: 6), color: active ? const Color(0xFF00D4AA) : Colors.grey[800]);
}