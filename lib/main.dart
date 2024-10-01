
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

void main() => runApp(AyahuascaVisionApp());

class AyahuascaVisionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ayahuasca Vision',
      home: VisionScreen(),
    );
  }
}

class VisionScreen extends StatefulWidget {
  @override
  _VisionScreenState createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _climbOffset = 0;
  bool _musicStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 30))
      ..repeat(); // Slower animation for smoother transitions
  }

  Future<void> _playMusic() async {
    if (!_musicStarted) {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('1.mp3')); // Play background music
      setState(() {
        _musicStarted = true; // Prevent multiple plays
      });
    }
  }

  void _startClimbing() {
    _controller.addListener(() {
      setState(() {
        _climbOffset = _controller.value * 500; // Adjust climb speed and height
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          _playMusic();
          _startClimbing();
        },
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: VisionPainter(_controller.value, _climbOffset),
                  child: Container(),
                );
              },
            ),
            if (!_musicStarted)  // Show the message only until the music starts
              Center(
                child: Text(
                  'Tap to Start the Vision',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class VisionPainter extends CustomPainter {
  final double progress;
  final double climbOffset;
  VisionPainter(this.progress, this.climbOffset);

  final Random random = Random();
  final List<Color> gradientColors = [Colors.blue, Colors.green, Colors.purple, Colors.orange];

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackgroundGradient(canvas, size);
    _drawFloatingOrbs(canvas, size);
    _drawGlowingFigures(canvas, size);
  }

  void _drawBackgroundGradient(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      colors: [
        gradientColors[random.nextInt(gradientColors.length)],
        gradientColors[random.nextInt(gradientColors.length)],
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final rect = Rect.fromLTWH(0, -climbOffset, size.width, size.height + climbOffset);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawFloatingOrbs(Canvas canvas, Size size) {
    for (int i = 0; i < 5; i++) {
      final radius = 30 + 20 * sin(progress * 2 * pi + i); // Pulsating effect
      final x = size.width * 0.5 + cos(progress * 2 * pi + i) * (i * 40);
      final y = size.height * 0.5 + sin(progress * 2 * pi + i) * (i * 40) - climbOffset;

      final orbPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius / 2); // Glow effect

      canvas.drawCircle(Offset(x, y), radius, orbPaint);
    }
  }

  void _drawGlowingFigures(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      final glowRadius = 50 + 10 * sin(progress * 2 * pi + i); // Expanding glow effect
      final x = size.width * 0.4 + (i * 100);
      final y = size.height * 0.75 - climbOffset; // Move figures up during "climb"

      final glowPaint = Paint()
        ..color = Colors.yellow.withOpacity(0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, glowRadius); // Outer glow effect

      canvas.drawCircle(Offset(x, y), glowRadius, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
