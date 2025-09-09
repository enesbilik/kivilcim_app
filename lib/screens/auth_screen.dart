import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firebase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar('Hata', 'Lütfen tüm alanları doldurun');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSignUp) {
        // Kayıt olma
        final result = await FirebaseService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (result != null) {
          // Kullanıcı verilerini Firestore'a kaydet
          await FirebaseService.saveUserData(result.user!.uid, {
            'email': _emailController.text.trim(),
            'createdAt': DateTime.now().toIso8601String(),
          });
          
          Get.snackbar('Başarılı', 'Hesabınız oluşturuldu');
          Get.offAllNamed('/home');
        }
      } else {
        // Giriş yapma
        final result = await FirebaseService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (result != null) {
          Get.snackbar('Başarılı', 'Giriş yapıldı');
          Get.offAllNamed('/home');
        }
      }
    } catch (e) {
      Get.snackbar('Hata', e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Kayıt Ol' : 'Giriş Yap'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleAuth,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isSignUp ? 'Kayıt Ol' : 'Giriş Yap'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSignUp = !_isSignUp;
                });
              },
              child: Text(
                _isSignUp
                    ? 'Zaten hesabınız var mı? Giriş yapın'
                    : 'Hesabınız yok mu? Kayıt olun',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
