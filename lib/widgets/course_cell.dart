import 'package:flutter/material.dart';
import '../models/course.dart';

class CourseCell extends StatefulWidget {
  final Course course;
  final double cellHeight;
  final VoidCallback? onTap;

  const CourseCell({
    super.key,
    required this.course,
    this.cellHeight = 100,
    this.onTap,
  });

  @override
  State<CourseCell> createState() => _CourseCellState();
}

class _CourseCellState extends State<CourseCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  static const _lightBgColors = [
    [Color(0xFFDCE4FF), Color(0xFFC8D6FF)],
    [Color(0xFFFFDCE7), Color(0xFFFFCAD8)],
    [Color(0xFFDDF5E3), Color(0xFFC8EDD2)],
    [Color(0xFFFFE7D4), Color(0xFFFFD8BE)],
    [Color(0xFFD8F3F8), Color(0xFFC2EBF2)],
    [Color(0xFFEBDDF7), Color(0xFFDDCBF0)],
    [Color(0xFFFFF4D8), Color(0xFFFFEDC0)],
    [Color(0xFFD8EBFF), Color(0xFFC4DFFF)],
    [Color(0xFFFFDDD6), Color(0xFFFFCCC2)],
    [Color(0xFFD7F4EF), Color(0xFFC2EDE6)],
  ];

  static const _darkBgColors = [
    [Color(0xFF2A3268), Color(0xFF222A58)],
    [Color(0xFF5C2240), Color(0xFF4E1A36)],
    [Color(0xFF1F4D2D), Color(0xFF184224)],
    [Color(0xFF6B401A), Color(0xFF5C3614)],
    [Color(0xFF10444E), Color(0xFF0C3A42)],
    [Color(0xFF47295C), Color(0xFF3C2150)],
    [Color(0xFF615218), Color(0xFF544712)],
    [Color(0xFF163C64), Color(0xFF103256)],
    [Color(0xFF622C22), Color(0xFF54241C)],
    [Color(0xFF1D4E44), Color(0xFF16423A)],
  ];

  static const _accentColors = [
    Color(0xFF3D5AFE),
    Color(0xFFD81B60),
    Color(0xFF2E7D32),
    Color(0xFFEF6C00),
    Color(0xFF00838F),
    Color(0xFF7B1FA2),
    Color(0xFFF9A825),
    Color(0xFF1565C0),
    Color(0xFFD84315),
    Color(0xFF00796B),
  ];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final index = widget.course.name.hashCode.abs() % _lightBgColors.length;
    final bgColors = isDark ? _darkBgColors[index] : _lightBgColors[index];
    final accentColor = _accentColors[index];

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          height: widget.cellHeight,
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          padding: const EdgeInsets.fromLTRB(10, 8, 8, 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: bgColors,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // 装饰圆
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: isDark ? 0.08 : 0.06),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.course.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.92)
                            : accentColor,
                        height: 1.2,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.course.classroom.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 10,
                            color: isDark
                                ? Colors.white54
                                : accentColor.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              widget.course.classroom,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white60
                                    : accentColor.withValues(alpha: 0.7),
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (widget.course.weekTypeLabel != '全周')
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      widget.course.weekTypeLabel,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white70
                            : accentColor.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
