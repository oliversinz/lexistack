abstract interface class ProgressStorage {
  Future<String?> read();
  Future<void> write(String document);
}

/// Deterministic test store; hooks can hold writes or inject platform failures.
class MemoryProgressStorage implements ProgressStorage {
  MemoryProgressStorage([this.value]);
  String? value;
  int failWrites = 0;
  bool failRead = false;
  Future<void> Function(String)? beforeWrite;
  final List<String> writes = [];

  @override
  Future<String?> read() async {
    if (failRead) throw StateError('Injected read failure');
    return value;
  }

  @override
  Future<void> write(String document) async {
    await beforeWrite?.call(document);
    if (failWrites > 0) {
      failWrites--;
      throw StateError('Injected write failure');
    }
    value = document;
    writes.add(document);
  }
}
