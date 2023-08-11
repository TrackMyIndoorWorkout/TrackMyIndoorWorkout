-verbose
-keep class androidx.lifecycle.** { *; }
-keepclassmembernames class androidx.lifecycle.* { *; }
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

# https://github.com/flutter/flutter/issues/78625#issuecomment-804164524
# https://stackoverflow.com/questions/76800185/how-to-keep-classes-reported-missing-by-r8-during-a-release-build-of-a-flutter-a/
# https://github.com/TrackMyIndoorWorkout/TrackMyIndoorWorkout/issues/435
#-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
#-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# This is from iterating over GeneratedPLuginRegistrant.java [
-keep class dev.fluttercommunity.plus.device_info.** { *; }
-keepclassmembernames class dev.fluttercommunity.plus.device_info.** { *; }
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keepclassmembernames class com.mr.flutter.plugin.filepicker.** { *; }
-keep class com.boskokg.flutter_blue_plus.** { *; }
-keepclassmembernames class com.boskokg.flutter_blue_plus.* { *; }
-keep class net.wolverinebeach.flutter_timezone.** { *; }
-keepclassmembernames class net.wolverinebeach.flutter_timezone.* { *; }
-keep class io.flutter.plugins.flutter_plugin_android_lifecycle.** { *; }
-keepclassmembernames class io.flutter.plugins.flutter_plugin_android_lifecycle.** { *; }
-keep class dev.fluttercommunity.plus.packageinfo.** { *; }
-keepclassmembernames class dev.fluttercommunity.plus.packageinfo.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
-keepclassmembernames class io.flutter.plugins.pathprovider.** { *; }
-keep class com.twwm.share_files_and_screenshot_widgets.** { *; }
-keepclassmembernames class com.twwm.share_files_and_screenshot_widgets.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keepclassmembernames class io.flutter.plugins.sharedpreferences.** { *; }
-keep class pl.ukaszapps.soundpool.** { *; }
-keepclassmembernames class pl.ukaszapps.soundpool.** { *; }
-keep class com.tekartik.sqflite.** { *; }
-keepclassmembernames class com.tekartik.sqflite.** { *; }
-keep class name.avioli.unilinks.** { *; }
-keepclassmembernames class name.avioli.unilinks.** { *; }
-keep class io.flutter.plugins.urllauncher.** { *; }
-keepclassmembernames class io.flutter.plugins.urllauncher.** { *; }
-keep class dev.fluttercommunity.plus.wakelock.** { *; }
-keepclassmembernames class dev.fluttercommunity.plus.wakelock.** { *; }
# ] This is from iterating over GeneratedPLuginRegistrant.java

-keepattributes Exceptions,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,*Annotation*,EnclosingMethod

-keep class * extends com.google.protobuf.** { *; }
-keepclassmembernames class * extends com.google.protobuf.** { *; }
