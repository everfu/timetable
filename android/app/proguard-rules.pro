# Flutter 标准 ProGuard 规则
# 保留 Flutter 引擎
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# 保留注解
-keepattributes *Annotation*
-keepattributes Signature

# 保留 native 方法
-keepclasseswithmembernames class * {
    native <methods>;
}
