import 'package:flutter/material.dart';

import '../game/save.dart';
import 'game_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  void _help(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('طريقة اللعب'),
          content: const Text(
            '• حرّك إصبعك يميناً ويساراً لتحريك السلّة.\n'
            '• التقط النجوم ⭐ لتزيد نتيجتك.\n'
            '• تجنّب القنابل 💣، فكل قنبلة تكلّفك قلباً.\n'
            '• تفويت نجمة يكلّفك قلباً أيضاً.\n'
            '• لديك 3 قلوب، والسرعة تزداد مع تقدّمك.',
            style: TextStyle(height: 1.7),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('حسناً'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF0B1026), Color(0xFF1B2A5C)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset('assets/cover.png', fit: BoxFit.cover),
                    ),
                  ),
                  const Text(
                    'صائد النجوم',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD54F),
                      shadows: <Shadow>[
                        Shadow(color: Color(0xFFFFC107), blurRadius: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedBuilder(
                    animation: Save.instance,
                    builder: (BuildContext context, Widget? child) {
                      return Text(
                        '🏆 أفضل نتيجة: ${Save.instance.best}',
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 240,
                    height: 50,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (BuildContext ctx) => const GameScreen(),
                        ),
                      ),
                      child: const Text('ابدأ اللعب', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 240,
                    height: 46,
                    child: FilledButton.tonal(
                      onPressed: () => _help(context),
                      child: const Text('طريقة اللعب'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
