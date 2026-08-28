/// Compile-time configuration, supplied by `--dart-define-from-file`.
///
/// Run an app with the real values like this, from the app's directory:
///
/// ```sh
/// flutter run -d web-server --dart-define-from-file=../../env/dev.json
/// ```
///
/// Three things about the keys stored here:
///
/// * The Supabase anon (publishable) key is **public by design**. It ships
///   inside every build and anyone can read it out of the bundle.
/// * What actually protects the data is **Row Level Security** in Postgres,
///   not the secrecy of this key.
/// * The `service_role` key bypasses RLS entirely and must **never** appear in
///   client code or in `env/*.json`. It belongs in Edge Function secrets only.
class AppConfig {
  const AppConfig._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// False when an app was built without `--dart-define-from-file`, which is
  /// the common cause of a confusing "invalid URL" at Supabase client startup.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
