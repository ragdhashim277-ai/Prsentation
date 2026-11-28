/// ضع بيانات مشروعك هنا، أو مرّرها عند التشغيل:
/// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://cnidxtravyrofgvxqndv.supabase.co',
  );
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_nYUZnG-GTEtX8LsOvn8_zw_Bw3uCqOb',
  );

  static bool get isConfigured =>
      !url.contains('YOUR_PROJECT') && !anonKey.startsWith('YOUR_');
}
