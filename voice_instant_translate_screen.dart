// lib/voice_instant_translate_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceInstantTranslateScreen extends StatefulWidget {
  const VoiceInstantTranslateScreen({Key? key}) : super(key: key);

  @override
  State<VoiceInstantTranslateScreen> createState() => _VoiceInstantTranslateScreenState();
}

class _VoiceInstantTranslateScreenState extends State<VoiceInstantTranslateScreen>
    with TickerProviderStateMixin {
  // Services
  final stt.SpeechToText _speech = stt.SpeechToText();
  final GoogleTranslator _translator = GoogleTranslator();
  final FlutterTts _tts = FlutterTts();

  bool _speechAvailable = false;
  bool _isListeningLeft = false;  // English side
  bool _isListeningRight = false; // Hindi side

  // animations
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(begin: 0.0, end: 24.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseController.repeat(reverse: true);
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize();
      setState(() {
        _speechAvailable = available;
      });
    } catch (_) {
      setState(() => _speechAvailable = false);
    }
  }

  Future<void> _initTts() async {
    try {
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  @override
  void dispose() {
    _pulseController.dispose();
    try {
      _speech.stop();
    } catch (_) {}
    try {
      _tts.stop();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _startListening({required bool left}) async {
    if (!_speechAvailable) {
      await _initSpeech();
      if (!_speechAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition unavailable on this device')),
        );
        return;
      }
    }

    if (left && _isListeningLeft) return;
    if (!left && _isListeningRight) return;

    // stop other side
    if (left && _isListeningRight) await _stopListening(left: false);
    if (!left && _isListeningLeft) await _stopListening(left: true);

    setState(() {
      if (left) _isListeningLeft = true;
      else _isListeningRight = true;
    });

    // left side = English -> translate to Hindi
    // right side = Hindi -> translate to English
    final sourceLocale = left ? 'en-US' : 'hi-IN';
    final targetCode = left ? 'hi' : 'en';
    final ttsLocale = left ? 'hi-IN' : 'en-US';

    try {
      await _speech.listen(
        localeId: sourceLocale,
        listenFor: const Duration(seconds: 12),
        pauseFor: const Duration(seconds: 3),
        partialResults: false,
        onResult: (val) async {
          if (val.finalResult && val.recognizedWords.isNotEmpty) {
            final spoken = val.recognizedWords.trim();

            // translate
            String translated = '';
            try {
              final translation = await _translator.translate(spoken, to: targetCode);
              translated = translation.text;
            } catch (_) {
              translated = '[translation error]';
            }

            // speak translation
            try {
              await _tts.setLanguage(ttsLocale);
              await _tts.speak(translated);
            } catch (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('TTS failed, check voice install')),
              );
            }

            // stop listening after result
            await _speech.stop();
            setState(() {
              if (left) _isListeningLeft = false;
              else _isListeningRight = false;
            });
          }
        },
      );
    } catch (_) {
      setState(() {
        if (left) _isListeningLeft = false;
        else _isListeningRight = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to start listening')),
      );
    }
  }

  Future<void> _stopListening({required bool left}) async {
    try {
      await _speech.stop();
    } catch (_) {}
    setState(() {
      if (left) _isListeningLeft = false;
      else _isListeningRight = false;
    });
  }

  Future<void> _stopAll() async {
    try {
      await _speech.stop();
    } catch (_) {}
    try {
      await _tts.stop();
    } catch (_) {}
    setState(() {
      _isListeningLeft = false;
      _isListeningRight = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stopped')),
    );
  }

  Widget _micWidget({required bool left, required String label}) {
    final listening = left ? _isListeningLeft : _isListeningRight;
    return Column(
      children: [
        GestureDetector(
          onTap: () =>
          listening ? _stopListening(left: left) : _startListening(left: left),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (listening)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) {
                    final size = 90.0 + _pulseAnim.value;
                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    );
                  },
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: listening ? 108 : 88,
                height: listening ? 108 : 88,
                decoration: BoxDecoration(
                  gradient: listening
                      ? const LinearGradient(colors: [Color(0xFFFFA726), Color(0xFFFF7043)])
                      : const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF1F1F1)]),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 6)),
                  ],
                ),
                child: Icon(
                  listening ? Icons.mic : Icons.mic_none,
                  size: 40,
                  color: listening ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
                color: Colors.white70, fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF0B486B), Color(0xFF3B8686)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Instant Voice Translate',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 6),
              const Text(
                '🎤 Speak in English → Hear in Hindi\n🎤 Speak in Hindi → Hear in English',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _micWidget(left: true, label: "🇺🇸 English"),
                  Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _stopAll,
                        icon: const Icon(Icons.stop_circle, color: Colors.white),
                        label: const Text('Stop All',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: const [
                            Text('Instant',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.translate,
                                    color: Colors.white70, size: 16),
                                SizedBox(width: 6),
                                Text("English ↔ Hindi",
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _micWidget(left: false, label: "🇮🇳 Hindi"),
                ],
              ),
              const Spacer(),
              const Text(
                'Tip: Use short phrases for best results.\nMake sure Hindi + English voices are installed in device settings.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
