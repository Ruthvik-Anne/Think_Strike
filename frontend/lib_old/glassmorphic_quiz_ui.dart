// glassmorphic_quiz_ui.dart
// A self-contained Flutter UI file that implements a glassmorphic, beige-based
// quiz list and components with hover shimmer/ripple effects and smooth
// animations. Drop this into `frontend/lib/` and import it from your app's
// main.dart (see integration notes at the end).

import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// -----------------------------
// Color palette (beige/light)
// -----------------------------
class BeigePalette {
  static const Color baseBackground = Color(0xFFFAF7F1); // off-white beige
  static const Color cream = Color(0xFFF6EFE6);
  static const Color sand = Color(0xFFE8D9C3);
  static const Color gold = Color(0xFFD9BC7A);
  static const Color tan = Color(0xFFD6C4A3);
  static const Color softBrown = Color(0xFF9B8663);
  static const Color textPrimary = Color(0xFF4B3F34);

  // Difficulty pastel glows
  static const Color easy = Color(0xFFDFF7E6);
  static const Color medium = Color(0xFFFFF1E6);
  static const Color hard = Color(0xFFFFE6E6);
}

// -----------------------------
// Glass container (reusable)
// -----------------------------
class GlassContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double blur;
  final Color overlayColor;
  final BoxShadow? shadow;

  const GlassContainer({
    Key? key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding = const EdgeInsets.all(16),
    this.blur = 12.0,
    this.overlayColor = const Color(0x66FFFFFF),
    this.shadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: overlayColor,
            borderRadius: borderRadius,
            boxShadow: [
              shadow ?? BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: Offset(0, 8),
              )
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// -----------------------------
// Hoverable glass card with shimmer/ripple
// -----------------------------
class GlassQuizCard extends StatefulWidget {
  final String title;
  final String description;
  final String difficulty; // "Easy" "Medium" "Hard"
  final int timeMinutes;
  final int questionCount;
  final VoidCallback? onTap;

  const GlassQuizCard({
    Key? key,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.timeMinutes,
    required this.questionCount,
    this.onTap,
  }) : super(key: key);

  @override
  _GlassQuizCardState createState() => _GlassQuizCardState();
}

class _GlassQuizCardState extends State<GlassQuizCard>
    with SingleTickerProviderStateMixin {
  bool hovering = false;
  Offset hoverPos = Offset.zero;
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent details) {
    setState(() {
      hovering = true;
      hoverPos = details.localPosition;
    });
    _hoverController.forward(from: 0.0);
  }

  void _onHover(PointerEvent details) {
    setState(() {
      hoverPos = details.localPosition;
    });
  }

  void _onExit(PointerEvent details) {
    setState(() {
      hovering = false;
    });
    _hoverController.reverse();
  }

  Color _difficultyGlow() {
    switch (widget.difficulty.toLowerCase()) {
      case 'easy':
        return BeigePalette.easy;
      case 'medium':
        return BeigePalette.medium;
      case 'hard':
        return BeigePalette.hard;
      default:
        return BeigePalette.cream;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = hovering ? 1.02 : 1.0;

    return MouseRegion(
      onEnter: _onEnter,
      onHover: _onHover,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: Duration(milliseconds: 250),
          scale: scale,
          curve: Curves.easeOut,
          child: Stack(
            children: [
              // rippled glass card base
              GlassContainer(
                borderRadius: BorderRadius.circular(20),
                padding: EdgeInsets.all(16),
                blur: 10.0,
                overlayColor:
                    Colors.white.withOpacity(0.55), // light beige glass
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // left icon column
                    Column(
                      children: [
                        _IconCircle(icon: Icons.book_rounded),
                        SizedBox(height: 12),
                        _IconCircle(icon: Icons.access_time_rounded),
                        SizedBox(height: 12),
                        _IconCircle(icon: Icons.list_alt_rounded),
                      ],
                    ),
                    SizedBox(width: 14),
                    // main content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: BeigePalette.textPrimary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              DifficultyBadge(
                                difficulty: widget.difficulty,
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            widget.description,
                            style: TextStyle(
                              color: BeigePalette.softBrown.withOpacity(0.9),
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              _SmallInfo(icon: Icons.access_time_rounded, text: "${widget.timeMinutes}m"),
                              SizedBox(width: 12),
                              _SmallInfo(icon: Icons.help_outline_rounded, text: "${widget.questionCount} q"),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // shimmer/water overlay on hover
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: AnimatedBuilder(
                    animation: _hoverController,
                    builder: (context, child) {
                      if (!hovering && _hoverController.value == 0) return SizedBox.shrink();

                      final progress = _hoverController.value;

                      return CustomPaint(
                        painter: _HoverRipplePainter(
                          center: hoverPos,
                          progress: progress,
                          color: _difficultyGlow().withOpacity(0.25),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  const _IconCircle({Key? key, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: BeigePalette.cream.withOpacity(0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 18,
          color: BeigePalette.softBrown,
        ),
      ),
    );
  }
}

class _SmallInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SmallInfo({Key? key, required this.icon, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: BeigePalette.softBrown.withOpacity(0.85)),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: BeigePalette.softBrown.withOpacity(0.85), fontSize: 13),
        )
      ],
    );
  }
}

// -----------------------------
// Difficulty badge
// -----------------------------
class DifficultyBadge extends StatefulWidget {
  final String difficulty;
  const DifficultyBadge({Key? key, required this.difficulty}) : super(key: key);

  @override
  _DifficultyBadgeState createState() => _DifficultyBadgeState();
}

class _DifficultyBadgeState extends State<DifficultyBadge> {
  bool hovering = false;

  Color get _bg {
    switch (widget.difficulty.toLowerCase()) {
      case 'easy':
        return BeigePalette.easy;
      case 'medium':
        return BeigePalette.medium;
      case 'hard':
        return BeigePalette.hard;
      default:
        return BeigePalette.cream;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: hovering ? [BoxShadow(color: _bg.withOpacity(0.45), blurRadius: 18, spreadRadius: 1)] : [],
        ),
        child: Text(
          widget.difficulty,
          style: TextStyle(
            color: BeigePalette.softBrown,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// -----------------------------
// Shimmering header and pill filters
// -----------------------------
class GlassHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<String> categories;
  final ValueChanged<String>? onCategorySelected;

  const GlassHeader({Key? key, required this.title, required this.categories, this.onCategorySelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: GlassContainer(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        overlayColor: Colors.white.withOpacity(0.5),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: BeigePalette.textPrimary,
              ),
            ),
            Spacer(),
            Row(
              children: categories.map((c) => _CategoryPill(text: c, onTap: () => onCategorySelected?.call(c))).toList(),
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(76);
}

class _CategoryPill extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  const _CategoryPill({Key? key, required this.text, this.onTap}) : super(key: key);

  @override
  __CategoryPillState createState() => __CategoryPillState();
}

class __CategoryPillState extends State<_CategoryPill> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 220),
          margin: EdgeInsets.symmetric(horizontal: 6),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [BeigePalette.cream, BeigePalette.sand],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: hovering ? [BoxShadow(color: BeigePalette.gold.withOpacity(0.18), blurRadius: 14, offset: Offset(0,6))] : [],
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Text(widget.text, style: TextStyle(color: BeigePalette.softBrown, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// -----------------------------
// Animated vertical list of quiz cards (with staggered fade-in)
// -----------------------------
class AnimatedQuizList extends StatefulWidget {
  final List<Map<String, dynamic>> quizzes; // list of quiz metadata
  const AnimatedQuizList({Key? key, required this.quizzes}) : super(key: key);

  @override
  _AnimatedQuizListState createState() => _AnimatedQuizListState();
}

class _AnimatedQuizListState extends State<AnimatedQuizList> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    // start entrance animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (context, index) {
        final quiz = widget.quizzes[index];
        final start = index * 0.08;
        final end = start + 0.4;
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(start.clamp(0.0,1.0), end.clamp(0.0,1.0), curve: Curves.easeOut),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(
              opacity: animation.value,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - animation.value)),
                child: Transform.scale(
                  scale: 0.98 + 0.02 * animation.value,
                  child: child,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: GlassQuizCard(
              title: quiz['title'],
              description: quiz['description'],
              difficulty: quiz['difficulty'],
              timeMinutes: quiz['time'],
              questionCount: quiz['questions'],
              onTap: () {
                // placeholder: open quiz
                if (kDebugMode) print('Open quiz ${quiz['title']}');
              },
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => SizedBox(height: 14),
      itemCount: widget.quizzes.length,
    );
  }
}

// -----------------------------
// Small painter for ripple effect
// -----------------------------
class _HoverRipplePainter extends CustomPainter {
  final Offset center;
  final double progress; // 0.0 -> 1.0
  final Color color;

  _HoverRipplePainter({required this.center, required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.001) return;

    final maxRadius = sqrt(size.width * size.width + size.height * size.height);
    final radius = lerpDouble(0, maxRadius, Curves.easeOut.transform(progress))!;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [color.withOpacity(0.45 * (1 - progress)), color.withOpacity(0.02)],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _HoverRipplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.center != center;
  }
}

// -----------------------------
// Example scaffold that composes everything
// -----------------------------
class GlassQuizHomePage extends StatelessWidget {
  final List<Map<String, dynamic>> sampleQuizzes;
  const GlassQuizHomePage({Key? key, required this.sampleQuizzes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeigePalette.baseBackground,
      appBar: GlassHeader(title: 'ThinkStrike', categories: ['All', 'Math', 'Science', 'History'], onCategorySelected: (c) { if (kDebugMode) print('Category: $c'); }),
      body: Row(
        children: [
          // left spacing column (for layout on wide screens)
          Expanded(
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 920),
                child: AnimatedQuizList(quizzes: sampleQuizzes),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(label: 'New Quiz', onPressed: () { if (kDebugMode) print('New quiz'); }),
            SizedBox(width: 12),
            _ActionButton(label: 'Browse', onPressed: () { if (kDebugMode) print('Browse'); }),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  const _ActionButton({Key? key, required this.label, required this.onPressed}) : super(key: key);

  @override
  __ActionButtonState createState() => __ActionButtonState();
}

class __ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  bool hovering = false;
  late AnimationController shimmer;

  @override
  void initState() {
    super.initState();
    shimmer = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [BeigePalette.cream, BeigePalette.sand]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: hovering ? [BoxShadow(color: BeigePalette.gold.withOpacity(0.18), blurRadius: 24, offset: Offset(0,8))] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: Offset(0,6))],
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // subtle shimmer overlay
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: shimmer,
                  builder: (context, child) {
                    return Opacity(
                      opacity: hovering ? 0.65 : 0.25,
                      child: FractionallySizedBox(
                        widthFactor: 1.4,
                        alignment: Alignment(-1.0 + 2.0 * shimmer.value, 0),
                        child: Container(
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white.withOpacity(0.0), Colors.white.withOpacity(0.16), Colors.white.withOpacity(0.0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Text(widget.label, style: TextStyle(color: BeigePalette.softBrown, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

/*
How to integrate this file into your Flutter app

1) Place this file at: frontend/lib/glassmorphic_quiz_ui.dart

2) In your main.dart, import and use `GlassQuizHomePage` with sample data:

import 'package:flutter/material.dart';
import 'glassmorphic_quiz_ui.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ThinkStrike - Glass UI',
      theme: ThemeData(
        scaffoldBackgroundColor: BeigePalette.baseBackground,
        fontFamily: 'Inter', // optional: add Inter or Roboto
      ),
      home: GlassQuizHomePage(
        sampleQuizzes: [
          { 'title': 'Basic Algebra', 'description': 'Linear equations, simplification, and factoring.', 'difficulty': 'Easy', 'time': 12, 'questions': 10 },
          { 'title': 'World History', 'description': 'Important events from 1500 to present.', 'difficulty': 'Medium', 'time': 20, 'questions': 15 },
          { 'title': 'Physics Mechanics', 'description': 'Forces, energy, and motion problems.', 'difficulty': 'Hard', 'time': 30, 'questions': 20 },
        ],
      ),
    );
  }
}

3) Run `flutter pub get` and `flutter run -d chrome` (for web) or `flutter run` (mobile).

Notes & tweaks:
- This implementation avoids third-party packages so it's easy to drop into your project.
- For improved typography and icons, add Google Fonts or custom icons.
- In production, tune blur/opacity values and replace `allow_origins` anywhere with your secure origins.
- If you already have an existing quiz list widget, adapt the `GlassQuizCard` and styles to your item data model.
*/
