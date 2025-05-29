import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // FlutterFire
    id("dev.flutter.flutter-gradle-plugin") // Flutter Plugin
}

// dotenv.gradle 적용
apply(from = rootProject.file("app/dotenv.gradle"))

// key.properties 로딩
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.oss.talk_pilot"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.oss.talk_pilot"
        minSdk = 31
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // manifestPlaceholders
        manifestPlaceholders["KAKAO_NATIVE_APP_KEY"] =
            rootProject.extra["KAKAO_NATIVE_APP_KEY"] as? String ?: ""
    }

    signingConfigs {
        maybeCreate("debug") // 기본 디버그 서명 유지
        create("release") {
            if (keystorePropertiesFile.exists()) {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

tasks.withType<JavaCompile> {
    options.compilerArgs.add("-Xlint:deprecation")
}
