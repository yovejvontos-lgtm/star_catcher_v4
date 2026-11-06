import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../game/painter.dart';
import '../game/save.dart';
import '../game/world.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late World _world;
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  Ticker? _ticker;
  Duration _last = Duration.zero;

  int _hudScore = 0;
  int _hudLives = World.maxLives;
  bool _overShown = false;
  bool _record = false;

  @override
  void initState() {
    super.initState();
    _world = _newWorld();
    _ticker = createTicker(_onTick)..start();
  }

  World _newWorld() {
    final World w = World();
    w.onHit = (bool bomb) {
      if (bomb) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    };
    return w;
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _frame.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    double dt = (elapsed - _last).inMicroseconds / 1000000.0;
    _last = elapsed;
    if (dt < 0) {
      dt = 0;
    }
    if (dt > 0.05) {
      dt = 0.05;
    }
    _world.update(dt);
    _frame.value++;

    if (_world.score != _hudScore || _world.lives != _hudLives) {
      setState(() {
        _hudScore = _world.score;
        _hudLives = _world.lives;
      });
    }

    if (_world.over && !_overShown) {
      _overShown = true;
      Save.instance.submit(_world.score).then((bool rec) {
        if (mounted) {
          setState(() {
            _record = rec;
          });
        }
      });
      setState(() {});
    }
  }

  void _restart() {
    setState(() {
      _world = _newWorld();
      _hudScore = 0;
      _hudLives = World.maxLives;
      _overShown = false;
      _record = false;
    });
  }

  void _move(double dx, double width) {
    if (width <= 0) {
      return;
    }
    _world.targetX = (dx / width).clamp(0.12, 0.88).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (PointerDownEvent e) =>
                    _move(e.localPosition.dx, box.maxWidth),
                onPointerMove: (PointerMoveEvent e) =>
                    _move(e.localPosition.dx, box.maxWidth),
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: WorldPainter(_world, _frame),
                    size: Size.infinite,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                      Expanded(
                        child: Text(
                          '⭐ $_hudScore',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '❤️' * _hudLives + '🖤' * (World.maxLives - _hudLives),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              if (_world.over)
                Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xEE0B1026),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFC107), width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          'انتهت اللعبة',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('نتيجتك: ${_world.score}', style: const TextStyle(fontSize: 20)),
                        if (_record)
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Text(
                              '🏆 رقم قياسي جديد!',
                              style: TextStyle(fontSize: 16, color: Color(0xFFFFC107)),
                            ),
                          ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            FilledButton(onPressed: _restart, child: const Text('العب مجدداً')),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('القائمة'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
