# Security Policy

## Supported Versions

Currently being supported with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Security Features

### Encryption

Hesar uses industry-standard **AES-256-GCM** encryption:

- **Algorithm**: AES (Advanced Encryption Standard) with 256-bit keys
- **Mode**: GCM (Galois/Counter Mode) for authenticated encryption
- **Key Derivation**: PBKDF2 with SHA-256 and 10,000 iterations
- **IV Generation**: Cryptographically secure random IVs for each message

### Key Security Best Practices

1. **Never share your encryption key over insecure channels**
   - Use secure messaging apps with end-to-end encryption
   - Share keys in person when possible
   - Never send keys via SMS, email, or unencrypted messaging

2. **Generate strong, random keys**
   - Use the app's built-in key generator
   - Do not use predictable patterns or personal information
   - Keys should be at least 32 characters long

3. **Store keys securely**
   - The app stores keys locally on your device
   - Ensure your device is password/PIN protected
   - Consider using a password manager for backup

4. **Key rotation**
   - Change encryption keys periodically
   - Generate new keys for different conversation contexts
   - Never reuse keys across different applications

## Known Limitations

⚠️ **Important Security Considerations:**

1. **Local Storage**: Keys are stored in SharedPreferences (Android). While convenient, this is not the most secure storage method. Users with rooted devices or those who grant storage permissions to malicious apps may be at risk.

2. **No Forward Secrecy**: The same key is used for all messages. If a key is compromised, all past and future messages can be decrypted.

3. **Key Distribution**: The app does not provide a secure channel for key exchange. Users must establish their own secure method for sharing keys.

4. **Device Security**: If your device is compromised (malware, physical access), the stored key may be accessible to attackers.

## Reporting a Vulnerability

If you discover a security vulnerability in Hesar, please report it by:

1. **DO NOT** open a public GitHub issue
2. Contact the maintainer directly through GitHub private channels
3. Provide a detailed description of the vulnerability
4. Include steps to reproduce if possible

We will:
- Acknowledge receipt within 48 hours
- Provide a timeline for addressing the issue
- Credit you in the fix (unless you prefer to remain anonymous)

## Security Roadmap

Future security improvements under consideration:

- [ ] Migrate to Android Keystore for secure key storage
- [ ] Implement perfect forward secrecy with ephemeral keys
- [ ] Add secure key exchange protocol (e.g., Diffie-Hellman)
- [ ] Implement biometric authentication for app access
- [ ] Add key expiration and automatic rotation
- [ ] Support for X25519/ChaCha20-Poly1305 cipher suite

## Security Testing

### Encryption Testing

The encryption implementation has been:
- ✅ Tested against NIST test vectors for AES-GCM
- ✅ Verified key derivation with PBKDF2 standards
- ✅ Validated IV uniqueness across multiple encryptions

### Code Security

- ✅ ProGuard/R8 obfuscation enabled in release builds
- ✅ No sensitive data logging in release builds
- ✅ TLS/SSL for any network communications (if applicable)

## Responsible Disclosure

We follow responsible disclosure practices:
- Security fixes are prioritized
- We coordinate with reporters before public disclosure
- We provide credit to researchers who report vulnerabilities

## Additional Resources

- [OWASP Mobile Security Testing Guide](https://owasp.org/www-project-mobile-security-testing-guide/)
- [Android Security Best Practices](https://developer.android.com/topic/security/best-practices)
- [NIST Cryptographic Standards](https://csrc.nist.gov/projects/cryptographic-standards-and-guidelines)

---

**Last Updated**: 2024-12-31
