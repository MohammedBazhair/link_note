class Result<T> {
  Result.ok(this.value) : errorMessage = null;
  Result.error(this.errorMessage) : value = null;

  final T? value;
  final String? errorMessage;

  bool get isOk => errorMessage == null;
  bool get hasError => errorMessage != null;
}
