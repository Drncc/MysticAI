🌌 Mystic AI: The Digital Oracle

Mystic AI is a cross-platform, Generative AI-powered application that blends ancient spiritual guidance with futuristic technology. It serves as a "Cyber-Shaman," offering context-aware, poetic, and philosophical guidance through a highly customized Large Language Model (LLM).

Built with Flutter for a seamless experience across Mobile and Desktop, and powered by Groq's LPU technology for ultra-low latency responses.
🚀 Key Features

    🔮 The Oracle Chat Interface: A fully immersive chat experience where the AI remembers conversation context, enabling deep and meaningful dialogues rather than simple Q&A.

    🧠 Advanced Prompt Engineering: Features a custom "Cyber-Mystic" persona designed to speak in Deep, Poetic Turkish (or English) without breaking character.

    🛡️ Double-Layer Hallucination Filter:

        Layer 1 (Prompt): Strict system instructions to prevent "Code-Switching" (mixing languages).

        Layer 2 (Regex Code Sanitization): A Dart-based backend filter that strictly removes foreign artifacts (e.g., Chinese/Kanji characters) before rendering, ensuring a polished user experience.

    ⚡ Ultra-Fast Inference: Utilizes Groq Cloud API running Meta Llama 3, delivering responses at speeds that feel instantaneous (Real-Time AI).

    🎨 Cyberpunk Aesthetic: A custom-designed Neon/Dark UI with animated elements, responsive layouts, and floating UI components.

    💎 Cosmic Economy: A local state management system that simulates a token economy, managing user quotas and interaction limits.

🛠️ Tech Stack & Architecture

This project is engineered for performance, scalability, and a single-codebase deployment.
Category	Technology	Rationale
Frontend Framework	Flutter	For high-performance rendering (Skia Engine) and deploying to Android, iOS, and Windows from a single codebase.
Language	Dart	Strictly typed, reactive, and optimized for UI development.
AI Model	Meta Llama 3 (via Groq)	Chosen for its reasoning capabilities and "human-like" nuance.
Inference Engine	Groq LPU	Language Processing Units (LPUs) provide strictly faster token generation compared to traditional GPUs.
State Management	Local State / Provider	Efficient management of chat history and user credits without backend overhead.
Networking	HTTP & REST API	Robust communication with AI endpoints handling JSON serialization/deserialization.
🧩 Engineering Highlights
1. The "Hallucination" Solution

One of the biggest challenges in LLMs is "Cultural Bias," where models trained on diverse data accidentally insert foreign characters (e.g., Chinese Kanji) or switch languages mid-sentence.

Mystic AI solves this with a rational pipeline:
Dart

// Example of the "Iron Dome" Regex Filter implemented in Dart
if (languageCode == 'tr') {
  // Physically removes non-Latin/non-Turkish characters before the user sees them
  content = content.replaceAll(RegExp(r'[^\x00-\x7FçğıöşüÇĞİÖŞÜ\s\.,;!?:()\-"'']+', unicode: true), '');
}

2. Context-Aware Memory

Unlike stateless API calls, Mystic AI manages a sliding window of conversation history (List<ChatMessage>), allowing the Oracle to reference previous user inputs, creating a continuity of "consciousness."
📸 Screenshots
Oracle Chat	Cyber Interface
	
Context-Aware Mystic Chat	Neon UI & Navigation
⚡ Getting Started

To run this project locally, you need the Flutter SDK installed.
Prerequisites

    Flutter SDK (3.0 or higher)

    Dart SDK

    A Groq Cloud API Key (Free tier available)

Installation

    Clone the repository
    Bash

    git clone https://github.com/yourusername/MysticAI.git
    cd MysticAI

    Install dependencies
    Bash

    flutter pub get

    Configure API Key

        Create a .env file in the root directory.

        Add your key: GROQ_API_KEY=your_actual_key_here

    Run the App

        For Mobile (Connect device or emulator):
        Bash

        flutter run

        For Windows:
        Bash

        flutter run -d windows

📱 Mobile Deployment (APK)

To generate a release APK for Android:
Bash

flutter build apk --release

The output will be located at: build/app/outputs/flutter-apk/app-release.apk
🔮 Roadmap

    [x] Windows & Android Support

    [x] Context-Aware Chat

    [x] Strict Language Filtering

    [ ] iOS Release (Pending Apple Developer Account)

    [ ] Voice-to-Text Integration (Whisper Model)

    [ ] Cloud Sync for User History

📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
