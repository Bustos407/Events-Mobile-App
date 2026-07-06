# Flutter wrapper and plugin classes must survive shrinking/obfuscation.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Play Core "deferred components" classes are only needed for dynamic feature
# delivery, which this app doesn't use; safe to silence R8's missing-class error.
-dontwarn com.google.android.play.core.**
