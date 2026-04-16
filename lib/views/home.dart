import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

class WeddingCardScreen extends StatefulWidget {
  const WeddingCardScreen({super.key});

  @override
  State<WeddingCardScreen> createState() => _WeddingCardScreenState();
}

class _WeddingCardScreenState extends State<WeddingCardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatingController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideInAnimation;

  late ConfettiController _confettiController;
  late AudioPlayer _audioPlayer;

  bool? _rsvpStatus; // null = pending, true = attending, false = declining

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 60),
    );
    _audioPlayer = AudioPlayer();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _fadeInAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideInAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
        );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatingController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _celebrate() async {
    setState(() {
      _rsvpStatus = true;
    });
    _confettiController.play();

    // Play the local wedding song asset
    try {
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(AssetSource('audio/weddingsong.mp3'));
      
      // Stop everything after exactly 1 minute
      Future.delayed(const Duration(minutes: 1), () {
        if (mounted) {
          _audioPlayer.stop();
          _confettiController.stop();
        }
      });
    } catch (e) {
      debugPrint("Audio play error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Audio error: $e")));
      }
    }
  }

  void _decline() {
    setState(() {
      _rsvpStatus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F5),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Texture/Gradient
          _buildBackground(),

          // Animated Floral Elements (Live Feel)
          _buildFloatingFlower(
            top: -20,
            right: -20,
            image: "assets/images/watercolor_floral_top_right.png",
            width: 300,
            angle: 0.1,
          ),
          _buildFloatingFlower(
            bottom: -30,
            left: -30,
            image: "assets/images/watercolor_floral_bottom_left.png",
            width: 350,
            angle: -0.05,
          ),

          // Main Content
          Center(
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: SlideTransition(
                  position: _slideInAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 40,
                    ),
                    padding: const EdgeInsets.all(32),
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: ElegantBorderPainter()),
                        ),
                        _buildContent(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Confetti Overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: true,
              colors: const [
                Colors.pink,
                Colors.orange,
                Color.fromARGB(255, 167, 151, 2),
                Colors.white,
                Colors.brown,
              ],
              createParticlePath: _drawStar,
            ),
          ),
        ],
      ),
    );
  }

  Path _drawStar(Size size) {
    // Method to draw a star shape for confetti
    double degToRad(double deg) => deg * (math.pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * math.cos(step),
        halfWidth + externalRadius * math.sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * math.sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAE3DF), Color(0xFFF4EEEA), Color(0xFFEAE3DF)],
        ),
      ),
      child: Opacity(
        opacity: 0.03,
        child: Image.network(
          "https://www.transparenttextures.com/patterns/paper-fibers.png",
          repeat: ImageRepeat.repeat,
        ),
      ),
    );
  }

  Widget _buildFloatingFlower({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required String image,
    required double width,
    required double angle,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          return Transform.rotate(
            angle:
                angle +
                (math.sin(_floatingController.value * 2 * math.pi) * 0.02),
            child: Transform.translate(
              offset: Offset(
                0,
                math.sin(_floatingController.value * 2 * math.pi) * 10,
              ),
              child: child,
            ),
          );
        },
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            1, 0, 0, 0, 0,
            0, 1, 0, 0, 0,
            0, 0, 1, 0, 0,
            -0.33, -0.33, -0.33, 1, 1, // Smart alpha-from-white filter
          ]),
          child: Image.asset(
            image,
            width: width,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 60),

        Text(
          "PLEASE JOIN US FOR THE",
          style: GoogleFonts.playfairDisplay(
            fontSize: 14,
            letterSpacing: 4,
            color: Colors.brown.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 20),

        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.brown.shade900, Colors.brown.shade400],
          ).createShader(bounds),
          child: Text(
            "Wedding",
            style: GoogleFonts.greatVibes(fontSize: 84, color: Colors.white),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          "OF",
          style: GoogleFonts.playfairDisplay(
            fontSize: 14,
            letterSpacing: 2,
            fontStyle: FontStyle.italic,
          ),
        ),

        const SizedBox(height: 40),

        /// Names Section
        ScaleTransition(
          scale: Tween<double>(
            begin: 1.0,
            end: 1.03,
          ).animate(_floatingController),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 20,
            runSpacing: 10,
            children: [
              _buildNameColumn("AAZIM", "NAUSHAD"),
              Text(
                "&",
                style: GoogleFonts.greatVibes(
                  fontSize: 60,
                  color: Colors.brown.shade300,
                ),
              ),
              _buildNameColumn("RASHMIKA", "MANDANNA"),
            ],
          ),
        ),

        const SizedBox(height: 50),

        /// Date Row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: Colors.brown.shade100, width: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDateInfo("JUL", "MONTH"),
              _buildDateInfo("27", "SATURDAY"),
              _buildDateInfo("4:30", "PM"),
            ],
          ),
        ),

        const SizedBox(height: 40),

        Text(
          "HAMINGTON BEACH & RESORT",
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          "MIAMI, FLORIDA",
          style: GoogleFonts.playfairDisplay(
            fontSize: 14,
            letterSpacing: 1,
            color: Colors.brown.shade600,
          ),
        ),

        const SizedBox(height: 30),

        Text(
          "RECEPTION TO FOLLOW",
          style: GoogleFonts.playfairDisplay(
            fontSize: 12,
            letterSpacing: 3,
            color: Colors.brown.shade300,
          ),
        ),

        const SizedBox(height: 40),

        /// RSVP Section
        _buildRSVPSection(),

        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildRSVPSection() {
    if (_rsvpStatus == null) {
      return Column(
        children: [
          Text(
            "WILL YOU ATTEND?",
            style: GoogleFonts.playfairDisplay(
              fontSize: 14,
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade800,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildRSVPButton(
                text: "YES, I WILL ATTEND",
                onPressed: _celebrate,
                isPrimary: true,
              ),
              _buildRSVPButton(
                text: "UNFORTUNATELY NO",
                onPressed: _decline,
                isPrimary: false,
              ),
            ],
          ),
        ],
      );
    } else {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Column(
          key: ValueKey(_rsvpStatus),
          children: [
            Icon(
              _rsvpStatus! ? Icons.favorite : Icons.sentiment_very_dissatisfied,
              color: Colors.brown.shade300,
              size: 40,
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                _rsvpStatus!
                    ? "WE CAN'T WAIT TO SEE \nYOU!"
                    : "WE WILL MISS YOU!",
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _rsvpStatus!
                  ? "Thank you for joining our special day."
                  : "We're sorry you can't make it, but we'll celebrate in spirit!",
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 12,
                color: Colors.brown.shade400,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => setState(() => _rsvpStatus = null),
              child: Text(
                "Change RSVP",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 10,
                  decoration: TextDecoration.underline,
                  color: Colors.brown.shade300,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildRSVPButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.brown.shade700 : Colors.white,
        foregroundColor: isPrimary ? Colors.white : Colors.brown.shade700,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        side: BorderSide(color: Colors.brown.shade100, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(
        text,
        style: GoogleFonts.playfairDisplay(
          fontSize: 10,
          letterSpacing: 1,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNameColumn(String first, String last) {
    return Column(
      children: [
        Text(
          first,
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          last,
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            letterSpacing: 2,
            color: Colors.brown.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(String value, String label) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.playfairDisplay(
            fontSize: 10,
            letterSpacing: 2,
            color: Colors.brown.shade400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class ElegantBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade100
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);

    // Draw an elegant double border frame
    canvas.drawRect(rect, paint);
    canvas.drawRect(
      Rect.fromLTWH(15, 15, size.width - 30, size.height - 30),
      paint..strokeWidth = 0.5,
    );

    // Corner Ornaments
    _drawCorner(canvas, Offset(10, 10), 0, paint);
    _drawCorner(canvas, Offset(size.width - 10, 10), math.pi / 2, paint);
    _drawCorner(
      canvas,
      Offset(size.width - 10, size.height - 10),
      math.pi,
      paint,
    );
    _drawCorner(canvas, Offset(10, size.height - 10), 3 * math.pi / 2, paint);
  }

  void _drawCorner(Canvas canvas, Offset offset, double angle, Paint paint) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(angle);

    final path = Path()
      ..moveTo(0, 30)
      ..lineTo(0, 0)
      ..lineTo(30, 0);

    canvas.drawPath(path, paint..strokeWidth = 2.0);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
