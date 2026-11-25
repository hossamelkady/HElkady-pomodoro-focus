# HElkady-pomodoro-focus

**English** | [العربية](#العربية)

Pomodoro focus timer. 25 minute focus sessions with 5 minute breaks.

## Features
- Start, pause and reset the timer
- Switch between focus and break
- Daily session stats and a 7-day chart
- Stats saved on the device

## Build
Requires Flutter (stable), JDK 17+ and Android SDK 35+.

```
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

The APK is written to `build/app/outputs/flutter-apk/app-debug.apk`.

## Notes
- Android only. All data stays on the device (local storage, no network, no account).
- UI language follows the device: English or Arabic (RTL).
- Tested with `flutter analyze` and `flutter test` (unit and widget tests). It has not been run on a physical phone yet.

---

<a id="العربية"></a>
# HElkady-pomodoro-focus (العربية)

مؤقت بومودورو للتركيز. جلسات تركيز ٢٥ دقيقة وراحة ٥ دقائق.

## المميزات
- تشغيل وإيقاف وإعادة ضبط المؤقت
- التبديل بين التركيز والراحة
- إحصائيات يومية للجلسات ورسم لآخر ٧ أيام
- الإحصائيات محفوظة على الجهاز

## البناء
يحتاج Flutter (stable) و JDK 17 أو أحدث و Android SDK 35 أو أحدث.

```
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

ملف APK يظهر في `build/app/outputs/flutter-apk/app-debug.apk`.

## ملاحظات
- أندرويد فقط. كل البيانات تتخزن على الجهاز (بدون إنترنت أو حساب).
- لغة الواجهة حسب لغة الجهاز: إنجليزي أو عربي (من اليمين لليسار).
- اتجرب بـ `flutter analyze` و `flutter test` (اختبارات وحدة وواجهة). لسه ما اتجربش على موبايل حقيقي.
