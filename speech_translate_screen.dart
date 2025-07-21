// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:translator/translator.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// class SpeechTranslateScreen extends StatefulWidget {
//   @override
//   _SpeechTranslateScreenState createState() => _SpeechTranslateScreenState();
// }
//
// class _SpeechTranslateScreenState extends State<SpeechTranslateScreen> {
//   final GoogleTranslator translator = GoogleTranslator();
//   final FlutterTts flutterTts = FlutterTts();
//   late stt.SpeechToText speech;
//
//   String spokenText = '';
//   String detectedLanguage = '';
//   String translatedText = '';
//   bool isListening = false;
//
//   final Map<String, String> languages = {
//     'Afrikaans': 'af', 'Albanian': 'sq', 'Amharic': 'am', 'Arabic': 'ar',
//     'Armenian': 'hy', 'Azerbaijani': 'az', 'Basque': 'eu', 'Belarusian': 'be',
//     'Bengali': 'bn', 'Bosnian': 'bs', 'Bulgarian': 'bg', 'Catalan': 'ca',
//     'Cebuano': 'ceb', 'Chinese (Simplified)': 'zh-CN', 'Chinese (Traditional)': 'zh-TW',
//     'Corsican': 'co', 'Croatian': 'hr', 'Czech': 'cs', 'Danish': 'da',
//     'Dutch': 'nl', 'English': 'en', 'Esperanto': 'eo', 'Estonian': 'et',
//     'Finnish': 'fi', 'French': 'fr', 'Frisian': 'fy', 'Galician': 'gl',
//     'Georgian': 'ka', 'German': 'de', 'Greek': 'el', 'Gujarati': 'gu',
//     'Haitian Creole': 'ht', 'Hausa': 'ha', 'Hawaiian': 'haw', 'Hebrew': 'iw',
//     'Hindi': 'hi', 'Hmong': 'hmn', 'Hungarian': 'hu', 'Icelandic': 'is',
//     'Igbo': 'ig', 'Indonesian': 'id', 'Irish': 'ga', 'Italian': 'it',
//     'Japanese': 'ja', 'Javanese': 'jw', 'Kannada': 'kn', 'Kazakh': 'kk',
//     'Khmer': 'km', 'Kinyarwanda': 'rw', 'Korean': 'ko', 'Kurdish': 'ku',
//     'Kyrgyz': 'ky', 'Lao': 'lo', 'Latin': 'la', 'Latvian': 'lv',
//     'Lithuanian': 'lt', 'Luxembourgish': 'lb', 'Macedonian': 'mk', 'Malagasy': 'mg',
//     'Malay': 'ms', 'Malayalam': 'ml', 'Maltese': 'mt', 'Maori': 'mi',
//     'Marathi': 'mr', 'Mongolian': 'mn', 'Myanmar (Burmese)': 'my', 'Nepali': 'ne',
//     'Norwegian': 'no', 'Nyanja (Chichewa)': 'ny', 'Odia (Oriya)': 'or', 'Pashto': 'ps',
//     'Persian': 'fa', 'Polish': 'pl', 'Portuguese': 'pt', 'Punjabi': 'pa',
//     'Romanian': 'ro', 'Russian': 'ru', 'Samoan': 'sm', 'Scots Gaelic': 'gd',
//     'Serbian': 'sr', 'Sesotho': 'st', 'Shona': 'sn', 'Sindhi': 'sd',
//     'Sinhala (Sinhalese)': 'si', 'Slovak': 'sk', 'Slovenian': 'sl', 'Somali': 'so',
//     'Spanish': 'es', 'Sundanese': 'su', 'Swahili': 'sw', 'Swedish': 'sv',
//     'Tagalog (Filipino)': 'tl', 'Tajik': 'tg', 'Tamil': 'ta', 'Tatar': 'tt',
//     'Telugu': 'te', 'Thai': 'th', 'Turkish': 'tr', 'Turkmen': 'tk',
//     'Ukrainian': 'uk', 'Urdu': 'ur', 'Uyghur': 'ug', 'Uzbek': 'uz',
//     'Vietnamese': 'vi', 'Welsh': 'cy', 'Xhosa': 'xh', 'Yiddish': 'yi',
//     'Yoruba': 'yo', 'Zulu': 'zu'
//   };
//
//   String selectedToLanguage = 'hi'; // Default target
//
//   @override
//   void initState() {
//     super.initState();
//     speech = stt.SpeechToText();
//   }
//
//   Future<void> _startListening() async {
//     bool available = await speech.initialize(
//       onStatus: (status) {
//         print('Speech status: $status');
//         if (status == 'done') {
//           setState(() => isListening = false);
//         }
//       },
//       onError: (error) {
//         print('Speech error: $error');
//         setState(() => isListening = false);
//       },
//     );
//
//     if (available) {
//       setState(() => isListening = true);
//       speech.listen(
//         onResult: (result) async {
//           spokenText = result.recognizedWords;
//           setState(() {});
//           if (spokenText.isNotEmpty) {
//             var translation = await translator.translate(spokenText, to: selectedToLanguage);
//             var detect = await translator.translate(spokenText, to: selectedToLanguage);
//             setState(() {
//               translatedText = translation.text;
//               detectedLanguage = detect.sourceLanguage?.code.toUpperCase() ?? '';
//             });
//           }
//         },
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Speech recognition not available. Check mic permission.")),
//       );
//     }
//   }
//
//   void _stopListening() {
//     speech.stop();
//     setState(() => isListening = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("🎤 Speak & Translate")),
//       body: Padding(
//         padding: EdgeInsets.all(20),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               ElevatedButton.icon(
//                 icon: Icon(isListening ? Icons.mic_off : Icons.mic),
//                 label: Text(isListening ? "Stop Listening" : "Start Listening"),
//                 onPressed: isListening ? _stopListening : _startListening,
//               ),
//               SizedBox(height: 20),
//
//               if (spokenText.isNotEmpty) ...[
//                 Text("🗣 Spoken Text:", style: TextStyle(fontWeight: FontWeight.bold)),
//                 SizedBox(height: 5),
//                 Text(spokenText),
//                 SizedBox(height: 10),
//                 Text("🌍 Detected Language: $detectedLanguage"),
//               ],
//
//               SizedBox(height: 20),
//               Row(
//                 children: [
//                   Text("🔁 Translate To: "),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: DropdownButton<String>(
//                       value: selectedToLanguage,
//                       isExpanded: true,
//                       items: languages.entries.map((entry) {
//                         return DropdownMenuItem(
//                           value: entry.value,
//                           child: Text(entry.key),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           selectedToLanguage = value!;
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20),
//
//               if (translatedText.isNotEmpty) ...[
//                 Text("✅ Translated Text:", style: TextStyle(fontWeight: FontWeight.bold)),
//                 SizedBox(height: 10),
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade200,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: SelectableText(translatedText),
//                 ),
//                 SizedBox(height: 10),
//                 Row(
//                   children: [
//                     ElevatedButton.icon(
//                       icon: Icon(Icons.volume_up),
//                       label: Text("Speak"),
//                       onPressed: () async {
//                         await flutterTts.setLanguage(selectedToLanguage);
//                         await flutterTts.speak(translatedText);
//                       },
//                     ),
//                     SizedBox(width: 10),
//                     ElevatedButton.icon(
//                       icon: Icon(Icons.stop),
//                       label: Text("Stop"),
//                       onPressed: () async {
//                         await flutterTts.stop();
//                       },
//                     ),
//                     SizedBox(width: 10),
//                     ElevatedButton.icon(
//                       icon: Icon(Icons.copy),
//                       label: Text("Copy"),
//                       onPressed: () {
//                         Clipboard.setData(ClipboardData(text: translatedText));
//                         Fluttertoast.showToast(msg: "Copied to Clipboard");
//                       },
//                     ),
//                   ],
//                 ),
//               ]
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
