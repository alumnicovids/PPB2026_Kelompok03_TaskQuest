import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class QuotesDatasource {
  final http.Client _client;

  QuotesDatasource(this._client);

  static const List<Map<String, String>> _fallbackQuotes = [
    {
      'quote': 'Do not watch the clock; do what it does. Keep going.',
      'author': 'Sam Levenson',
    },
    {
      'quote': 'The secret of getting ahead is getting started.',
      'author': 'Mark Twain',
    },
    {
      'quote': 'It always seems impossible until it\'s done.',
      'author': 'Nelson Mandela',
    },
    {
      'quote': 'Our greatest weakness lies in giving up.',
      'author': 'Thomas A. Edison',
    },
    {
      'quote': 'Focus on being productive instead of busy.',
      'author': 'Tim Ferriss',
    },
  ];

  Future<Map<String, String>> getRandomQuote() async {
    try {
      final response = await _client
          .get(Uri.parse('https://zenquotes.io/api/random'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final first = data.first;
          return {
            'quote': first['q'] as String,
            'author': first['a'] as String,
          };
        }
      }
    } catch (_) {
      // Return fallback quote on network exception/timeout
    }

    // Fallback if network call failed
    final random = Random();
    return _fallbackQuotes[random.nextInt(_fallbackQuotes.length)];
  }
}
