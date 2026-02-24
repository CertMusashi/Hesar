# Hesar - Secure Message Encryption

<div align="center">
<img src="logo.png" alt="Logo" width="200" height="200">

**A secure Android application for encrypting and decrypting messages with AES-256-GCM**

[![Build and Release APK](https://github.com/CertMusashi/Hesar/actions/workflows/release.yml/badge.svg)](https://github.com/CertMusashi/Hesar/actions/workflows/release.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.24.5-02569B?logo=flutter)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-21%2B-3DDC84?logo=android)](https://www.android.com)

[English](README.md) | [فارسی](README-fa.md)

</div>

---

## 📋 Table of Contents

- [Features](#-features)
- [Screenshots](#-screenshots)
- [Download](#-download)
- [Security](#-security)
- [Getting Started](#-getting-started)
- [Usage](#-usage)
- [Building from Source](#-building-from-source)
- [Technical Architecture](#-technical-architecture)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

- 🔐 **Military-Grade Encryption**: AES-256-GCM encryption with PBKDF2 key derivation
- 🔑 **Key Management**: Generate, save, and share encryption keys securely
- 📱 **Modern UI**: Beautiful dark-themed interface with Persian language support
- 🌐 **Multi-language Output Encoding**: Converts encrypted data to characters from Persian, Korean, Chinese, or Russian scripts — or outputs raw hex — for easy and discreet sharing
- 💾 **Persistent Storage**: Automatically saves your encryption key for convenience
- 🚀 **Optimized Performance**: Split APK builds for minimal app size
- 🔄 **Real-time Encryption**: Instant encryption/decryption as you type
- 🎨 **Material Design**: Follows modern Android design guidelines

---

## 📸 Screenshots

<div align="center">
<table>
  <tr>
    <td><img src="screenshots/encrypt.png" width="200" alt="Encryption Screen"/></td>
    <td><img src="screenshots/decrypt.png" width="200" alt="Decryption Screen"/></td>
    <td><img src="screenshots/key.png" width="200" alt="Key Management Screen"/></td>
  </tr>
  <tr>
    <td align="center"><b>Encryption</b></td>
    <td align="center"><b>Decryption</b></td>
    <td align="center"><b>Key Management</b></td>
  </tr>
</table>
</div>

---

## 📥 Download

### Latest Release

Download the latest version from the [Releases](https://github.com/CertMusashi/Dapp/releases) page.

### Choose the Right Version

| Architecture | Description | Recommended For |
|-------------|-------------|-----------------|
| **arm64-v8a** | 64-bit ARM devices | Modern Android phones (2017+) |
| **armeabi-v7a** | 32-bit ARM devices | Older Android phones |
| **x86_64** | 64-bit Intel/AMD | Emulators, Chromebooks |
| **x86** | 32-bit Intel/AMD | Older emulators |
| **universal** | All architectures | If unsure (larger file size) |

**Note**: Most modern Android devices use **arm64-v8a**. If you're unsure, download the universal version.

---

## 🔒 Security

### Encryption Algorithm

Hesar uses **AES-256-GCM** (Advanced Encryption Standard with Galois/Counter Mode), which is:
- ✅ Approved by NIST and used by governments worldwide
- ✅ Provides both confidentiality and authenticity
- ✅ Resistant to known cryptographic attacks
- ✅ Industry standard for secure communications

### Key Derivation

- **PBKDF2** (Password-Based Key Derivation Function 2) with SHA-256
- **10,000 iterations** to prevent brute-force attacks
- Each message uses a **unique random IV** (Initialization Vector)

### Security Considerations

⚠️ **Important Notes:**
- Keep your encryption key safe and private
- Share keys only through secure channels (in person, encrypted messaging)
- Do not reuse keys across different applications
- This app is designed for personal use and moderate security needs
- For highly sensitive data, consider additional security layers

---

## 🚀 Getting Started

### Prerequisites

- Android device running **Android 5.0 (API 21)** or higher
- ~20 MB of free storage space

### Installation

1. Download the appropriate APK for your device from [Releases](https://github.com/CertMusashi/Dapp/releases)
2. Enable "Install from unknown sources" in your Android settings
3. Install the APK
4. Open Hesar and start encrypting!

---

## 📖 Usage

### First Time Setup

1. **Open the app** and navigate to the "Key" (کلید) tab
2. **Generate a new key** by clicking "Create New Key" button
   - Or enter your existing key manually
3. **Save the key** by clicking the "Save Key" button
4. **Share the key** with your intended recipient through a secure channel

### Encrypting a Message

1. Navigate to the **"Encryption" (رمزنگاری)** tab
2. Type your message in the input field
3. The encrypted message appears automatically
4. Click **"Copy"** to copy the encrypted message
5. Share it through any messaging platform

### Decrypting a Message

1. Make sure you have the correct key entered in the **"Key"** tab
2. Navigate to the **"Decryption" (رمزگشایی)** tab
3. Paste the encrypted message in the input field
4. The decrypted message appears automatically
5. Click **"Copy"** to copy the original message

### Key Management

- **Generate**: Creates a random 32-character key
- **Save**: Stores the key locally for future use
- **Copy**: Copies the key to clipboard for sharing

### Output Language

In the **Settings** tab, choose how encrypted output is displayed:

| Language | Script |
|----------|--------|
| فارسی (Persian) | Persian characters |
| انگلیسی (English) | Raw hex |
| کره‌ای (Korean) | Hangul syllables |
| چینی (Chinese) | CJK characters |
| روسی (Russian) | Cyrillic characters |

Both sender and receiver must use the same output language setting.

---

## 🛠 Building from Source

### Prerequisites

- **Flutter SDK**: 3.24.5 or higher
- **Android SDK**: API level 21+
- **Java**: JDK 17
- **Git**: For cloning the repository

### Setup

```bash
# Clone the repository
git clone https://github.com/CertMusashi/Dapp.git
cd Dapp

# Install dependencies
flutter pub get

# Run the app in debug mode
flutter run

# Build release APK (universal)
flutter build apk --release

# Build split APKs for smaller size
flutter build apk --release --split-per-abi
```
---

## 🏗 Technical Architecture

### Project Structure

```
lib/
└── main.dart          # Main application code with encryption logic

android/
├── app/
│   └── build.gradle   # Android build configuration with APK splitting
└── ...

.github/
└── workflows/
    ├── build.yml      # CI/CD for debug builds
    └── release.yml    # Release workflow with version management
```

### Encryption Flow

```
User Input → PBKDF2 Key Derivation → AES-256-GCM Encryption
          → Hex Encoding → Language Character Mapping → Output
```

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add some amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/CertMusashi/Dapp/issues)
- **Discussions**: [GitHub Discussions](https://github.com/CertMusashi/Dapp/discussions)

---

<div align="center">

**Made with ❤️ for secure communications**

[⬆ Back to Top](#hesar---secure-message-encryption)

</div>
