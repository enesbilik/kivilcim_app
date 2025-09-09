import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color brandColor = const Color(0xFFF94616);
  final GetStorage storage = GetStorage();
  bool notificationsEnabled = false;
  String dailyQuote = 'Pozitif enerjin etrafını aydınlatır. 🌞'; // Varsayılan quote
  bool isLoadingQuote = true;

  @override
  void initState() {
    super.initState();
    notificationsEnabled = storage.read('notificationsEnabled') == true;
    _loadDailyQuote();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  // Günlük quote'u yükle
  Future<void> _loadDailyQuote() async {
    try {
      setState(() {
        isLoadingQuote = true;
      });
      
      final quoteData = await FirebaseService.getDailyQuote();
      if (quoteData != null && quoteData['quote'] != null) {
        setState(() {
          dailyQuote = quoteData['quote'].toString();
          isLoadingQuote = false;
        });
      } else {
        setState(() {
          isLoadingQuote = false;
        });
      }
    } catch (e) {
      print('Günlük quote yükleme hatası: $e');
      setState(() {
        isLoadingQuote = false;
      });
    }
  }


  void toggleNotifications(bool value) {
    setState(() {
      notificationsEnabled = value;
    });
    storage.write('notificationsEnabled', value);
    // ignore: avoid_print
    print('Bildirim izni: $value');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Başlıklar
              Text(
                'Kıvılcım 🔥',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Günün küçük anlarında seni hatırlayan uygulama',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 20),

              // Bugünün Sözü
              _Card(
                background: brandColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _CardTitle(text: 'Bugünün Sözü ✨'),
                        
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (isLoadingQuote)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Yükleniyor...',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      )
                    else
                      Text(
                        dailyQuote,
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                  ],
                ),
              ),

              // Bildirimler
              _Card(
                background: brandColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _CardTitle(text: '🔔 Bildirimler'),
                        _PrettySwitch(
                          value: notificationsEnabled,
                          onChanged: toggleNotifications,
                          activeColor: const Color(0xFFFFE3DA),
                          inactiveColor: const Color(0xFFEEEEEE),
                          thumbActiveColor: Color(0xFFF94616),
                          thumbInactiveColor: const Color(0xFF888888),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Günün rastgele saatlerinde pozitif mesajlar göndeririz.',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    if (!notificationsEnabled)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Bildirim izni kapalı. Ayarlardan izin verebilirsiniz.',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),

              // Ana Ekran Widget'ı
              _Card(
                background: brandColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _CardTitle(text: '📱 Ana Ekran Widget\'ı'),
                    const SizedBox(height: 4),
                    const Text(
                      'Ana ekranına motivasyon widget’ı eklemek ister misin?',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Get.toNamed('/onboarding'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Widget Ekleme Adımlarını Göster',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: brandColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Geri Bildirim
              _Card(
                background: brandColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _CardTitle(text: '💬 Geri Bildirim'),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Bize Yaz',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: brandColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final Color background;
  const _Card({required this.child, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String text;
  const _CardTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}

class _PrettySwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final Color thumbActiveColor;
  final Color thumbInactiveColor;

  const _PrettySwitch({
    required this.value,
    required this.onChanged,
    required this.activeColor,
    required this.inactiveColor,
    required this.thumbActiveColor,
    required this.thumbInactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 28 : 0,
              right: value ? 0 : 28,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: value ? thumbActiveColor : thumbInactiveColor,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


