extension NullableListExtensions<T> on Iterable<T?> {
  Iterable<T> whereNotNull() {
    return where((e) => e != null).map((e) => e as T);
  }
}
