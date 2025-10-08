// lib/conversation_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:flutter/services.dart';

enum _Who { left, right }

class _ConvEntry {
  final _Who who;
  final String original;
  final String detectedLangCode;
  final String detectedLangDisplay;
  final String translated;
  final DateTime timestamp;

  _ConvEntry({
    required this.who,
    required this.original,
    required this.detectedLangCode,
    required this.detectedLangDisplay,
    required this.translated,
    required this.timestamp,
  });
}

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({Key? key}) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with TickerProviderStateMixin {
  // Services
  final stt.SpeechToText _speech = stt.SpeechToText();
  final GoogleTranslator _translator = GoogleTranslator();
  final FlutterTts _tts = FlutterTts();
  late final LanguageIdentifier _languageIdentifier;

  // Device locales
  List<stt.LocaleName> _availableLocales = [];

  // STT/TTS state
  bool _speechAvailable = false;
  bool _isListeningLeft = false;
  bool _isListeningRight = false;

  // live partial text preview
  String _currentLeftTranscription = '';
  String _currentRightTranscription = '';

  // conversation history
  final List<_ConvEntry> _history = [];

  // languages mapping (same as before)
  final Map<String, String> _languagesMap = {
    '🇿🇦 Afrikaans': 'af',
    '🇦🇱 Albanian': 'sq',
    '🇪🇹 Amharic': 'am',
    '🇸🇦 Arabic': 'ar',
    '🇦🇲 Armenian': 'hy',
    '🇦🇿 Azerbaijani': 'az',
    '🇪🇸 Basque': 'eu',
    '🇧🇾 Belarusian': 'be',
    '🇮🇳 Bengali': 'bn',
    '🇧🇦 Bosnian': 'bs',
    '🇧🇬 Bulgarian': 'bg',
    '🇪🇸 Catalan': 'ca',
    '🇵🇭 Cebuano': 'ceb',
    '🇨🇳 Chinese (Simplified)': 'zh-CN',
    '🇹🇼 Chinese (Traditional)': 'zh-TW',
    '🇫🇷 Corsican': 'co',
    '🇭🇷 Croatian': 'hr',
    '🇨🇿 Czech': 'cs',
    '🇩🇰 Danish': 'da',
    '🇳🇱 Dutch': 'nl',
    '🇺🇸 English': 'en',
    '🌐 Esperanto': 'eo',
    '🇪🇪 Estonian': 'et',
    '🇫🇮 Finnish': 'fi',
    '🇫🇷 French': 'fr',
    '🇳🇱 Frisian': 'fy',
    '🇪🇸 Galician': 'gl',
    '🇬🇪 Georgian': 'ka',
    '🇩🇪 German': 'de',
    '🇬🇷 Greek': 'el',
    '🇮🇳 Gujarati': 'gu',
    '🇭🇹 Haitian Creole': 'ht',
    '🇳🇬 Hausa': 'ha',
    '🇺🇸 Hawaiian': 'haw',
    '🇮🇱 Hebrew': 'iw',
    '🇮🇳 Hindi': 'hi',
    '🇨🇳 Hmong': 'hmn',
    '🇭🇺 Hungarian': 'hu',
    '🇮🇸 Icelandic': 'is',
    '🇳🇬 Igbo': 'ig',
    '🇮🇩 Indonesian': 'id',
    '🇮🇪 Irish': 'ga',
    '🇮🇹 Italian': 'it',
    '🇯🇵 Japanese': 'ja',
    '🇮🇩 Javanese': 'jw',
    '🇮🇳 Kannada': 'kn',
    '🇰🇿 Kazakh': 'kk',
    '🇰🇭 Khmer': 'km',
    '🇷🇼 Kinyarwanda': 'rw',
    '🇰🇷 Korean': 'ko',
    '🇮🇶 Kurdish': 'ku',
    '🇰🇬 Kyrgyz': 'ky',
    '🇱🇦 Lao': 'lo',
    '🏛️ Latin': 'la',
    '🇱🇻 Latvian': 'lv',
    '🇱🇹 Lithuanian': 'lt',
    '🇱🇺 Luxembourgish': 'lb',
    '🇲🇰 Macedonian': 'mk',
    '🇲🇬 Malagasy': 'mg',
    '🇲🇾 Malay': 'ms',
    '🇮🇳 Malayalam': 'ml',
    '🇲🇹 Maltese': 'mt',
    '🇳🇿 Maori': 'mi',
    '🇮🇳 Marathi': 'mr',
    '🇲🇳 Mongolian': 'mn',
    '🇲🇲 Myanmar (Burmese)': 'my',
    '🇳🇵 Nepali': 'ne',
    '🇳🇴 Norwegian': 'no',
    '🇲🇼 Nyanja (Chichewa)': 'ny',
    '🇮🇳 Odia (Oriya)': 'or',
    '🇦🇫 Pashto': 'ps',
    '🇮🇷 Persian': 'fa',
    '🇵🇱 Polish': 'pl',
    '🇵🇹 Portuguese': 'pt',
    '🇮🇳 Punjabi': 'pa',
    '🇷🇴 Romanian': 'ro',
    '🇷🇺 Russian': 'ru',
    '🇼🇸 Samoan': 'sm',
    '🏴 Scots Gaelic': 'gd',
    '🇷🇸 Serbian': 'sr',
    '🇱🇸 Sesotho': 'st',
    '🇿🇼 Shona': 'sn',
    '🇵🇰 Sindhi': 'sd',
    '🇱🇰 Sinhala (Sinhalese)': 'si',
    '🇸🇰 Slovak': 'sk',
    '🇸🇮 Slovenian': 'sl',
    '🇸🇴 Somali': 'so',
    '🇪🇸 Spanish': 'es',
    '🇮🇩 Sundanese': 'su',
    '🌍 Swahili': 'sw',
    '🇸🇪 Swedish': 'sv',
    '🇵🇭 Tagalog (Filipino)': 'tl',
    '🇹🇯 Tajik': 'tg',
    '🇮🇳 Tamil': 'ta',
    '🇷🇺 Tatar': 'tt',
    '🇮🇳 Telugu': 'te',
    '🇹🇭 Thai': 'th',
    '🇹🇷 Turkish': 'tr',
    '🇹🇲 Turkmen': 'tk',
    '🇺🇦 Ukrainian': 'uk',
    '🇵🇰 Urdu': 'ur',
    '🇨🇳 Uyghur': 'ug',
    '🇺🇿 Uzbek': 'uz',
    '🇻🇳 Vietnamese': 'vi',
    '🏴 Welsh': 'cy',
    '🇿🇦 Xhosa': 'xh',
    '🇮🇱 Yiddish': 'yi',
    '🇳🇬 Yoruba': 'yo',
    '🇿🇦 Zulu': 'zu',
  };

  // default displays
  late String _leftLangDisplay;
  late String _rightLangDisplay;

  // user-chosen recognition locale per side (from device locales)
  String? _leftRecognitionLocaleId;
  String? _rightRecognitionLocaleId;

  // controllers
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // animations
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

    _leftLangDisplay = _languagesMap.keys.firstWhere((k) => _languagesMap[k] == 'en',
        orElse: () => _languagesMap.keys.first);
    _rightLangDisplay = _languagesMap.keys.firstWhere((k) => _languagesMap[k] == 'hi',
        orElse: () => _languagesMap.keys.first);

    _initSpeech();
    _initTts();

    _pulseController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pulseAnim = Tween<double>(begin: 0.0, end: 20.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
    _pulseController.repeat(reverse: true);
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(onStatus: (s) {
        // optional status handling
      }, onError: (err) {});
      final locales = await _speech.locales();
      setState(() {
        _speechAvailable = available;
        _availableLocales = locales;
      });
    } catch (_) {
      setState(() => _speechAvailable = false);
    }
  }

  Future<void> _initTts() async {
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    _tts.stop();
    _languageIdentifier.close();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // helper: pick best available STT locale for a language code
  String? _bestLocaleForLangCode(String code) {
    try {
      final lower = code.toLowerCase();
      final match = _availableLocales.firstWhere(
              (l) => l.localeId.toLowerCase().startsWith(lower) || l.localeId.toLowerCase().contains(lower),
          orElse: () => stt.LocaleName('', ''));
      return match.localeId.isEmpty ? null : match.localeId;
    } catch (_) {
      return null;
    }
  }

  // NEW: UI action to pick recognition locale from device locales
  Future<void> _pickRecognitionLocale({required bool forLeft}) async {
    _searchController.clear();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final locales = _availableLocales;
        return DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.35,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(18))),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(width: 56, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search locale (eg: hi_IN, en_US)'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      children: locales
                          .where((l) {
                        final q = _searchController.text.toLowerCase();
                        if (q.isEmpty) return true;
                        return l.localeId.toLowerCase().contains(q) || l.name.toLowerCase().contains(q);
                      })
                          .map((l) => ListTile(
                        title: Text(l.name),
                        subtitle: Text(l.localeId),
                        onTap: () {
                          setState(() {
                            if (forLeft) _leftRecognitionLocaleId = l.localeId;
                            else _rightRecognitionLocaleId = l.localeId;
                          });
                          Navigator.pop(context);
                        },
                      ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (forLeft) _leftRecognitionLocaleId = null;
                          else _rightRecognitionLocaleId = null;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Use automatic / default locale'))
                ],
              ),
            );
          },
        );
      },
    );
  }

  // helper: listen once with specified locale and timeout, returning a transcription or empty string
  Future<String> _listenOnceWithLocale(String? localeId, {int timeoutSeconds = 6}) async {
    final completer = Completer<String>();
    String lastRecognized = '';

    // Ensure no other listen session is active
    try {
      await _speech.stop();
    } catch (_) {}

    // Create a timer to cancel if no final result by timeoutSeconds
    Timer? timeoutTimer;
    timeoutTimer = Timer(Duration(seconds: timeoutSeconds), () async {
      if (!completer.isCompleted) {
        try {
          await _speech.stop();
        } catch (_) {}
        completer.complete(lastRecognized);
      }
    });

    await _speech.listen(
      onResult: (val) {
        lastRecognized = val.recognizedWords;
        if (val.finalResult && !completer.isCompleted) {
          timeoutTimer?.cancel();
          completer.complete(lastRecognized);
        }
      },
      listenFor: Duration(seconds: timeoutSeconds + 2),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      localeId: localeId,
      onSoundLevelChange: (level) {},
    );

    final result = await completer.future;
    timeoutTimer?.cancel();
    // stop to clean up
    try {
      await _speech.stop();
    } catch (_) {}
    return result;
  }

  // NEW: attempt recognition using multiple candidate localeIds sequentially
  // Returns the first non-empty transcription found.
  Future<String> _attemptRecognitionWithLocales(List<String?> localeCandidates, {int perLocaleSec = 5}) async {
    for (final localeId in localeCandidates) {
      final txt = await _listenOnceWithLocale(localeId, timeoutSeconds: perLocaleSec);
      if (txt.trim().isNotEmpty) return txt;
      // otherwise continue to next candidate
    }
    return ''; // none produced useful result
  }

  // Start listening for left participant with smart fallback
  Future<void> _startListeningLeft() async {
    if (!_speechAvailable) {
      await _initSpeech();
      if (!_speechAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Speech not available')));
        return;
      }
    }

    if (_isListeningRight) await _stopListeningRight();

    setState(() {
      _isListeningLeft = true;
      _currentLeftTranscription = '';
    });

    // Decide candidate locales order:
    // 1) user-selected recognition locale
    // 2) best locale for the *speaker's* language (leftLangDisplay)
    // 3) device default (null)
    // 4) optionally, a short list of close matches from _availableLocales
    final chosenLocale = _leftRecognitionLocaleId;
    final bestForLanguage = _bestLocaleForLangCode(_languagesMap[_leftLangDisplay] ?? '');
    final candidates = <String?>[chosenLocale, bestForLanguage, null];

    // Also add a couple of nearby matches to try (e.g. 'hi_IN', 'hi', variants)
    // we add at most 3 more locales from available list that contain the language code
    final langCode = (_languagesMap[_leftLangDisplay] ?? '').toLowerCase();
    final extras = _availableLocales
        .where((l) => l.localeId.toLowerCase().contains(langCode) && l.localeId != bestForLanguage)
        .map((l) => l.localeId)
        .take(3)
        .toList();
    for (final ex in extras) candidates.add(ex);

    // If user explicitly chose a recognition locale, try it with a longer timeout first
    String recognized = '';
    if (chosenLocale != null) {
      recognized = await _listenOnceWithLocale(chosenLocale, timeoutSeconds: 10);
    }

    // If nothing yet, attempt sequentially with short per-locale timeout
    if (recognized.trim().isEmpty) {
      recognized = await _attemptRecognitionWithLocales(candidates.where((e) => e != chosenLocale).toList(), perLocaleSec: 5);
    }

    // update UI & process result
    setState(() {
      _currentLeftTranscription = recognized;
      _isListeningLeft = false;
    });

    if (recognized.trim().isNotEmpty) {
      await _handleConversationTurn(who: _Who.left, original: recognized);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No speech detected / failed to transcribe. Try selecting a recognition locale.')));
    }
  }

  Future<void> _stopListeningLeft() async {
    await _speech.stop();
    setState(() {
      _isListeningLeft = false;
      _currentLeftTranscription = '';
    });
  }

  // Start listening for right participant with smart fallback (mirror of left)
  Future<void> _startListeningRight() async {
    if (!_speechAvailable) {
      await _initSpeech();
      if (!_speechAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Speech not available')));
        return;
      }
    }

    if (_isListeningLeft) await _stopListeningLeft();

    setState(() {
      _isListeningRight = true;
      _currentRightTranscription = '';
    });

    final chosenLocale = _rightRecognitionLocaleId;
    final bestForLanguage = _bestLocaleForLangCode(_languagesMap[_rightLangDisplay] ?? '');
    final candidates = <String?>[chosenLocale, bestForLanguage, null];

    final langCode = (_languagesMap[_rightLangDisplay] ?? '').toLowerCase();
    final extras = _availableLocales
        .where((l) => l.localeId.toLowerCase().contains(langCode) && l.localeId != bestForLanguage)
        .map((l) => l.localeId)
        .take(3)
        .toList();
    for (final ex in extras) candidates.add(ex);

    String recognized = '';
    if (chosenLocale != null) {
      recognized = await _listenOnceWithLocale(chosenLocale, timeoutSeconds: 10);
    }

    if (recognized.trim().isEmpty) {
      recognized = await _attemptRecognitionWithLocales(candidates.where((e) => e != chosenLocale).toList(), perLocaleSec: 5);
    }

    setState(() {
      _currentRightTranscription = recognized;
      _isListeningRight = false;
    });

    if (recognized.trim().isNotEmpty) {
      await _handleConversationTurn(who: _Who.right, original: recognized);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No speech detected / failed to transcribe. Try selecting a recognition locale.')));
    }
  }

  Future<void> _stopListeningRight() async {
    await _speech.stop();
    setState(() {
      _isListeningRight = false;
      _currentRightTranscription = '';
    });
  }

  Future<void> _handleConversationTurn({required _Who who, required String original}) async {
    if (original.trim().isEmpty) return;

    // detect language via ML Kit
    String detected = '';
    try {
      final lang = await _languageIdentifier.identifyLanguage(original);
      if (lang != 'und') detected = lang;
    } catch (_) {
      detected = '';
    }

    final fromDisplay = detected.isEmpty ? '' : _languageDisplayForCode(detected);
    final targetDisplay = (who == _Who.left) ? _rightLangDisplay : _leftLangDisplay;
    final targetCode = _languagesMap[targetDisplay] ?? 'en';

    String translated = '';
    try {
      final translation = await _translator.translate(original, to: targetCode);
      translated = translation.text;
    } catch (e) {
      translated = '[translation error]';
    }

    // speak translation
    try {
      final ttsLocale = _ttsLocaleForCode(targetCode);
      await _tts.setLanguage(ttsLocale);
      await _tts.speak(translated);
    } catch (_) {}

    final entry = _ConvEntry(
      who: who,
      original: original,
      detectedLangCode: detected,
      detectedLangDisplay: fromDisplay,
      translated: translated,
      timestamp: DateTime.now(),
    );

    setState(() {
      _history.add(entry);
      _currentLeftTranscription = '';
      _currentRightTranscription = '';
    });

    await Future.delayed(const Duration(milliseconds: 120));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  String _languageDisplayForCode(String code) {
    if (code.isEmpty) return '';
    final norm = code.toLowerCase();
    final entry = _languagesMap.entries.firstWhere((e) => e.value.toLowerCase() == norm, orElse: () => const MapEntry('', ''));
    return entry.key;
  }

  // TTS locale mapping - keep or expand
  String _ttsLocaleForCode(String code) {
    final Map<String, String> mapping = {
      'en': 'en-US',
      'hi': 'hi-IN',
      'es': 'es-ES',
      'fr': 'fr-FR',
      'de': 'de-DE',
      'ru': 'ru-RU',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'pt': 'pt-PT',
      'ar': 'ar-SA',
    };
    return mapping[code] ?? code;
  }

  // UI building helpers
  Widget _buildMicButton({required bool left}) {
    final listening = left ? _isListeningLeft : _isListeningRight;
    return GestureDetector(
      onTap: () => left ? (listening ? _stopListeningLeft() : _startListeningLeft()) : (listening ? _stopListeningRight() : _startListeningRight()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          gradient: listening ? const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]) : const LinearGradient(colors: [Colors.white, Colors.grey]),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 6))],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (listening)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) {
                  final v = 20 + _pulseAnim.value;
                  return Container(width: v, height: v, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)));
                },
              ),
            Icon(listening ? Icons.mic : Icons.mic_none, color: listening ? Colors.white : Colors.black87, size: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationList() {
    if (_history.isEmpty) {
      return const Center(
        child: Text('No conversation yet. Tap a mic to start.', style: TextStyle(color: Colors.white70)),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _history.length,
      itemBuilder: (context, i) {
        final e = _history[i];
        final isLeft = e.who == _Who.left;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (e.detectedLangDisplay.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('${e.detectedLangDisplay} • ${_formatTime(e.timestamp)}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                ),
              Align(
                alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: isLeft ? Colors.white : Colors.blueAccent, borderRadius: BorderRadius.circular(14)),
                  child: Text(e.original, style: TextStyle(color: isLeft ? Colors.black87 : Colors.white)),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: isLeft ? Colors.blue.shade700 : Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Text(e.translated, style: TextStyle(color: isLeft ? Colors.white : Colors.black87)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // Header
  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.record_voice_over, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Conversation Mode', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 2),
              Text('Tap a mic to speak. App translates & speaks for the other side.', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(colors: [Color(0xFF0F4C66), Color(0xFF8FD3C7)], begin: Alignment.topLeft, end: Alignment.bottomRight);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        padding: const EdgeInsets.only(top: 44, left: 12, right: 12, bottom: 18),
        child: SafeArea(
          bottom: true,
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 12),

              // conversation area
              Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(14)), child: _buildConversationList())),

              const SizedBox(height: 12),

              // partial preview row + recognition-locale display
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('You (${_languagesMap[_leftLangDisplay] ?? ''})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              GestureDetector(
                                onTap: () => _pickRecognitionLocale(forLeft: true),
                                child: Text(_leftRecognitionLocaleId ?? 'auto', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ),
                            ]),
                            const SizedBox(height: 6),
                            Text(_currentLeftTranscription.isEmpty ? '—' : _currentLeftTranscription, style: const TextStyle(color: Colors.white70)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('Partner (${_languagesMap[_rightLangDisplay] ?? ''})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              GestureDetector(
                                onTap: () => _pickRecognitionLocale(forLeft: false),
                                child: Text(_rightRecognitionLocaleId ?? 'auto', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ),
                            ]),
                            const SizedBox(height: 6),
                            Text(_currentRightTranscription.isEmpty ? '—' : _currentRightTranscription, style: const TextStyle(color: Colors.white70)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // bottom controls: left mic, clear/stop, right mic
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    _buildMicButton(left: true),
                    const SizedBox(height: 8),
                    TextButton(onPressed: () => _openLanguagePicker(forLeft: true), child: Text(_leftLangDisplay, style: const TextStyle(color: Colors.white70))),
                  ]),
                  Column(children: [
                    ElevatedButton.icon(onPressed: () {
                      _speech.stop();
                      _tts.stop();
                      setState(() {
                        _isListeningLeft = false;
                        _isListeningRight = false;
                      });
                    }, icon: const Icon(Icons.stop_circle_outlined), label: const Text('Stop All'), style: ElevatedButton.styleFrom(backgroundColor: Colors.white)),
                    const SizedBox(height: 6),
                    TextButton(onPressed: () => setState(() => _history.clear()), child: const Text('Clear', style: TextStyle(color: Colors.white70))),
                  ]),
                  Column(children: [
                    _buildMicButton(left: false),
                    const SizedBox(height: 8),
                    TextButton(onPressed: () => _openLanguagePicker(forLeft: false), child: Text(_rightLangDisplay, style: const TextStyle(color: Colors.white70))),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Simple language picker for left/right spoken language (chooses target for translation)
  Future<void> _openLanguagePicker({required bool forLeft}) async {
    _searchController.clear();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final allKeys = _languagesMap.keys.toList();
        return DraggableScrollableSheet(
          maxChildSize: 0.95,
          minChildSize: 0.35,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(18.0))),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(width: 56, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 8),
                  TextField(controller: _searchController, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search language'), onChanged: (_) => setState(() {})),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: allKeys.where((k) {
                        final q = _searchController.text.toLowerCase();
                        if (q.isEmpty) return true;
                        final code = _languagesMap[k]!.toLowerCase();
                        return k.toLowerCase().contains(q) || code.contains(q);
                      }).map((k) => ListTile(title: Text(k), subtitle: Text(_languagesMap[k] ?? ''), onTap: () {
                        setState(() {
                          if (forLeft) _leftLangDisplay = k;
                          else _rightLangDisplay = k;
                        });
                        Navigator.pop(context);
                      })).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
