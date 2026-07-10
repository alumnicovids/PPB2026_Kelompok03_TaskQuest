import '../repositories/quotes_repository.dart';

class GetRandomQuoteUseCase {
  final QuotesRepository _repository;

  GetRandomQuoteUseCase(this._repository);

  Future<Map<String, String>> execute() async {
    return await _repository.getRandomQuote();
  }
}
