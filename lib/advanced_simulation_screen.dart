import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// 🎨 Фиксированные цвета для 5 позиций
const Color _c0 = Color(0xFFFF4444); // 🔴 Красный
const Color _c1 = Color(0xFFAA44FF); // 🟣 Фиолетовый
const Color _c2 = Color(0xFFFFBB33); // 🟡 Желтый
const Color _c3 = Colors.white60;    // ⚪ Белый
const Color _c4 = Color(0xFF00D4AA); // 🟢 Зеленый
const List<Color> _circleColors = [_c0, _c1, _c2, _c3, _c4];

const Color _bg = Color(0xFF0F1115);
const Color _card = Color(0xFF212731);

class AdvancedSimulationScreen extends StatefulWidget {
  const AdvancedSimulationScreen({super.key});

  @override
  State<AdvancedSimulationScreen> createState() => _AdvancedSimulationScreenState();
}

class _AdvancedSimulationScreenState extends State<AdvancedSimulationScreen> {
  final _engine = FeedSimulationEngine();
  bool _isPlaying = true;
  double _speed = 1.0;
  Timer? _timer;

  @override
  void initState() { super.initState(); _startLoop(); }

  void _startLoop() {
    // Спокойный темп: 1 тик = 1 секунда
    _timer = Timer.periodic(Duration(milliseconds: (1000 / _speed).round()), (_) {
      if (_isPlaying && mounted) setState(() => _engine.tick());
    });
  }

  void _togglePause() => setState(() => _isPlaying = !_isPlaying);
  void _changeSpeed() => setState(() => _speed = _speed >= 4.0 ? 1.0 : _speed + 1.0);

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('🌐 Verification Cycles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          TextButton(onPressed: _changeSpeed, child: Text('x${_speed.toStringAsFixed(1)}', style: TextStyle(color: _c4, fontWeight: FontWeight.bold))),
          IconButton(icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow), onPressed: _togglePause),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _engine.posts.length,
        itemBuilder: (ctx, i) => TelegramPostCard(post: _engine.posts[i]),
      ),
    );
  }
}

// 📦 Карточка поста (Telegram Style)
class TelegramPostCard extends StatelessWidget {
  final FeedPost post;
  const TelegramPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    // Цвет текста зависит от того, какой кружок стал финальным
    final finalColor = _circleColors[post.winningIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Шапка канала
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(children: [
              CircleAvatar(radius: 18, backgroundColor: post.avatarColor, child: Text(post.channel[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(post.channel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(post.category, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ])),
            ]),
          ),
          
          // Изображение
          if (post.imageUrl != null)
            ClipRRect(
              child: Image.asset(
                post.imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(height: 100, color: Colors.black26, child: const Center(child: Text('Image', style: TextStyle(color: Colors.white54)))),
              ),
            ),

          // Текст поста
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(post.content, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),
          ),

          // 5 Кружков (по центру)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => _buildCircle(post.circles[index])),
            ),
          ),
          
          // Результат (появляется только после анимации)
          AnimatedOpacity(
            opacity: post.isFinished ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      '✅ VERIFICATION COMPLETE',
                      style: TextStyle(color: finalColor, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        post.verificationMethod,
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ⏱️ Просмотры и время (всегда внизу)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                const Icon(Icons.visibility, size: 12, color: Colors.white38),
                const SizedBox(width: 4),
                Text('${post.views} views • ${_timeAgo(post.timestamp)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(CircleState circle) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: circle.isFinal ? 28 : 14,
      height: circle.isFinal ? 28 : 14,
      decoration: BoxDecoration(
        color: circle.isFinal ? circle.color : Colors.white.withOpacity(0.15),
        border: Border.all(color: circle.isFinal ? circle.color : Colors.white30, width: 2),
        shape: BoxShape.circle,
        boxShadow: circle.isFinal ? [
          BoxShadow(color: circle.color.withOpacity(0.6), blurRadius: 12, spreadRadius: 2),
        ] : [],
      ),
      child: circle.isFinal 
          ? const Icon(Icons.check, size: 16, color: Colors.white) 
          : null,
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

// 🧠 Модели
class CircleState {
  final int index;
  final Color color;
  bool isFinal = false; // Станет true только для победившего кружка

  CircleState({required this.index, required this.color});
}

class FeedPost {
  final String id;
  final String channel;
  final String category;
  final String content;
  final String? imageUrl;
  final Color avatarColor;
  final DateTime timestamp;
  
  final List<CircleState> circles;
  final int winningIndex; // Индекс кружка, который станет цветным (0-4)
  final String verificationMethod;
  
  bool isFinished = false;
  int ticksAlive = 0;
  int views = 0;

  FeedPost({
    required this.id, required this.channel, required this.category, required this.content,
    this.imageUrl, required this.avatarColor, 
    required this.circles, required this.winningIndex, required this.verificationMethod, DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  void tick() {
    ticksAlive++;
    views += Random().nextInt(25); // Плавный рост просмотров
    
    // Через 4 секунды запускаем финальную анимацию
    if (!isFinished && ticksAlive >= 4) {
      isFinished = true;
      circles[winningIndex].isFinal = true; // Один кружок становится большим и цветным
    }
  }
}

// ⚙️ Движок
class FeedSimulationEngine {
  final Random _rnd = Random();
  final List<FeedPost> posts = [];
  
  final List<String> _images = [
    'assets/images/sim_1.jpg', 'assets/images/sim_2.jpg', 'assets/images/sim_3.jpg',
    'assets/images/sim_4.jpg', 'assets/images/sim_5.jpg',
  ];
  final List<String> _channels = ['@MarketWatch', '@ScienceDaily', '@TechCrunch', '@Reuters', '@FutureAI'];
  final List<String> _categories = ['Finance', 'Science', 'Tech', 'News', 'AI'];
  final List<String> _contents = [
    ' BREAKING: Bitcoin crashes below \$50k amid regulatory concerns. Analysts predict further volatility...',
    '✅ New study confirms coffee reduces risk of heart disease by 15%. Research over 10 years shows...',
    ' SpaceX successfully launches 60 Starlink satellites today. Mission marks the 15th launch...',
    '🏛 Parliament votes to increase digital privacy regulations. New law requires explicit consent...',
    ' Google DeepMind announces breakthrough in protein folding. AI predicts structures with 95% accuracy...',
  ];
  final List<String> _methods = [
    'AI Verification', 
    'AI + Expert Panel', 
    'Cross-Source Check', 
    'Crowd Consensus', 
    'Hybrid Analysis',
    'Blockchain Audit'
  ];

  FeedSimulationEngine() {
    for (int i = 0; i < 5; i++) _spawnPost(i);
  }

  void tick() {
    for (final post in posts) {
      post.tick();
    }
    
    // Удаляем старые посты и добавляем новые
    posts.removeWhere((p) => p.ticksAlive > 22);
    if (posts.length < 5) {
      final idx = _rnd.nextInt(5);
      _spawnPost(idx);
    }
  }

  void _spawnPost(int index) {
    // Случайный победитель (0-4)
    final winner = _rnd.nextInt(5);
    
    // Создаем 5 кружков. Только один станет финальным
    List<CircleState> circles = List.generate(5, (i) => 
      CircleState(index: i, color: _circleColors[i])
    );

    posts.insert(0, FeedPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      channel: _channels[index],
      category: _categories[index],
      content: _contents[index],
      imageUrl: _images[index],
      avatarColor: Colors.primaries[_rnd.nextInt(Colors.primaries.length)],
      circles: circles,
      winningIndex: winner,
      verificationMethod: _methods[_rnd.nextInt(_methods.length)],
    ));
  }
}