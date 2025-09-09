import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final GetStorage _storage = GetStorage();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await _storage.write('onboardingCompleted', true);
    Get.offAllNamed('/home');
  }

  void _handleNext() {
    if (_currentPage == 2) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFF94616);
    final Color secondaryColor = const Color(0xFF6C63FF);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Stack(
            children: [
              // Ana içerik
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  _fadeController.reset();
                  _slideController.reset();
                  _fadeController.forward();
                  _slideController.forward();
                },
                children: [
                  _ModernOnboardingPage(
                    title: 'Widget Nasıl Eklenir?',
                    subtitle: 'Ana ekranda boş bir alana uzun basarak veya uygulama ikonuna basılı tutarak widget ekleyebilirsiniz.',
                    content: _buildStep1Content(),
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                  ),
                  _ModernOnboardingPage(
                    title: 'Widget\'ı Seçin',
                    subtitle: 'Listeden uygulamanızın widget\'ını bulun ve ekleyin.',
                    content: _buildStep2Content(),
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                  ),
                  _ModernOnboardingPage(
                    title: 'Hazır!',
                    subtitle: 'Artık widget\'ınız ana ekranda 🎉',
                    content: _buildStep3Content(),
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                  ),
                ],
              ),

              // Modern dots indicator
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.of(context).padding.bottom + 120,
                child: _buildModernDots(),
              ),

              // Modern buton grubu
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.of(context).padding.bottom + 40,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildModernButtons(primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildStep1Content() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAnimatedImage(
            'assets/images/white-hand-tap-to-screen 1.png',
            120,
            const Offset(-0.1, 0),
          ),
          _buildAnimatedImage(
            'assets/images/Untitled.png',
            120,
            const Offset(0.1, 0),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Content() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: _buildAnimatedImage(
        'assets/images/Frame 1 (1).png',
        160,
        Offset.zero,
      ),
    );
  }

  Widget _buildStep3Content() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Lottie.asset(
        'assets/lotties/success.json',
        width: 200,
        height: 200,
        repeat: true,
        animate: true,
      ),
    );
  }

  Widget _buildAnimatedImage(String asset, double size, Offset offset) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: offset,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.elasticOut,
      )),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildModernDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final bool active = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: active ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFF94616) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFFF94616).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildModernButtons(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: _ModernButton(
              label: 'Skip',
              onTap: _completeOnboarding,
              isPrimary: false,
              primaryColor: primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ModernButton(
              label: _currentPage == 2 ? 'Finish' : 'Next',
              onTap: _handleNext,
              isPrimary: true,
              primaryColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernOnboardingPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final Color primaryColor;
  final Color secondaryColor;

  const _ModernOnboardingPage({
    required this.title,
    required this.content,
    required this.primaryColor,
    required this.secondaryColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Üst boşluk
          const Spacer(flex: 1),
          
          // Ana içerik
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Resim/İçerik
              Padding(
                padding: const EdgeInsets.all(24),
                child: content,
              ),
              
              const SizedBox(height: 40),
              
              // Başlık
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[900],
                  letterSpacing: -0.5,
                ),
              ),
              
              if (subtitle != null) ...[
                const SizedBox(height: 16),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
          
          // Alt boşluk
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _ModernButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final Color primaryColor;

  const _ModernButton({
    required this.label,
    required this.onTap,
    required this.isPrimary,
    required this.primaryColor,
  });

  @override
  State<_ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<_ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: widget.isPrimary
                    ? LinearGradient(
                        colors: [widget.primaryColor, widget.primaryColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: widget.isPrimary ? null : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: widget.isPrimary
                    ? null
                    : Border.all(color: Colors.grey[300]!, width: 2),
                boxShadow: widget.isPrimary
                    ? [
                        BoxShadow(
                          color: widget.primaryColor.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isPrimary ? Colors.white : Colors.grey[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


