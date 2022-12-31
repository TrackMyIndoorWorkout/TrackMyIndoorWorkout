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
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# This is from iterating over GeneratedPLuginRegistrant.java [
-keep class com.hui.bluetooth_enable.** { *; }
-keepclassmembernames class com.hui.bluetooth_enable.* { *; }
-keep class dev.fluttercommunity.plus.device_info.** { *; }
-keepclassmembernames class dev.fluttercommunity.plus.device_info.** { *; }
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keepclassmembernames class com.mr.flutter.plugin.filepicker.** { *; }
-keep class dev.steenbakker.flutter_ble_peripheral.** { *; }
-keepclassmembernames class dev.steenbakker.flutter_ble_peripheral.* { *; }
-keep class com.boskokg.flutter_blue_plus.** { *; }
-keepclassmembernames class com.boskokg.flutter_blue_plus.* { *; }
-keep class com.flutter.logs.plogs.flutter_logs.** { *; }
-keepclassmembernames class com.flutter.logs.plogs.flutter_logs.* { *; }
-keep class net.wolverinebeach.flutter_timezone.** { *; }
-keepclassmembernames class net.wolverinebeach.flutter_timezone.* { *; }
-keep class io.flutter.plugins.flutter_plugin_android_lifecycle.** { *; }
-keepclassmembernames class io.flutter.plugins.flutter_plugin_android_lifecycle.** { *; }
-keep class dev.fluttercommunity.plus.packageinfo.** { *; }
-keepclassmembernames class dev.fluttercommunity.plus.packageinfo.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
-keepclassmembernames class io.flutter.plugins.pathprovider.** { *; }
# permission_handler transitive dependency of easy_folder_picker
-keep class com.baseflow.permissionhandler.** { *; }
-keepclassmembernames class com.baseflow.permissionhandler.** { *; }
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
-keep class creativemaybeno.wakelock.** { *; }
-keepclassmembernames class creativemaybeno.wakelock.** { *; }
# ] This is from iterating over GeneratedPLuginRegistrant.java

-keepattributes Exceptions,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,*Annotation*,EnclosingMethod

-keep class * extends com.google.protobuf.** { *; }
-keepclassmembernames class * extends com.google.protobuf.** { *; }
