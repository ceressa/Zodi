import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/user_history_service.dart';
import '../services/firebase_service.dart';

class FeedbackWidget extends StatefulWidget {
  final String interactionType;
  final VoidCallback? onFeedbackSubmitted;
  
  const FeedbackWidget({
    super.key,
    required this.interactionType,
    this.onFeedbackSubmitted,
  });

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  double _rating = 0;
  final _feedbackController = TextEditingController();
  bool _isSubmitted = false;
  final UserHistoryService _historyService = UserHistoryService();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir puan verin')),
      );
      return;
    }

    await _historyService.addFeedback(
      widget.interactionType,
      _rating,
      _feedbackController.text.isEmpty ? null : _feedbackController.text,
    );

    // Zengin profil güncellemeleri
    if (_firebaseService.isAuthenticated) {
      // Geri bildirim puanını kaydet
      await _firebaseService.submitRating(
        widget.interactionType,
        _rating,
        _feedbackController.text.isEmpty ? null : _feedbackController.text,
      );
    }

    setState(() => _isSubmitted = true);
    
    if (widget.onFeedbackSubmitted != null) {
      widget.onFeedbackSubmitted!();
    }

    // Auto hide after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isSubmitted) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.positive,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Teşekkürler!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Geri bildirimini aldım, seni daha iyi tanıyorum artık 😊',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nasıldı?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close,
                  color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Yorumum sana nasıl geldi? Dürüst ol, alınmam 😄',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondary : AppColors.textMuted,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Star Rating
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1.0;
                return IconButton(
                  onPressed: () => setState(() => _rating = starValue),
                  icon: Icon(
                    _rating >= starValue ? Icons.star : Icons.star_border,
                    color: AppColors.gold,
                    size: 40,
                  ),
                );
              }),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Feedback Text
          TextField(
            controller: _feedbackController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Eklemek istediğin bir şey var mı? (opsiyonel)',
              filled: true,
              fillColor: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.accentPurple, width: 2),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Submit Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.cosmicGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _submitFeedback,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Gönder',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show feedback dialog
void showFeedbackDialog(BuildContext context, String interactionType) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: FeedbackWidget(interactionType: interactionType),
    ),
  );
}
