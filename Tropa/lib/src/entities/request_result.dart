class RequestResult<Tdata> {
  final Tdata? data;
  final Object? error;

  RequestResult(this.data, this.error);

  factory RequestResult.fromError(Object error) => RequestResult(null, error);

  factory RequestResult.fromData(Tdata data) => RequestResult(data, null);

  bool get isSuccessTheResult {
    return error == null;
  }
}