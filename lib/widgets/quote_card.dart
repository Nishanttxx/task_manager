import 'package:flutter/material.dart';
import '../models/quote_model.dart';
import '../services/quote_service.dart';

/// A card widget that displays a motivational quote.
///
/// Uses [FutureBuilder] to handle loading / success / error states
/// as specified in the architecture (Phase 4 → QuoteCard section).
class QuoteCard extends StatefulWidget {
  const QuoteCard({super.key});

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  late Future<QuoteModel> _quoteFuture;
  final QuoteService _quoteService = QuoteService();

  @override
  void initState() {
    super.initState();
    _quoteFuture = _quoteService.fetchRandomQuote();
  }

  void _refreshQuote() {
    setState(() {
      _quoteFuture = _quoteService.fetchRandomQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuoteModel>(
      future: _quoteFuture,
      builder: (context, snapshot) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withAlpha(40),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    color: Color(0xFF818CF8),
                    size: 28,
                  ),
                  const Spacer(),
                  // Refresh button
                  InkWell(
                    onTap: _refreshQuote,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Color(0xFF818CF8),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF818CF8),
                      ),
                    ),
                  ),
                )
              else if (snapshot.hasError)
                Text(
                  '"The only way to do great work is to love what you do."',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                )
              else if (snapshot.hasData) ...[
                Text(
                  '"${snapshot.data!.content}"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '— ${snapshot.data!.author}',
                    style: TextStyle(
                      color: Colors.white.withAlpha(140),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
