-verbose
-keep class androidx.lifecycle.** { *; }
-keepclassmembers class * implements androidx.lifecycle.LifecycleObserver {
    <init>(...);
}
-keepclassmembers class * extends androidx.lifecycle.ViewModel {
    <init>(...);
}
-keepclassmembers class androidx.lifecycle.Lifecycle$State { *; }
-keepclassmembers class androidx.lifecycle.Lifecycle$Event { *; }
-keepclassmembers class * {
    @androidx.lifecycle.OnLifecycleEvent *;
}

-keep class com.pauldemarco.flutter_blue.** { *; }
-keep class io.flutter.plugins.deviceinfo.** { *; }
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keep class com.pauldemarco.flutter_blue.** { *; }
-keep class io.flutter.plugins.flutter_plugin_android_lifecycle.** { *; }
-keep class dev.flutter.plugins.integration_test.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class com.twwm.share_files_and_screenshot_widgets.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class com.tekartik.sqflite.** { *; }
-keep class name.avioli.unilinks.** { *; }
-keep class io.flutter.plugins.urllauncher.** { *; }
-keep class creativemaybeno.wakelock.** { *; }

-keepattributes Exceptions,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,*Annotation*,EnclosingMethod
