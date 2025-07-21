import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TextInputScreen extends StatefulWidget {
  @override
  _TextInputScreenState createState() => _TextInputScreenState();
}

class _TextInputScreenState extends State<TextInputScreen> {
  final TextEditingController _textController = TextEditingController();
  final GoogleTranslator translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();

  final Map<String, String> languages = {
    'Afrikaans': 'af', 'Albanian': 'sq', 'Amharic': 'am', 'Arabic': 'ar', 'Armenian': 'hy',
    'Azerbaijani': 'az', 'Basque': 'eu', 'Belarusian': 'be', 'Bengali': 'bn', 'Bosnian': 'bs',
    'Bulgarian': 'bg', 'Catalan': 'ca', 'Cebuano': 'ceb', 'Chinese (Simplified)': 'zh-CN',
    'Chinese (Traditional)': 'zh-TW', 'Corsican': 'co', 'Croatian': 'hr', 'Czech': 'cs',
    'Danish': 'da', 'Dutch': 'nl', 'English': 'en', 'Esperanto': 'eo', 'Estonian': 'et',
    'Finnish': 'fi', 'French': 'fr', 'Frisian': 'fy', 'Galician': 'gl', 'Georgian': 'ka',
    'German': 'de', 'Greek': 'el', 'Gujarati': 'gu', 'Haitian Creole': 'ht', 'Hausa': 'ha',
    'Hawaiian': 'haw', 'Hebrew': 'iw', 'Hindi': 'hi', 'Hmong': 'hmn', 'Hungarian': 'hu',
    'Icelandic': 'is', 'Igbo': 'ig', 'Indonesian': 'id', 'Irish': 'ga', 'Italian': 'it',
    'Japanese': 'ja', 'Javanese': 'jw', 'Kannada': 'kn', 'Kazakh': 'kk', 'Khmer': 'km',
    'Kinyarwanda': 'rw', 'Korean': 'ko', 'Kurdish': 'ku', 'Kyrgyz': 'ky', 'Lao': 'lo',
    'Latin': 'la', 'Latvian': 'lv', 'Lithuanian': 'lt', 'Luxembourgish': 'lb', 'Macedonian': 'mk',
    'Malagasy': 'mg', 'Malay': 'ms', 'Malayalam': 'ml', 'Maltese': 'mt', 'Maori': 'mi',
    'Marathi': 'mr', 'Mongolian': 'mn', 'Myanmar (Burmese)': 'my', 'Nepali': 'ne',
    'Norwegian': 'no', 'Nyanja (Chichewa)': 'ny', 'Odia (Oriya)': 'or', 'Pashto': 'ps',
    'Persian': 'fa', 'Polish': 'pl', 'Portuguese': 'pt', 'Punjabi': 'pa', 'Romanian': 'ro',
    'Russian': 'ru', 'Samoan': 'sm', 'Scots Gaelic': 'gd', 'Serbian': 'sr', 'Sesotho': 'st',
    'Shona': 'sn', 'Sindhi': 'sd', 'Sinhala (Sinhalese)': 'si', 'Slovak': 'sk', 'Slovenian': 'sl',
    'Somali': 'so', 'Spanish': 'es', 'Sundanese': 'su', 'Swahili': 'sw', 'Swedish': 'sv',
    'Tagalog (Filipino)': 'tl', 'Tajik': 'tg', 'Tamil': 'ta', 'Tatar': 'tt', 'Telugu': 'te',
    'Thai': 'th', 'Turkish': 'tr', 'Turkmen': 'tk', 'Ukrainian': 'uk', 'Urdu': 'ur',
    'Uyghur': 'ug', 'Uzbek': 'uz', 'Vietnamese': 'vi', 'Welsh': 'cy', 'Xhosa': 'xh',
    'Yiddish': 'yi', 'Yoruba': 'yo', 'Zulu': 'zu'
  };

  String fromLanguage = 'en';
  String toLanguage = 'hi';
  String translatedText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Type Text Manually")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: "Enter text to translate",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              SizedBox(height: 20),

              /// Language selection: From → To
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("From:"),
                        DropdownButton<String>(
                          value: fromLanguage,
                          items: languages.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.value,
                              child: Text(entry.key),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              fromLanguage = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("To:"),
                        DropdownButton<String>(
                          value: toLanguage,
                          items: languages.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.value,
                              child: Text(entry.key),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              toLanguage = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              /// Translate Button
              ElevatedButton.icon(
                icon: Icon(Icons.translate),
                label: Text("Translate"),
                onPressed: () async {
                  final inputText = _textController.text.trim();

                  if (inputText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter some text")),
                    );
                    return;
                  }

                  final translation = await translator.translate(
                    inputText,
                    from: fromLanguage,
                    to: toLanguage,
                  );

                  setState(() {
                    translatedText = translation.text;
                  });
                },
              ),
              SizedBox(height: 30),

              /// Translated Output
              if (translatedText.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Translated Text:", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(translatedText, style: TextStyle(fontSize: 16)),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.volume_up),
                          label: Text("Speak"),
                          onPressed: () async {
                            await flutterTts.setLanguage(toLanguage);
                            await flutterTts.speak(translatedText);
                          },
                        ),
                        SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: Icon(Icons.stop),
                          label: Text("Stop"),
                          onPressed: () async {
                            await flutterTts.stop();
                          },
                        ),
                        SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: Icon(Icons.copy),
                          label: Text("Copy"),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: translatedText));
                            Fluttertoast.showToast(msg: "Text copied to clipboard");
                          },
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
