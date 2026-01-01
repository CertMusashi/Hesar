import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/digests/sha256.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hesar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1c1c1c),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFF333333)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFF333333)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _encodeInputController = TextEditingController();
  final TextEditingController _decodeInputController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  String _encodeOutput = '';
  String _decodeOutput = '';

  // Obfuscated salt computation constants
  static const int _saltBase = 72;
  static const List<int> _saltOffsets = [0, 29, 43, 25, 42, -3, 38, 27, 42, 49, 40, 44, 33, 39, 38, 11, 25, 36, 44, -22, -24, -22, -20];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavedKey();
    _encodeInputController.addListener(_onEncodeInputChanged);
    _decodeInputController.addListener(_onDecodeInputChanged);
    _keyController.addListener(_onKeyChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _encodeInputController.dispose();
    _decodeInputController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString('encryption_key');
    if (savedKey != null && savedKey.isNotEmpty) {
      setState(() {
        _keyController.text = savedKey;
      });
      // Trigger encryption/decryption updates after key is loaded
      _onEncodeInputChanged();
      _onDecodeInputChanged();
    }
  }

  Future<void> _saveKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('encryption_key', _keyController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('کلید ذخیره شد'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _generateKey() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(32, (index) => chars[random.nextInt(chars.length)]).join();
  }

  void _onGenerateKey() {
    setState(() {
      _keyController.text = _generateKey();
    });
  }

  void _onKeyChanged() {
    // Re-run encryption/decryption when key changes
    _onEncodeInputChanged();
    _onDecodeInputChanged();
  }

  void _onEncodeInputChanged() {
    if (_keyController.text.isEmpty) {
      setState(() {
        _encodeOutput = 'لطفا ابتدا یک کلید ایجاد کنید';
      });
      return;
    }
    
    final input = _encodeInputController.text;
    if (input.isEmpty) {
      setState(() {
        _encodeOutput = '';
      });
      return;
    }

    try {
      final encoded = _encryptText(input, _keyController.text);
      setState(() {
        _encodeOutput = encoded;
      });
    } catch (e) {
      setState(() {
        _encodeOutput = 'خطا در رمزنگاری: ${e.toString()}';
      });
    }
  }

  void _onDecodeInputChanged() {
    if (_keyController.text.isEmpty) {
      setState(() {
        _decodeOutput = 'لطفا ابتدا کلید را وارد کنید';
      });
      return;
    }
    
    final input = _decodeInputController.text;
    if (input.isEmpty) {
      setState(() {
        _decodeOutput = '';
      });
      return;
    }

    try {
      final decoded = _decryptText(input, _keyController.text);
      setState(() {
        _decodeOutput = decoded;
      });
    } catch (e) {
      setState(() {
        _decodeOutput = 'خطا در رمزگشایی: کلید نادرست یا پیام معتبر نیست';
      });
    }
  }

  // AES-256-GCM encryption with proper key derivation
  String _encryptText(String plainText, String key) {
    try {
      // Derive a proper 256-bit key from the user's key using PBKDF2
      final keyBytes = _deriveKey(key);
      final encryptKey = encrypt.Key(keyBytes);
      
      // Generate a random IV for each encryption
      final iv = encrypt.IV.fromSecureRandom(16);
      
      // Create encrypter with AES-256-GCM
      final encrypter = encrypt.Encrypter(
        encrypt.AES(encryptKey, mode: encrypt.AESMode.gcm),
      );
      
      // Encrypt the plain text
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      
      // Combine IV + encrypted data for transmission
      final combined = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
      
      // Convert to base64, then to Persian characters for easy sharing
      final base64Str = base64.encode(combined);
      return _latinToPersian(base64Str);
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  String _decryptText(String encryptedPersian, String key) {
    try {
      // Derive the same key
      final keyBytes = _deriveKey(key);
      final encryptKey = encrypt.Key(keyBytes);
      
      // Convert Persian back to base64
      final base64Str = _persianToLatin(encryptedPersian);
      final combined = base64.decode(base64Str);
      
      // Extract IV (first 16 bytes) and encrypted data
      if (combined.length < 32) { // Minimum: 16 bytes IV + 16 bytes GCM tag
        throw Exception('Invalid encrypted data');
      }
      
      final iv = encrypt.IV(Uint8List.fromList(combined.sublist(0, 16)));
      final encryptedBytes = Uint8List.fromList(combined.sublist(16));
      
      // Create encrypter with AES-256-GCM
      final encrypter = encrypt.Encrypter(
        encrypt.AES(encryptKey, mode: encrypt.AESMode.gcm),
      );
      
      // Decrypt
      final encrypted = encrypt.Encrypted(encryptedBytes);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      
      return decrypted;
    } catch (e) {
      throw Exception('Decryption failed');
    }
  }

  // Generate salt bytes using obfuscated computation
  Uint8List _generateSalt() {
    // Derive salt from mathematical operations to avoid obvious hardcoded strings
    // This ensures deterministic salt generation while obscuring the actual value
    return Uint8List.fromList(
      List.generate(23, (i) => _saltBase + _saltOffsets[i])
    );
  }

  // Derive a 256-bit key from the user's key using PBKDF2
  Uint8List _deriveKey(String userKey) {
    // Use PBKDF2 with SHA-256 to derive a strong key
    // Salt is derived from a constant to ensure same key produces same result
    final salt = _generateSalt();
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, 10000, 32));
    
    return derivator.process(Uint8List.fromList(utf8.encode(userKey)));
  }

  // Character mapping similar to the reference v2ray app
  final Map<String, String> _latinToPersianMap = {
    'a': 'ش', 'b': 'ل', 'c': 'ض', 'd': 'ب', 'e': 'ع', 'f': 'گ', 'g': 'و', 'h': 'ظ',
    'i': 'س', 'j': 'ژ', 'k': 'ک', 'l': 'م', 'm': 'ن', 'n': 'پ', 'o': 'غ', 'p': 'ح',
    'q': 'ز', 'r': 'ط', 's': 'ر', 't': 'ق', 'u': 'ث', 'v': 'ف', 'w': 'ی', 'x': 'د',
    'y': 'ذ', 'z': 'خ',
    'A': 'هش', 'B': 'هل', 'C': 'هض', 'D': 'هب', 'E': 'هع', 'F': 'هگ', 'G': 'هو', 'H': 'هظ',
    'I': 'هس', 'J': 'هژ', 'K': 'هک', 'L': 'هم', 'M': 'هن', 'N': 'هپ', 'O': 'هغ', 'P': 'هح',
    'Q': 'هز', 'R': 'هط', 'S': 'هر', 'T': 'هق', 'U': 'هث', 'V': 'هف', 'W': 'هی', 'X': 'هد',
    'Y': 'هذ', 'Z': 'هخ',
    '0': '۰', '1': '۱', '2': '۲', '3': '۳', '4': '۴', '5': '۵', '6': '۶', '7': '۷',
    '8': '۸', '9': '۹',
    '+': 'ا', '/': 'ت', '=': 'چ',
  };

  late final Map<String, String> _persianToLatinMap = {
    for (var entry in _latinToPersianMap.entries) entry.value: entry.key,
  };

  String _latinToPersian(String latin) {
    final result = StringBuffer();
    for (var i = 0; i < latin.length; i++) {
      final char = latin[i];
      result.write(_latinToPersianMap[char] ?? char);
    }
    return result.toString();
  }

  String _persianToLatin(String persian) {
    final result = StringBuffer();
    var i = 0;
    while (i < persian.length) {
      // Try to match 2-character sequence first (for capital letters)
      if (i + 1 < persian.length) {
        final twoChar = persian.substring(i, i + 2);
        if (_persianToLatinMap.containsKey(twoChar)) {
          result.write(_persianToLatinMap[twoChar]);
          i += 2;
          continue;
        }
      }
      // Try single character
      final oneChar = persian[i];
      result.write(_persianToLatinMap[oneChar] ?? oneChar);
      i++;
    }
    return result.toString();
  }

  Future<void> _copyToClipboard(String text, String successMessage) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'حصار',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade800,
                        width: 1,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'رمزنگاری'),
                      Tab(text: 'رمزگشایی'),
                      Tab(text: 'کلید'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEncodeTab(),
                      _buildDecodeTab(),
                      _buildKeyTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEncodeTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _encodeInputController,
              decoration: const InputDecoration(
                hintText: 'متن خود را وارد کنید...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border.all(color: const Color(0xFF333333)),
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(minHeight: 120),
              child: Text(
                _encodeOutput,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _encodeOutput.isEmpty ? null : () => _copyToClipboard(_encodeOutput, 'کپی شد!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1a1a1a),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ),
              child: const Text('کپی', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecodeTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _decodeInputController,
              decoration: const InputDecoration(
                hintText: 'پیام رمزنگاری شده را وارد کنید...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border.all(color: const Color(0xFF333333)),
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(minHeight: 120),
              child: Text(
                _decodeOutput,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _decodeOutput.isEmpty || _decodeOutput.startsWith('خطا') ? null : () => _copyToClipboard(_decodeOutput, 'کپی شد!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1a1a1a),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ),
              child: const Text('کپی', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'کلید رمزنگاری',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                hintText: 'کلید خود را وارد کنید (یا روی "ایجاد کلید جدید" کلیک کنید)',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _onGenerateKey,
              icon: const Icon(Icons.key),
              label: const Text('ایجاد کلید جدید'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1a1a1a),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _keyController.text.isEmpty ? null : _saveKey,
              icon: const Icon(Icons.save),
              label: const Text('ذخیره کلید'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1a1a1a),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _keyController.text.isEmpty ? null : () => _copyToClipboard(_keyController.text, 'کلید کپی شد!'),
              icon: const Icon(Icons.copy),
              label: const Text('کپی کلید'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1a1a1a),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1a),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'نحوه استفاده:\n\n'
                '۱. یک کلید جدید ایجاد کنید یا کلید خود را مستقیماً وارد کنید\n'
                '۲. کلید را ذخیره کنید تا برای استفاده‌های بعدی نگهداری شود\n'
                '۳. کلید را با فرد مقابل از طریق یک کانال امن به اشتراک بگذارید\n'
                '۴. در تب رمزنگاری، پیام خود را وارد کنید\n'
                '۵. پیام رمزنگاری شده را کپی و ارسال کنید\n'
                '۶. گیرنده با همان کلید می‌تواند پیام را رمزگشایی کند\n\n'
                '⚠️ نکته: کلید را در مکانی امن نگهداری کنید و تنها از طریق کانال‌های رمزنگاری شده به اشتراک بگذارید',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
