abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Terjadi kesalahan pada server']);
}

class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Terjadi kesalahan pada penyimpanan lokal',
  ]);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure([super.message = 'Tidak ada koneksi internet']);
}
