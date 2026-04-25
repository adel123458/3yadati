import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const PatientApp());

class PatientApp extends StatelessWidget {
  const PatientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'عيادتي - المريض',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1FAE9A)),
      ),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF1FAE9A),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.favorite, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                'تطبيق عيادتي للمرضى',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 8),
              const Text(
                'قيد التطوير 🚧',
                style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'هذا الهيكل جاهز ليتم بناء واجهة المريض عليه لاحقًا. يستخدم التطبيق نفس الـ Backend ونفس قاعدة البيانات المشتركة مع تطبيق الطبيب.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
