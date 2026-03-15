# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# Hive
-keep class com.hive.** { *; }
-keep class * extends com.google.crypto.tink.shaded.protobuf.GeneratedMessageLite { *; }

# Supabase / Realtime
-keep class io.supabase.** { *; }
-dontwarn io.supabase.**

# Dio / OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Google Sign-In
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Firebase / Google Services
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Connectivity Plus
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# Share Plus
-keep class dev.fluttercommunity.plus.share.** { *; }

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Keep enums
-keepclassmembers enum * { *; }

# Keep Parcelables
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    !private <fields>;
    !private <methods>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
