import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  File? _image;
  String _scannedText = '';
  String _translatedText = '';
  String? _selectedLanguageCode;
  String _detectedLangCode = '';
  String _detectedLangName = '';
  String _translatedLangName = '';

  final ImagePicker _picker = ImagePicker();
  final translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();

  late AnimationController _animController;
  late Animation<double> _fadeIn;

  final Map<String, String> languages = {
    '🇿🇦 Afrikaans': 'af', '🇦🇱 Albanian': 'sq', '🇪🇹 Amharic': 'am', '🇸🇦 Arabic': 'ar', '🇦🇲 Armenian': 'hy',
    '🇦🇿 Azerbaijani': 'az', '🇪🇸 Basque': 'eu', '🇧🇾 Belarusian': 'be', '🇧🇩 Bengali': 'bn', '🇧🇦 Bosnian': 'bs',
    '🇧🇬 Bulgarian': 'bg', '🇪🇸 Catalan': 'ca', '🇵🇭 Cebuano': 'ceb', '🇨🇳 Chinese (Simplified)': 'zh-CN',
    '🇹🇼 Chinese (Traditional)': 'zh-TW', '🇫🇷 Corsican': 'co', '🇭🇷 Croatian': 'hr', '🇨🇿 Czech': 'cs',
    '🇩🇰 Danish': 'da', '🇳🇱 Dutch': 'nl', '🇬🇧 English': 'en', '🌐 Esperanto': 'eo', '🇪🇪 Estonian': 'et',
    '🇫🇮 Finnish': 'fi', '🇫🇷 French': 'fr', '🇳🇱 Frisian': 'fy', '🇪🇸 Galician': 'gl', '🇬🇪 Georgian': 'ka',
    '🇩🇪 German': 'de', '🇬🇷 Greek': 'el', '🇮🇳 Gujarati': 'gu', '🇭🇹 Haitian Creole': 'ht', '🇳🇬 Hausa': 'ha',
    '🇺🇸 Hawaiian': 'haw', '🇮🇱 Hebrew': 'iw', '🇮🇳 Hindi': 'hi', '🇨🇳 Hmong': 'hmn', '🇭🇺 Hungarian': 'hu',
    '🇮🇸 Icelandic': 'is', '🇳🇬 Igbo': 'ig', '🇮🇩 Indonesian': 'id', '🇮🇪 Irish': 'ga', '🇮🇹 Italian': 'it',
    '🇯🇵 Japanese': 'ja', '🇮🇩 Javanese': 'jw', '🇮🇳 Kannada': 'kn', '🇰🇿 Kazakh': 'kk', '🇰🇭 Khmer': 'km',
    '🇷🇼 Kinyarwanda': 'rw', '🇰🇷 Korean': 'ko', '🇮🇶 Kurdish': 'ku', '🇰🇬 Kyrgyz': 'ky', '🇱🇦 Lao': 'lo',
    '🇻🇦 Latin': 'la', '🇱🇻 Latvian': 'lv', '🇱🇹 Lithuanian': 'lt', '🇱🇺 Luxembourgish': 'lb', '🇲🇰 Macedonian': 'mk',
    '🇲🇬 Malagasy': 'mg', '🇲🇾 Malay': 'ms', '🇮🇳 Malayalam': 'ml', '🇲🇹 Maltese': 'mt', '🇳🇿 Maori': 'mi',
    '🇮🇳 Marathi': 'mr', '🇲🇳 Mongolian': 'mn', '🇲🇲 Myanmar (Burmese)': 'my', '🇳🇵 Nepali': 'ne',
    '🇳🇴 Norwegian': 'no', '🇲🇼 Nyanja (Chichewa)': 'ny', '🇮🇳 Odia (Oriya)': 'or', '🇦🇫 Pashto': 'ps',
    '🇮🇷 Persian': 'fa', '🇵🇱 Polish': 'pl', '🇵🇹 Portuguese': 'pt', '🇮🇳 Punjabi': 'pa', '🇷🇴 Romanian': 'ro',
    '🇷🇺 Russian': 'ru', '🇼🇸 Samoan': 'sm', '🏴 Scots Gaelic': 'gd', '🇷🇸 Serbian': 'sr', '🇱🇸 Sesotho': 'st',
    '🇿🇼 Shona': 'sn', '🇵🇰 Sindhi': 'sd', '🇱🇰 Sinhala (Sinhalese)': 'si', '🇸🇰 Slovak': 'sk', '🇸🇮 Slovenian': 'sl',
    '🇸🇴 Somali': 'so', '🇪🇸 Spanish': 'es', '🇮🇩 Sundanese': 'su', '🇰🇪 Swahili': 'sw', '🇸🇪 Swedish': 'sv',
    '🇵🇭 Tagalog (Filipino)': 'tl', '🇹🇯 Tajik': 'tg', '🇮🇳 Tamil': 'ta', '🇷🇺 Tatar': 'tt', '🇮🇳 Telugu': 'te',
    '🇹🇭 Thai': 'th', '🇹🇷 Turkish': 'tr', '🇹🇲 Turkmen': 'tk', '🇺🇦 Ukrainian': 'uk', '🇵🇰 Urdu': 'ur',
    '🇨🇳 Uyghur': 'ug', '🇺🇿 Uzbek': 'uz', '🇻🇳 Vietnamese': 'vi', '🏴 Welsh': 'cy', '🇿🇦 Xhosa': 'xh',
    '🇮🇱 Yiddish': 'yi', '🇳🇬 Yoruba': 'yo', '🇿🇦 Zulu': 'zu'
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
        _scannedText = '⏳ Extracting text...';
        _translatedText = '';
      });
      await _performOCR(imageFile);
    }
  }

  Future<void> _performOCR(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      final rawText = recognizedText.text.trim();
      setState(() {
        _scannedText = rawText.isEmpty ? '⚠️ No text found.' : rawText;
      });

      if (_selectedLanguageCode != null && rawText.isNotEmpty) {
        final translation = await translator.translate(rawText, to: _selectedLanguageCode!);
        final sourceLangCode = translation.sourceLanguage.code;
        String sourceLangName = languages.entries
            .firstWhere((entry) => entry.value == sourceLangCode, orElse: () => MapEntry('Unknown', ''))
            .key;
        String translatedLangName = languages.entries
            .firstWhere((entry) => entry.value == _selectedLanguageCode!, orElse: () => MapEntry('Unknown', ''))
            .key;

        setState(() {
          _translatedText = translation.text;
          _detectedLangCode = sourceLangCode;
          _detectedLangName = sourceLangName;
          _translatedLangName = translatedLangName;
        });
      }
    } catch (e) {
      setState(() {
        _scannedText = '❌ Error: ${e.toString()}';
      });
    } finally {
      await textRecognizer.close();
    }
  }

  Widget gradientButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F2FF),
      appBar: AppBar(
        title: Text("📸 Image Text Translator"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: _image != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_image!, height: 250),
                )
                    : Icon(Icons.image, size: 100, color: Colors.grey[500]),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  gradientButton(
                    label: "Camera",
                    icon: Icons.camera_alt,
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  gradientButton(
                    label: "Gallery",
                    icon: Icons.photo,
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "🌐 Choose Target Language",
                  border: OutlineInputBorder(),
                ),
                items: languages.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.value,
                    child: Text(entry.key),
                  );
                }).toList(),
                value: _selectedLanguageCode,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguageCode = value!;
                    _translatedText = '';
                  });
                  if (_scannedText.isNotEmpty) {
                    translator.translate(_scannedText, to: value!).then((translation) {
                      final sourceLangCode = translation.sourceLanguage.code;
                      String sourceLangName = languages.entries
                          .firstWhere((entry) => entry.value == sourceLangCode, orElse: () => MapEntry('Unknown', ''))
                          .key;
                      String translatedLangName = languages.entries
                          .firstWhere((entry) => entry.value == value, orElse: () => MapEntry('Unknown', ''))
                          .key;
                      setState(() {
                        _translatedText = translation.text;
                        _detectedLangCode = sourceLangCode;
                        _detectedLangName = sourceLangName;
                        _translatedLangName = translatedLangName;
                      });
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              if (_scannedText.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "📃 Scanned Text (Detected: $_detectedLangName):",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    border: Border.all(color: Colors.purpleAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SelectableText(
                    _scannedText,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
              if (_translatedText.isNotEmpty) ...[
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "🌍 Translated Text (To: $_translatedLangName):",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[50],
                    border: Border.all(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SelectableText(
                    _translatedText,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    gradientButton(
                      label: "Speak",
                      icon: Icons.volume_up,
                      onPressed: () async {
                        await flutterTts.setLanguage(_selectedLanguageCode ?? 'en');
                        await flutterTts.speak(_translatedText);
                      },
                    ),
                    SizedBox(width: 10),
                    gradientButton(
                      label: "Stop",
                      icon: Icons.stop,
                      onPressed: () async {
                        await flutterTts.stop();
                      },
                    ),
                    SizedBox(width: 10),
                    gradientButton(
                      label: "Copy",
                      icon: Icons.copy,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _translatedText));
                        Fluttertoast.showToast(msg: "✅ Text copied!");
                      },
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
