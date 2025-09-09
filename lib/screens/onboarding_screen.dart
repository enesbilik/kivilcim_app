import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GetStorage storage = GetStorage();
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await storage.write('onboardingCompleted', true);
            Get.offAllNamed('/home');
          },
          child: const Text('Başla'),
        ),
      ),
    );
  }
}


