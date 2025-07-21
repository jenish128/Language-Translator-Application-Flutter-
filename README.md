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


<img align ="center" width="370" height="835" alt="Image" src="https://github.com/user-attachments/assets/701646db-634c-47d8-be65-46e9b33d63e5" /> <br>

<img align ="center" width="367" height="831" alt="Image" src="https://github.com/user-attachments/assets/9328458b-c890-4061-ab35-b6359a3e440e" /> <br>

<img align ="center" width="380" height="831" alt="Image" src="https://github.com/user-attachments/assets/844a71ec-f4ef-489d-b8c6-293c6a505da5" /> <br>

<img align ="center" width="375" height="830" alt="Image" src="https://github.com/user-attachments/assets/a4f52add-1219-440e-8ea6-28a379668d95" /> <br>

<img align ="center" width="370" height="829" alt="Image" src="https://github.com/user-attachments/assets/f30f3ff5-5006-4f94-b4c2-78cb2e505fc2" /> <br>

<img align ="center" width="370" height="829" alt="Image" src="https://github.com/user-attachments/assets/5573b60b-d354-41d7-9e87-37ff407fdbd3" /> <br>

<img align ="center" width="370" height="829" alt="Image" src="https://github.com/user-attachments/assets/7aabfc39-5ac7-4ac1-b52d-91012eeb7c58" /> <br>


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
