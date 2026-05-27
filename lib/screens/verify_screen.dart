import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

import '../models/verification_result.dart';
import '../services/ai_service.dart';
import '../services/history_service.dart';
import '../widgets/verification_indicator.dart';
import 'history_screen.dart';
import '../simulation_screen.dart';           // <-- Старая симуляция
import '../advanced_simulation_screen.dart'; // <-- Новая соцсеть

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  // 🎨 Брендовые цвета
  static const Color accent = Color(0xFF00D4AA);
  static const Color bg = Color(0xFF0F1115);
  static const Color cardBg = Color(0xFF1C1F26);

  // 📏 Шрифты
  static const double kFontSizeSmall = 14.0;
  static const double kFontSizeMedium = 18.0;
  static const double kFontSizeLarge = 22.0;
  static const String kFontFamily = 'Roboto';

  String _inputMode = 'text';
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  VerificationResult? _result;
  bool _isProcessing = false;
  bool _isSearchingWeb = false;

  @override
  void initState() { super.initState(); _initSpeech(); }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (error) => debugPrint('🎤 Ошибка микрофона: $error'),
      onStatus: (status) => debugPrint('🎤 Статус: $status'),
    );
    if (mounted) setState(() {});
  }

  void _toggleMic() {
    if (!_speechAvailable) return;
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    } else {
      _speech.listen(onResult: (r) => setState(() => _controller.text = r.recognizedWords), localeId: 'ru_RU');
      setState(() => _isListening = true);
    }
  }

  Future<void> _verify() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    if (AiService.yandexApiKey.isEmpty) {
      _showError('⚠️ API ключ не установлен в .env');
      return;
    }

    setState(() {
      _isSearchingWeb = true;
      _isProcessing = true;
      _result = null;
    });

    try {
      final result = await AiService.checkStatement(text, type: _inputMode);
      if (mounted) {
        setState(() {
          _result = result;
          _isSearchingWeb = false;
          _isProcessing = false;
        });
        HistoryService.saveVerification(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = VerificationResult(
            statement: text,
            status: VerificationStatus.unclear,
            explanation: 'Ошибка: ${e.toString().replaceAll('Exception: ', '')}',
            sources: [],
          );
          _isSearchingWeb = false;
          _isProcessing = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }

  void _resetScreen() {
    setState(() {
      _result = null;
      _controller.clear();
      _isProcessing = false;
      _isSearchingWeb = false;
      _isListening = false;
    });
    _speech.stop();
  }

  @override
  void dispose() { _controller.dispose(); _speech.stop(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('TrueReality', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          // 📜 КНОПКА ИСТОРИЯ
          _buildNavButton('История', Icons.history, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
          const SizedBox(width: 8),
          //  КНОПКА СИМУЛЯЦИЯ (Старая)
          _buildNavButton('Симуляция', Icons.auto_awesome, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SimulationScreen()))),
          const SizedBox(width: 8),
          // 🌐 КНОПКА СОЦСЕТЬ (Новая)
          _buildNavButton('Соцсеть', Icons.group, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvancedSimulationScreen()))),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🎛️ Переключатель режима ввода
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Expanded(child: _buildTab('text', 'Текст', Icons.edit)),
                    Expanded(child: _buildTab('voice', 'Голос', Icons.mic)),
                    Expanded(child: _buildTab('url', 'Ссылка', Icons.link)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (_inputMode == 'text') _buildField('Введите утверждение для проверки...', Icons.edit_outlined, 4),
              if (_inputMode == 'voice') ...[
                _buildField('Скажите утверждение или нажмите на микрофон...', Icons.mic_none, 4),
                const SizedBox(height: 12),
                _buildMicButton(),
              ],
              if (_inputMode == 'url') _buildField('Вставьте ссылку на статью...', Icons.link, 1, keyboardType: TextInputType.url),

              const SizedBox(height: 24),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isProcessing || _controller.text.trim().isEmpty) ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    disabledBackgroundColor: accent.withOpacity(0.3),
                  ),
                  child: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                      : Text('ПРОВЕРИТЬ', style: TextStyle(fontSize: kFontSizeLarge, fontWeight: FontWeight.bold, fontFamily: kFontFamily)),
                ),
              ),

              const SizedBox(height: 20),

              if (_isSearchingWeb) _buildStatus('🔍 Ищем информацию в сети...', accent),
              if (_isProcessing && !_isSearchingWeb) _buildStatus(' Анализирую данные...', accent),

              if (_result != null) ...[
                _buildResultCard(),
                const SizedBox(height: 16),
                _buildResetButton(),
              ],

              if (_result == null && !_isProcessing) ...[
                const SizedBox(height: 12),
                Text('Попробуйте проверить:', style: TextStyle(color: Colors.white54, fontSize: kFontSizeSmall)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _buildChip('Курс доллара 100 рублей'),
                    _buildChip('Земля плоская'),
                    _buildChip('Кофеин продлевает жизнь'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 🔘 Единый стиль кнопок в AppBar
  Widget _buildNavButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  Widget _buildTab(String mode, String label, IconData icon) {
    final isActive = _inputMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _inputMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? accent : Colors.transparent),
        ),
        child: Column(children: [
          Icon(icon, color: isActive ? accent : Colors.white54, size: 20),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontSize: kFontSizeSmall)),
        ]),
      ),
    );
  }

  Widget _buildField(String hint, IconData icon, int maxLines, {TextInputType? keyboardType}) {
    return TextField(
      controller: _controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white, fontSize: kFontSizeMedium, fontFamily: kFontFamily),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white38, fontSize: kFontSizeMedium, fontFamily: kFontFamily),
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        prefixIcon: Icon(icon, color: accent),
      ),
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) => !_isProcessing ? _verify() : null,
    );
  }

  Widget _buildMicButton() {
    return Center(
      child: GestureDetector(
        onTap: _toggleMic,
        child: Container(
          width: 72, height: 72,
          decoration: BoxDecoration(shape: BoxShape.circle, color: _isListening ? Colors.redAccent : accent),
          child: Icon(_isListening ? Icons.mic_off : Icons.mic, color: Colors.black, size: 32),
        ),
      ),
    );
  }

  Widget _buildStatus(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(text, style: TextStyle(color: color, fontSize: kFontSizeMedium, fontFamily: kFontFamily)),
    );
  }

  Widget _buildResultCard() {
    final r = _result!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: r.statusColor.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          VerificationIndicator(result: r, size: 36),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.statusLabel.toUpperCase(), style: TextStyle(color: r.statusColor, fontWeight: FontWeight.bold, fontSize: kFontSizeMedium, fontFamily: kFontFamily)),
            Text(r.statusDescription, style: TextStyle(color: Colors.white54, fontSize: kFontSizeSmall, fontFamily: kFontFamily)),
          ])),
        ]),
        const Divider(height: 24, color: Colors.white10),
        Text(r.explanation ?? '', style: TextStyle(color: Colors.white, fontSize: kFontSizeMedium, height: 1.4, fontFamily: kFontFamily)),
        if (r.sources.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('ИСТОЧНИКИ:', style: TextStyle(color: Colors.white38, fontSize: kFontSizeSmall, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...r.sources.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () => _launchUrl(s),
              child: Row(children: [
                const Icon(Icons.link, size: 14, color: accent),
                const SizedBox(width: 8),
                Expanded(child: Text(s, style: TextStyle(color: accent, fontSize: kFontSizeSmall, decoration: TextDecoration.underline, fontFamily: kFontFamily), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ),
          )),
        ],
      ]),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity, height: 48,
      child: OutlinedButton.icon(
        onPressed: _resetScreen,
        icon: const Icon(Icons.refresh, size: 20),
        label: Text('Сбросить', style: TextStyle(fontSize: kFontSizeMedium, fontFamily: kFontFamily)),
        style: OutlinedButton.styleFrom(foregroundColor: accent, side: const BorderSide(color: accent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Widget _buildChip(String text) {
    return ActionChip(
      label: Text(text, style: TextStyle(color: Colors.white, fontSize: kFontSizeSmall, fontFamily: kFontFamily)),
      backgroundColor: cardBg,
      side: const BorderSide(color: accent),
      onPressed: () { _controller.text = text; setState(() {}); },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}