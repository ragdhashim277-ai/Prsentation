name: Build APK

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Arrange project files
        run: |
          mkdir -p app/lib/core app/lib/models app/lib/services app/lib/screens
          cp pubspec.yaml app/
          cp main.dart app/lib/
          cp supabase_config.dart app/lib/core/
          cp lesson.dart app/lib/models/
          cp ai_service.dart lesson_service.dart voice_service.dart app/lib/services/
          cp auth_screen.dart home_screen.dart lesson_screen.dart library_screen.dart prepare_screen.dart app/lib/screens/
          grep -q "_gradesByLevel" app/lib/screens/prepare_screen.dart || { echo "prepare_screen.dart is an old version"; exit 1; }
          tail -n 3 app/lib/screens/prepare_screen.dart

      - uses: actions/setup-java@v5
        with:
          distribution: temurin
          java-version: '17'

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Generate android platform files
        working-directory: app
        run: flutter create . --platforms=android --project-name albayan_lesson_prep

      - name: Add INTERNET permission for release
        working-directory: app
        run: |
          sed -i 's#<application#<uses-permission android:name="android.permission.INTERNET"/>\n    <application#' android/app/src/main/AndroidManifest.xml

      - name: Get packages
        working-directory: app
        run: flutter pub get

      - name: Analyze code
        working-directory: app
        continue-on-error: true
        run: flutter analyze 2>&1 | tee analyze.log

      - name: Build release APK
        working-directory: app
        run: |
          set -o pipefail
          flutter build apk --release 2>&1 | tee build.log

      - name: Collect errors
        if: failure()
        working-directory: app
        run: |
          echo '## Analyze errors' >> $GITHUB_STEP_SUMMARY
          echo '```' >> $GITHUB_STEP_SUMMARY
          grep -E "error" analyze.log | head -n 30 >> $GITHUB_STEP_SUMMARY || true
          echo '```' >> $GITHUB_STEP_SUMMARY
          echo '## Build errors' >> $GITHUB_STEP_SUMMARY
          echo '```' >> $GITHUB_STEP_SUMMARY
          grep -nE "Error|error:|FAILURE|What went wrong|Execution failed" -A6 build.log | head -n 80 >> $GITHUB_STEP_SUMMARY || true
          echo '```' >> $GITHUB_STEP_SUMMARY

      - uses: actions/upload-artifact@v4
        if: success()
        with:
          name: albayan-apk
          path: app/build/app/outputs/flutter-apk/app-release.apk

      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: build-log
          path: |
            app/build.log
            app/analyze.log
