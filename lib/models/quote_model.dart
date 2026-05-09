/// Data model for a motivational quote fetched from the REST API.
///
/// This model is independent of Firebase — it only parses the
/// JSON response from https://api.quotable.io/random.
class QuoteModel {
  final String content;
  final String author;

  QuoteModel({
    required this.content,
    required this.author,
  });

  /// Creates a QuoteModel from the API's JSON response.
  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      content: json['content'] as String? ?? 'Stay motivated!',
      author: json['author'] as String? ?? 'Unknown',
    );
  }
}
