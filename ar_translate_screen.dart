// lib/ar_translate_screen.dart
// AR Camera Translate - fixed clamp RangeError, safer overlay sizing, faster processing, removed Save button
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

class ArTranslateScreen extends StatefulWidget {
  const ArTranslateScreen({Key? key}) : super(key: key);

  @override
  State<ArTranslateScreen> createState() => _ArTranslateScreenState();
}

class _ArTranslateScreenState extends State<ArTranslateScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _cameraInitialized = false;

  XFile? _capturedImage;
  ui.Image? _capturedUiImage;

  bool _processing = false;

  List<_TranslatedBlock> _translatedBlocks = [];

  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final GoogleTranslator _translator = GoogleTranslator();
  final FlutterTts _tts = FlutterTts();

  // Full language map (display -> code)
  final Map<String, String> _languages = {
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

  final Map<String, String> _ttsLocaleFor = {
    'en': 'en-US',
    'hi': 'hi-IN',
    'gu': 'gu-IN',
    'mr': 'mr-IN',
    'ja': 'ja-JP',
    'es': 'es-ES',
    'fr': 'fr-FR',
    'de': 'de-DE',
    'ru': 'ru-RU',
    'ko': 'ko-KR',
    'zh-CN': 'zh-CN',
    'zh-TW': 'zh-TW',
    'pt': 'pt-PT',
    'ar': 'ar-SA',
  };

  late String _selectedLanguageDisplay;
  String _targetLanguageCode = 'en';

  late AnimationController _procAnimController;
  late Animation<double> _procScale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _selectedLanguageDisplay = _languages.keys.firstWhere((k) => _languages[k] == 'en', orElse: () => _languages.keys.first);
    _targetLanguageCode = _languages[_selectedLanguageDisplay] ?? 'en';

    _initCamera();
    _initTts();

    _procAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _procScale = Tween<double>(begin: 0.9, end: 1.05).animate(CurvedAnimation(parent: _procAnimController, curve: Curves.easeInOut));
    _procAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _procAnimController.reverse();
      else if (status == AnimationStatus.dismissed) _procAnimController.forward();
    });
  }

  Future<void> _initTts() async {
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No camera found on device')));
        return;
      }
      // use medium preset for faster capture/processing
      _cameraController = CameraController(_cameras.first, ResolutionPreset.medium, enableAudio: false);
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() => _cameraInitialized = true);
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Camera init failed: $e')));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _textRecognizer.close();
    _tts.stop();
    _procAnimController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) controller.dispose();
    else if (state == AppLifecycleState.resumed) _initCamera();
  }

  Future<void> _takePictureAndProcess() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _processing) return;

    setState(() {
      _processing = true;
      _translatedBlocks = [];
    });

    _procAnimController.forward();

    try {
      // capture at medium resolution (faster than high)
      final file = await _cameraController!.takePicture();
      _capturedImage = file;

      final bytes = await file.readAsBytes();

      // decode image at a reduced target width to speed up instantiateImageCodec
      const int targetWidth = 800; // smaller -> faster; adjust if you need more detail
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: targetWidth);
      final frame = await codec.getNextFrame();
      _capturedUiImage = frame.image;

      final inputImage = InputImage.fromFilePath(file.path);
      final RecognizedText visionResult = await _textRecognizer.processImage(inputImage);

      final blocks = visionResult.blocks.where((b) => b.text.trim().isNotEmpty).toList();

      // process fewer blocks for speed (12)
      final limited = _selectImportantBlocks(blocks, maxBlocks: 12);

      final List<_TranslatedBlock> results = [];
      for (final block in limited) {
        try {
          final code = _languages[_selectedLanguageDisplay] ?? 'en';
          // translation network calls can dominate time — we do fewer calls by limiting blocks
          final tr = await _translator.translate(block.text, to: code);
          final translated = tr.text;
          results.add(_TranslatedBlock(text: block.text, translated: translated, boundingBox: block.boundingBox));
        } catch (e) {
          results.add(_TranslatedBlock(text: block.text, translated: block.text, boundingBox: block.boundingBox));
        }
      }

      setState(() {
        _translatedBlocks = results;
        _processing = false;
        _targetLanguageCode = _languages[_selectedLanguageDisplay] ?? 'en';
      });
    } catch (e) {
      debugPrint('capture/process error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      setState(() {
        _processing = false;
        _translatedBlocks = [];
      });
    } finally {
      _procAnimController.stop();
      _procAnimController.reset();
    }
  }

  List<TextBlock> _selectImportantBlocks(List<TextBlock> blocks, {int maxBlocks = 12}) {
    if (blocks.length <= maxBlocks) return blocks;
    final items = List<TextBlock>.from(blocks);
    items.sort((a, b) {
      final ar = (a.boundingBox?.width ?? 0) * (a.boundingBox?.height ?? 0);
      final br = (b.boundingBox?.width ?? 0) * (b.boundingBox?.height ?? 0);
      return br.compareTo(ar);
    });
    return items.take(maxBlocks).toList();
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    final code = _languages[_selectedLanguageDisplay] ?? 'en';
    final locale = _ttsLocaleFor[code] ?? code;
    try { await _tts.setLanguage(locale); } catch (_) {}
    await _tts.speak(text);
  }

  Future<void> _stopSpeaking() async {
    try { await _tts.stop(); } catch (_) {}
  }

  void _clear() {
    setState(() {
      _capturedImage = null;
      _capturedUiImage = null;
      _translatedBlocks = [];
    });
  }

  /// Safe overlay builder: avoids any clamp(lower, upper) where lower > upper.
  List<Widget> _buildOverlays(BoxConstraints constraints) {
    try {
      if (_capturedUiImage == null || _translatedBlocks.isEmpty) return [];

      final imageW = _capturedUiImage!.width.toDouble();
      final imageH = _capturedUiImage!.height.toDouble();

      final boxW = constraints.maxWidth;
      final boxH = constraints.maxHeight;

      final imageRatio = imageW / imageH;
      final boxRatio = boxW / boxH;

      double renderW, renderH, offsetX = 0, offsetY = 0;
      if (imageRatio > boxRatio) {
        renderW = boxW;
        renderH = boxW / imageRatio;
        offsetY = (boxH - renderH) / 2;
      } else {
        renderH = boxH;
        renderW = boxH * imageRatio;
        offsetX = (boxW - renderW) / 2;
      }

      final wScale = renderW / imageW;
      final hScale = renderH / imageH;

      // reserve dynamic right margin to avoid overlap with UI; responsive
      final double reservedRight = (boxW * 0.10).clamp(29.0, 120.0);

      final overlays = <Widget>[];
      for (final tb in _translatedBlocks) {
        if (tb.boundingBox == null) continue;
        final rect = tb.boundingBox!;
        final left = rect.left * wScale + offsetX;
        final top = rect.top * hScale + offsetY;

        // keep the left within bounds
        final constrainedLeft = left.clamp(0.0, boxW - 4);

        // available horizontal space for overlay after reserved right area
        final double availSpace = boxW - constrainedLeft - reservedRight;

        // max possible width considering reserved right margin and small padding
        final double maxPossible = boxW - reservedRight - 8.0;

        double overlayWidth;
        if (maxPossible <= 8.0) {
          // extremely small screens: fallback to most of width minus small padding
          overlayWidth = math.max(8.0, boxW - 16.0);
        } else if (availSpace <= 8.0) {
          // not enough space on the right of this rect — use maxPossible (puts overlay leftwards)
          overlayWidth = math.max(8.0, maxPossible);
        } else {
          // normal case: use available space but never exceed maxPossible
          overlayWidth = math.min(availSpace, maxPossible);
        }

        // ensure overlayWidth is positive and not NaN
        if (!overlayWidth.isFinite || overlayWidth < 8.0) overlayWidth = math.max(8.0, boxW * 0.4);

        final positionedTop = top.clamp(0.0, boxH - 18);

        overlays.add(Positioned(
          left: constrainedLeft,
          top: positionedTop,
          width: overlayWidth,
          child: GestureDetector(
            onTap: () => _showBlockActions(tb),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                tb.translated,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.2),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ),
          ),
        ));
      }

      return overlays;
    } catch (e) {
      // safety: if anything unexpected happens, don't crash the UI — return no overlays
      debugPrint('Overlay build error: $e');
      return [];
    }
  }

  void _showBlockActions(_TranslatedBlock tb) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy translation'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: tb.translated));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.volume_up),
                title: const Text('Speak translation'),
                onTap: () {
                  Navigator.pop(ctx);
                  _speak(tb.translated);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('View source text'),
                subtitle: Text(tb.text, maxLines: 3, overflow: TextOverflow.ellipsis),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCameraPreview() {
    if (!_cameraInitialized || _cameraController == null) return const Center(child: CircularProgressIndicator());
    return ClipRect(child: CameraPreview(_cameraController!));
  }

  Widget _buildCapturedView() {
    if (_capturedUiImage == null) return const Center(child: CircularProgressIndicator());

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _capturedUiImage!.width.toDouble(),
                  height: _capturedUiImage!.height.toDouble(),
                  child: RawImage(image: _capturedUiImage),
                ),
              ),
            ),
            ..._buildOverlays(constraints),
          ],
        );
      },
    );
  }

  void _openLanguagePicker() {
    final keys = _languages.keys.toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final controller = TextEditingController();
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.95,
          minChildSize: 0.35,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(width: 48, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search language (name or code)', border: OutlineInputBorder()),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: keys.where((k) {
                        final q = controller.text.toLowerCase();
                        if (q.isEmpty) return true;
                        final code = (_languages[k] ?? '').toLowerCase();
                        return k.toLowerCase().contains(q) || code.contains(q);
                      }).map((k) {
                        return ListTile(
                          title: Text(k),
                          subtitle: Text(_languages[k] ?? '', style: const TextStyle(fontSize: 12)),
                          onTap: () {
                            setState(() {
                              _selectedLanguageDisplay = k;
                              _targetLanguageCode = _languages[k] ?? 'en';
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      }).toList(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('AR Camera Translate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.stop_circle_outlined, color: Colors.white), onPressed: _stopSpeaking),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              icon: const Icon(Icons.language, color: Colors.white),
              label: Flexible(child: Text(_selectedLanguageDisplay, style: const TextStyle(color: Colors.white))),
              onPressed: _openLanguagePicker,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _capturedImage == null ? _buildCameraPreview() : _buildCapturedView()),
            Positioned(
              left: 12,
              top: 12,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _processing ? 0.0 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(8)),
                  child: Text(_capturedImage == null ? 'Point & capture text' : 'Tap overlays for actions', style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
            Positioned(
              bottom: 18,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_processing)
                    ScaleTransition(
                      scale: _procScale,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(width: 6),
                            CircularProgressIndicator(strokeWidth: 2),
                            SizedBox(width: 12),
                            Text('Processing...', style: TextStyle(color: Colors.white)),
                            SizedBox(width: 6),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_capturedImage == null)
                        FloatingActionButton(
                          heroTag: 'capture',
                          tooltip: 'Capture & translate',
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          onPressed: _cameraInitialized && !_processing ? _takePictureAndProcess : null,
                          child: const Icon(Icons.camera_alt, size: 28),
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              ElevatedButton.icon(icon: const Icon(Icons.refresh), label: const Text('Retake'), style: ElevatedButton.styleFrom(backgroundColor: Colors.white70, foregroundColor: Colors.black), onPressed: _processing ? null : _clear),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(icon: const Icon(Icons.copy), label: const Text('Copy all'), onPressed: () { final all = _translatedBlocks.map((b) => b.translated).join('\n'); Clipboard.setData(ClipboardData(text: all)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied all translations'))); }),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(icon: const Icon(Icons.volume_up), label: const Text('Speak all'), onPressed: () { final all = _translatedBlocks.map((b) => b.translated).join('. '); _speak(all); }),
                              const SizedBox(width: 8),
                              // Save button intentionally removed for speed / simplicity
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TranslatedBlock {
  final String text;
  final String translated;
  final Rect? boundingBox;

  _TranslatedBlock({
    required this.text,
    required this.translated,
    required this.boundingBox,
  });
}
