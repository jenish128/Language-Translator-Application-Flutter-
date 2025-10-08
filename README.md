# Language-Translator-Application-Flutter-
A Flutter-based Language Translator App that supports text input, image scanning (OCR), and speech-to-text. It auto-detects input language and translates to 100+ languages with Text-to-Speech and copy features. Built using Flutter, Dart, Google ML Kit, and Translation APIs.


🌐 Language Translator App (Flutter)
This Flutter app allows users to translate text between 100+ languages using three smart input methods:

✨ Features
📝 Type Text – Manually enter text and translate it to any selected language.

📷 OCR from Image – Pick an image or click a photo to extract text and translate it.

🎤 Speech-to-Text – Speak to input text, detect the language automatically, and translate it.

🛠️ Built With
Flutter & Dart

Google ML Kit – OCR (Text Recognition)

Google Translate API – Language Detection & Translation

speech_to_text – Speech Recognition

flutter_tts – Text-to-Speech

Platform: Android (API 21–34)


<img align ="center" width="370" height="835" alt="Image" src="https://github.com/user-attachments/assets/b0638bfb-bbe1-4b7a-b606-6affd01fb02b" /> <br>

<img align ="center" width="370" height="835" alt="Image" src="https://github.com/user-attachments/assets/b5af0e6f-9699-4f9d-a764-66d793503f8c" /> <br>

<img align ="center" width="370" height="835" alt="Image" src="https://github.com/user-attachments/assets/e745bf4a-b044-43b5-80c8-8e22f1c4d81a" /> <br>

<img align ="center" width="370" height="835" alt="Image" src="https://github.com/user-attachments/assets/24e81fe1-90f0-4552-8daa-61dfce98ec36" /> <br>

<img align ="center" width="370" height="835" alt="Image" src="https://github.com/user-attachments/assets/38b68389-ad18-47df-8afb-fb418a0285a5" /> <br>

<img align ="center" width="370" height="835" alt="Image" src="https://github.com/user-attachments/assets/102dfc39-cab7-4ae6-9cec-e33f41f4d6d7" /> <br>

<img align ="center" width="370" height="835" alt="Image" src="https://github.com/user-attachments/assets/6f5e7df6-570a-401c-a1bb-a1a30813dd7e" /> <br>

<img align ="center" width="370" height="835" alt="Image" src="https://github.com/user-attachments/assets/00c03756-f94e-4ccc-8296-0147dcefe0e8" /> <br>

<img align ="center" width="370" height="835" alt="Image" src="https://github.com/user-attachments/assets/f5263888-244a-424f-8d56-4b5f0ca008bb" /> <br>

<img align ="center" width="370" height="835" alt="Image" src="https://github.com/user-attachments/assets/0887a593-76e7-4a8e-952d-e750ae99bdb9" /> <br>

<img align ="center" width="370" height="835" alt="Image" src="https://github.com/user-attachments/assets/775a81ff-f791-4836-9f32-4b1308d5fc67" /> <br>

<img align ="center" width="370" height="835" alt="Image" src="https://github.com/user-attachments/assets/72946caa-61b6-4d5d-a622-2974508aef3b" /> <br>

<img align ="center" width="370" height="835" alt="Image" src="https://github.com/user-attachments/assets/7b0e3156-334c-43d6-8c10-2af7cd3bfe63" /> <br>





📂 Project Structure
css
Copy
Edit
lib/
 ┣ screens/
 ┃ ┣ home_screen.dart
 ┃ ┣ ocr_screen.dart
 ┃ ┣ manual_text_screen.dart
 ┃ ┗ speech_screen.dart
 ┣ utils/
 ┃ ┗ language_map.dart
 ┣ main.dart


✅ Git installed

✅ Flutter SDK installed and added to PATH

✅ Android Studio or VS Code with Flutter & Dart plugins

✅ Emulator or physical Android phone connected

🚀 Step-by-Step Setup Guide
🔁 1. Clone your project from GitHub
bash
Copy
Edit
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name
Replace the URL with your actual repo URL.

📦 2. Get all dependencies
Run this command inside the project folder:

bash
Copy
Edit
flutter pub get
This installs all packages listed in pubspec.yaml.

🧹 3. (Optional) Clean previous builds
If there's any error, try cleaning the build first:

bash
Copy
Edit
flutter clean
flutter pub get
🔌 4. Connect your Android phone or emulator
Make sure USB Debugging is ON if using a phone

Run this to confirm device is connected:

bash
Copy
Edit
flutter devices
▶️ 5. Run the app
bash
Copy
Edit
flutter run
It will build and launch the app on your phone/emulator.

📦 Optional: Create APK for Testing
To generate a .apk file you can share or install manually:

bash
Copy
Edit
flutter build apk --release
APK will be located at:

swift
Copy
Edit
build/app/outputs/flutter-apk/app-release.apk
📁 Notes on GitHub Upload
If you haven't uploaded your code to GitHub yet, follow this:

bash
Copy
Edit
git init
git remote add origin https://github.com/your-username/your-repo-name.git
git add .
git commit -m "Initial commit"
git push -u origin main
⚠️ Don’t forget to add build/, .idea/, and .dart_tool/ in .gitignore.
