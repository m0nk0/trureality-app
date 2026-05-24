import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/verification_result.dart';
import '../services/ai_service.dart';
import '../simulation_screen.dart'; // или '../screens/simulation_screen.dart', если файл в другой папке
import '../cross_verification_simulation.dart'; 

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  // 🎛️ Режим ввода: 'text', 'voice' или 'url'
  String _inputMode = 'text';
  
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  VerificationResult? _result;
  bool _isChecking = false;

  // Твой кастомный серый
  final Color customGrey = const Color.fromRGBO(189, 189, 189, 1);

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (error) => debugPrint('🎤 Ошибка микрофона: $error'),
      onStatus: (status) => debugPrint('🎤 Статус: $status'),
    );
    if (mounted) setState(() {});
  }

  void _startListening() async {
    if (!_speechAvailable) return;
    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _textController.text = result.recognizedWords;
          });
        }
      },
      localeId: 'ru_RU',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 2),
    );
    setState(() => _isListening = true);
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _checkStatement() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    if (AiService.apiKey == "YOUR_API_KEY_HERE") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Вставьте API ключ в ai_service.dart')),
      );
      return;
    }

    setState(() {
      _isChecking = true;
      _result = null;
    });

    try {
      final result = await AiService.checkStatement(text);
      if (mounted) {
        setState(() {
          _result = result;
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = VerificationResult(
            statement: text,
            status: VerificationStatus.pending,
            explanation: 'Ошибка соединения: $e',
          );
          _isChecking = false;
        });
      }
    }
  }

  void _resetScreen() {
    setState(() {
      _result = null;
      _textController.clear();
      _isChecking = false;
      _isListening = false;
    });
    _speech.stop();
  }

  @override
  void dispose() {
    _textController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
  title: const Text('TrueTalk: Проверка фактов'),
  backgroundColor: const Color(0xFF0F1115),
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () => Navigator.pop(context),
  ),
  actions: [
    // 🔲 Кнопка 1: "Симуляция ИИ"
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SimulationScreen()),
        );
      },
      child: Container(
        width: 130, // Чуть уже, чтобы две кнопки влезли
        height: 40,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF00D4AA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.auto_awesome, color: Colors.black, size: 16),
            SizedBox(width: 4),
            Text(
              'Симуляция ИИ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
    
    // 🔲 Кнопка 2: "Симуляция ПВ" (Перекрёстная верификация)
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CrossVerificationSimulation()),
        );
      },
      child: Container(
        width: 130,
        height: 40,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF00D4AA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.groups, color: Colors.black, size: 16),
            SizedBox(width: 4),
            Text(
              'Симуляция ПВ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  ],
),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🎛️ Переключатель режима ввода (3 кнопки)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildModeTab('text', 'Текст', Icons.edit, _inputMode == 'text'),
                    ),
                    Expanded(
                      child: _buildModeTab('voice', 'Голос', Icons.mic, _inputMode == 'voice'),
                    ),
                    Expanded(
                      child: _buildModeTab('url', 'Ссылка', Icons.link, _inputMode == 'url'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 📝 Поле ввода: Текст
              if (_inputMode == 'text')
                TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Введите утверждение...',
                    hintStyle: TextStyle(color: customGrey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.edit_outlined, color: Color(0xFF00D4AA)),
                  ),
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                ),

              // 📝 Поле ввода: Голос
              if (_inputMode == 'voice')
                Column(
                  children: [
                    TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Нажмите на микрофон и говорите...',
                        hintStyle: TextStyle(color: customGrey),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.mic_none, color: Color(0xFF00D4AA)),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _isListening ? _stopListening : _startListening,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening ? Colors.redAccent : const Color(0xFF00D4AA),
                          boxShadow: _isListening
                              ? [
                                  BoxShadow(
                                    color: Colors.redAccent.withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: Icon(
                          _isListening ? Icons.mic_off : Icons.mic,
                          color: Colors.black,
                          size: 36,
                        ),
                      ),
                    ),
                    if (_isListening)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'Слушаю...',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),

              // 🔗 Поле ввода: Ссылка
              if (_inputMode == 'url')
                TextField(
                  controller: _textController,
                  keyboardType: TextInputType.url,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'https://...',
                    hintStyle: TextStyle(color: customGrey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.link, color: Color(0xFF00D4AA)),
                    suffixIcon: _textController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () => _textController.clear(),
                          )
                        : null,
                  ),
                  maxLines: 1,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _isChecking ? null : _checkStatement(),
                ),

              const SizedBox(height: 24),

              // 🔘 Кнопка проверки
              ElevatedButton(
                onPressed: _isChecking ? null : _checkStatement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4AA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isChecking
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : const Text(
                        'Проверить',
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),

              const SizedBox(height: 24),

              // 📊 Результат
              if (_result != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _result!.statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12, height: 12,
                            decoration: BoxDecoration(
                              color: _result!.statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _result!.statusLabel,
                              style: TextStyle(
                                color: _result!.statusColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_result!.explanation != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _result!.explanation!,
                          style: const TextStyle(color: Color.fromRGBO(189, 189, 189, 1), fontSize: 14, height: 1.4),
                        ),
                      ],
                      if (_result!.sources.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text('Источники:', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                        ..._result!.sources.map((s) => Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.link, size: 14, color: Color(0xFF00D4AA)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(s, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),

              if (_result == null) ...[
                const SizedBox(height: 8),
                Text(
                  'Попробуйте ввести или сказать:',
                  style: TextStyle(color: customGrey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ExampleChip('Земля плоская', _textController),
                    _ExampleChip('Вода кипит при 100°C', _textController),
                    _ExampleChip('https://ru.wikipedia.org/wiki/Кофе', _textController),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeTab(String mode, String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _inputMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00D4AA) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.black : customGrey, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : customGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleChip extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  const _ExampleChip(this.text, this.controller);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: Colors.grey[850],
      side: const BorderSide(color: Color(0xFF00D4AA), width: 0.5),
      onPressed: () {
        controller.text = text;
      },
    );
  }
}