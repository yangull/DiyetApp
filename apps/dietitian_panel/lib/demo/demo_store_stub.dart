/// Nothing persists off the web. Tests and any non-web build always start from
/// the seed data.
class DemoStore {
  const DemoStore();

  String? read() => null;

  void write(String json) {}

  void clear() {}
}
