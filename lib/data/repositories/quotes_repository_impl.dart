import '../../domain/repositories/quotes_repository.dart';
import '../datasources/remote/quotes_datasource.dart';

class QuotesRepositoryImpl implements QuotesRepository {
  final QuotesDatasource _quotesDatasource;

  QuotesRepositoryImpl(this._quotesDatasource);

  @override
  Future<Map<String, String>> getRandomQuote() async {
    return await _quotesDatasource.getRandomQuote();
  }
}
