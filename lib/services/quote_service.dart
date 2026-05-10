import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote_model.dart';

/// Fetches motivational quotes from the quotable.io REST API.
///
/// This service has NO dependency on Firebase — it is a standalone
/// modular integration, as shown in Phase 3 of the architecture.
class QuoteService {
  static const String _baseUrl = 'https://dummyjson.com/quotes/random';

  /// Fetches a single random motivational quote.
  ///
  /// Returns a [QuoteModel] on success.
  /// Throws an [Exception] on network or parsing errors.
  Future<QuoteModel> fetchRandomQuote() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return QuoteModel.fromJson(data);
      } else {
        throw Exception(
          'Failed to fetch quote (HTTP ${response.statusCode})',
        );
      }
    } catch (e) {
      // Return a fallback quote if the API is unreachable.
      // This keeps the app usable even without network.
      throw Exception('Quote service error: $e');
    }
  }
}
