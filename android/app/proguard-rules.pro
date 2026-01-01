# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Preserve Flutter embedding classes
-keep class io.flutter.embedding.** { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep custom application class
-keep public class * extends android.app.Application { *; }

# Keep Parcelables
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Preserve annotations
-keepattributes *Annotation*

# Keep source file and line numbers for better crash reports
-keepattributes SourceFile,LineNumberTable

# Remove verbose logging in release builds (keep warnings and errors)
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Keep shared_preferences plugin
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Keep encryption libraries (pointycastle, encrypt)
-keep class com.github.pointycastle.** { *; }
-dontwarn com.github.pointycastle.**
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# Keep crypto classes to prevent issues with reflection
-keepclassmembers class * {
    public <init>(...);
}

-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep JavaScript interface methods (if using WebView)
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Suppress warnings for Google Play Core classes (used by Flutter but not in this app)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
