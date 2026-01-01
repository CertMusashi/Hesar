# Contributing to Hesar

Thank you for your interest in contributing to Hesar! This document provides guidelines and information for contributors.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Building the Project](#building-the-project)
- [Release Process](#release-process)
- [Code Style](#code-style)
- [Pull Request Process](#pull-request-process)

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Dapp.git
   cd Dapp
   ```
3. Add the upstream remote:
   ```bash
   git remote add upstream https://github.com/CertMusashi/Dapp.git
   ```

## Development Setup

### Prerequisites

- Flutter SDK 3.24.5 or higher
- Android SDK with API level 21+
- Java JDK 17
- Git

### Installation

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Verify your Flutter installation:
   ```bash
   flutter doctor
   ```

3. Run the app in debug mode:
   ```bash
   flutter run
   ```

## Building the Project

### Debug Build

```bash
flutter build apk --debug
```

### Release Build (Universal APK)

```bash
flutter build apk --release
```

This creates a single APK (~83 MB) compatible with all architectures.

### Release Build (Split APKs)

```bash
flutter build apk --release --split-per-abi
```

This creates separate APKs for each architecture (~18-21 MB each):
- `app-armeabi-v7a-release.apk` - 32-bit ARM devices
- `app-arm64-v8a-release.apk` - 64-bit ARM devices (most modern phones)
- `app-x86-release.apk` - 32-bit x86 devices (emulators)
- `app-x86_64-release.apk` - 64-bit x86 devices (emulators, Chromebooks)
- `app-release.apk` - Universal APK (if enabled in build.gradle)

## Release Process

### Automated Release via GitHub Actions

The project includes an automated release workflow that can be triggered manually:

1. Go to **Actions** tab in GitHub
2. Select **"Build and Release APK"** workflow
3. Click **"Run workflow"**
4. Enter the required information:
   - **Version number** (e.g., `1.0.0`)
   - **Version code** (integer, e.g., `1`)
5. Click **"Run workflow"**

The workflow will:
- Build split APKs for all architectures
- Create a GitHub Release with the version tag
- Upload all APK files to the release
- Generate release notes in both English and Persian

### Manual Release via Git Tags

You can also trigger a release by creating and pushing a version tag:

```bash
# Create a version tag
git tag v1.0.0

# Push the tag to GitHub
git push origin v1.0.0
```

The release workflow will automatically run and create a release.

## Code Style

### Dart

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` to check for issues
- Format code with `dart format .`

### Commit Messages

Use clear and descriptive commit messages:

```
Add feature: Brief description

- Detailed point 1
- Detailed point 2
```

Examples:
- `Add: AES-256-GCM encryption support`
- `Fix: Key input bug on app startup`
- `Update: README documentation`

## Pull Request Process

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Write clean, readable code
   - Add comments for complex logic
   - Update documentation as needed

3. **Test your changes**:
   ```bash
   flutter analyze
   flutter test
   flutter build apk --debug
   ```

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Add: Your feature description"
   ```

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**:
   - Go to the repository on GitHub
   - Click "New Pull Request"
   - Select your feature branch
   - Fill in the PR template
   - Submit the PR

### PR Requirements

- [ ] Code follows the project's style guidelines
- [ ] All tests pass
- [ ] Documentation is updated
- [ ] Commit messages are clear
- [ ] No merge conflicts with main branch

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Manual Testing

Before submitting a PR, manually test:

1. **Key Management**:
   - Generate a new key
   - Save the key
   - Enter an existing key manually
   - Copy the key

2. **Encryption/Decryption**:
   - Encrypt a message
   - Copy encrypted message
   - Decrypt the message with correct key
   - Try decrypting with wrong key (should fail)

3. **UI/UX**:
   - Test on different screen sizes
   - Check Persian text rendering
   - Verify dark theme consistency

## Questions or Issues?

- **Bug Reports**: Open an issue with the "bug" label
- **Feature Requests**: Open an issue with the "enhancement" label
- **Questions**: Use GitHub Discussions

## License

By contributing to Hesar, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to Hesar!** 🎉
