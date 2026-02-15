import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasKeystoreFile = keystorePropertiesFile.exists()

if (hasKeystoreFile) {
    FileInputStream(keystorePropertiesFile).use { input ->
        keystoreProperties.load(input)
    }
}

val requiredSigningKeys = listOf(
    "storeFile",
    "storePassword",
    "keyAlias",
    "keyPassword",
)
val hasReleaseSigning = hasKeystoreFile &&
    requiredSigningKeys.all { key ->
        (keystoreProperties.getProperty(key) ?: "").isNotBlank()
    }

val isReleaseTaskRequested = gradle.startParameter.taskNames.any { task ->
    task.contains("release", ignoreCase = true)
}

android {
    namespace = "io.naviary.avium"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "io.naviary.avium"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (!hasReleaseSigning) {
                return@create
            }
            storeFile = file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

if (isReleaseTaskRequested && !hasReleaseSigning) {
    throw GradleException(
        "Missing Android release signing config. " +
            "Create android/key.properties (see android/key.properties.example) " +
            "and provide a valid keystore before running release builds.",
    )
}

flutter {
    source = "../.."
}
