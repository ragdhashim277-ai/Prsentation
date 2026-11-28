# البيان لتحضير الدروس

## الإعداد
1. أنشئ مشروعاً في Supabase ونفّذ `supabase/schema.sql` في SQL Editor.
2. في Authentication فعّل Email (ويمكنك تعطيل تأكيد البريد أثناء التجربة).
3. ضع `url` و`anon key` في `lib/core/supabase_config.dart`
   أو شغّل: `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
4. لتفعيل الذكاء الاصطناعي:
   ```
   supabase functions deploy generate-lesson
   supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
   ```
   بدون ذلك يعمل التطبيق بقالب جاهز.
5. من داخل المجلد: `flutter create .` (لتوليد android/ و ios/) ثم `flutter pub get` ثم `flutter run`.
6. أندرويد: تأكد من وجود `<uses-permission android:name="android.permission.INTERNET"/>`
   في `android/app/src/main/AndroidManifest.xml` لنسخة الإصدار (release).
