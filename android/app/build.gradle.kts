import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing key 설정
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.han.puzzle"
    
    // compileSdk를 flutter 기본값과 동기화하거나 targetSdk와 일치시킵니다.
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.han.puzzle"
        minSdk = flutter.minSdkVersion
        // targetSdk를 임의로 고정하는 대신 플러터 기본값을 사용하거나 
        // 꼭 필요하다면 compileSdk와 동일하게 맞추는 것이 안전합니다.
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Release 서명 설정 (key.properties가 없을 경우 대비 안전장치 추가)
    signingConfigs {
        create("release") {
            val hasKeyProps = keystoreProperties.isNotEmpty()
            keyAlias = if (hasKeyProps) keystoreProperties["keyAlias"] as String else ""
            keyPassword = if (hasKeyProps) keystoreProperties["keyPassword"] as String else ""
            storeFile = if (hasKeyProps && keystoreProperties["storeFile"] != null) file(keystoreProperties["storeFile"] as String) else null
            storePassword = if (hasKeyProps) keystoreProperties["storePassword"] as String else ""
        }
    }

    buildTypes {
        release {
            // key.properties가 있을 때만 release 서명 적용, 없으면 debug 서명으로 폴백
            // (CI/신규 PC에서 서명 없이도 빌드 가능하도록)
            signingConfig = if (keystoreProperties.isNotEmpty()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}