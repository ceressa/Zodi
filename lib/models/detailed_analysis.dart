class DetailedAnalysis {
  final String title;
  final String content;
  final int percentage;

  DetailedAnalysis({
    required this.title,
    required this.content,
    required this.percentage,
  });

  factory DetailedAnalysis.fromJson(Map<String, dynamic> json) {
    return DetailedAnalysis(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      percentage: json['percentage'] ?? 0,
    );
  }
}
