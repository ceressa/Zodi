import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CandyLoading extends StatefulWidget {
  final String? message;
  final double size;
  
  const CandyLoading({
    super.key,
    this.message,
    this.size = 60,
  });

  @override
  State<CandyLoading> createState() => _CandyLoadingState();
}

class _CandyLoadingState extends State<CandyLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer rotating circle
                  Transform.rotate(
                    angle: _controller.value * 2 * 3.14159,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentPink,
                            AppColors.pastelLavender,
                            AppColors.accentBlue,
                            AppColors.accentPink,
                          ],
                          stops: const [0.0, 0.33, 0.66, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Inner white circle
                  Container(
                    width: widget.size * 0.7,
                    height: widget.size * 0.7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  // Center sparkle
                  Transform.scale(
                    scale: 0.5 + (_controller.value * 0.5),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.accentPink,
                      size: 24,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
