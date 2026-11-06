import 'dart:math';

/// عنصر ساقط: نجمة أو قنبلة. الإحداثيات كسور من عرض/ارتفاع الشاشة.
class Item {
  Item({
    required this.x,
    required this.y,
    required this.vy,
    required this.bomb,
  });

  double x;
  double y;
  final double vy;
  final bool bomb;
  double spin = 0;
}

/// منطق اللعبة فقط (بلا واجهة).
class World {
  static const double basketW = 0.24;
  static const double basketY = 0.88;
  static const double itemR = 0.045;
  static const int maxLives = 3;

  final Random _rnd = Random();
  final List<Item> items = <Item>[];

  double basketX = 0.5;
  double targetX = 0.5;
  int score = 0;
  int lives = maxLives;
  bool over = false;
  double flash = 0; // وميض أحمر عند الإصابة
  double _spawn = 0.6;

  /// يُستدعى عند الالتقاط: true = قنبلة، false = نجمة.
  void Function(bool bomb)? onHit;

  double get _speed => 1 + min(score / 30, 1.6);

  void update(double dt) {
    if (over) {
      return;
    }
    basketX += (targetX - basketX) * min(1.0, dt * 18);
    if (flash > 0) {
      flash = max(0.0, flash - dt * 2.5);
    }

    _spawn -= dt;
    if (_spawn <= 0) {
      _spawn = max(0.32, 0.85 - score * 0.008);
      final double bombChance = min(0.3, 0.12 + score * 0.004);
      items.add(Item(
        x: 0.08 + _rnd.nextDouble() * 0.84,
        y: -0.05,
        vy: (0.26 + _rnd.nextDouble() * 0.12) * _speed,
        bomb: _rnd.nextDouble() < bombChance,
      ));
    }

    for (int i = items.length - 1; i >= 0; i--) {
      final Item it = items[i];
      it.y += it.vy * dt;
      it.spin += dt * 3;

      final bool inBand = it.y >= basketY - 0.05 && it.y <= basketY + 0.03;
      final bool inReach = (it.x - basketX).abs() <= basketW / 2 + itemR * 0.6;
      if (inBand && inReach) {
        items.removeAt(i);
        if (it.bomb) {
          _hurt();
          onHit?.call(true);
        } else {
          score++;
          onHit?.call(false);
        }
      } else if (it.y > 1.06) {
        items.removeAt(i);
        if (!it.bomb) {
          _hurt(); // تفويت نجمة يكلّف قلباً
        }
      }
      if (over) {
        break;
      }
    }
  }

  void _hurt() {
    lives--;
    flash = 1;
    if (lives <= 0) {
      lives = 0;
      over = true;
    }
  }
}
