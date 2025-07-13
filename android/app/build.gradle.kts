plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Plugin Google Services để dùng Firebase
    id("com.google.gms.google-services")
    // Flutter Gradle plugin (phải đứng sau android/kotlin)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.trao_doi_do_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.trao_doi_do_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // BoM để đồng bộ version các thư viện Firebase
    implementation(platform("com.google.firebase:firebase-bom:33.16.0"))

    // Firebase Analytics (thống kê người dùng)
    implementation("com.google.firebase:firebase-analytics")

    // Firebase Cloud Messaging (thông báo đẩy)
    implementation("com.google.firebase:firebase-messaging")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
