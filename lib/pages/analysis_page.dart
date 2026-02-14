import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/analysis_screen.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: 8),
          
          // Mevcut analysis screen'i göster
          AnalysisScreen(),
        ],
      ),
    );
  }
}
