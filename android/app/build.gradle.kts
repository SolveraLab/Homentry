plugins {
        id("com.android.application")
        id("dev.flutter.flutter-gradle-plugin")
        id("com.google.gms.google-services") // ✅ No version here
        id("org.jetbrains.kotlin.android")
    }



android {
    namespace = "com.example.homebite"
    compileSdk = flutter.compileSdkVersion.toInt() // Added toInteger() for safety
    ndkVersion = "27.0.12077973"


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"  // Simplified version
    }

    defaultConfig {
        applicationId = "com.example.homebite"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion.toInt() // Added toInteger()
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
        multiDexEnabled = true  // Added for larger apps
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            isMinifyEnabled = true  // Explicitly enable minification
            isShrinkResources = true  // Enable resource shrinking
        }
        debug {
            isDebuggable = true
        }
    }

    buildFeatures {
        viewBinding = true  // Optional: Enable if using view binding
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))
    // Required Firebase dependencies
    implementation("com.google.firebase:firebase-analytics-ktx")  // Using -ktx version
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")


    implementation("com.google.firebase:firebase-auth")

    // Core Kotlin extensions
    implementation("androidx.core:core-ktx:1.12.0")

    // MultiDex support for larger apps
    implementation("androidx.multidex:multidex:2.0.1")

    implementation("com.google.android.gms:play-services-auth:21.3.0")
    // Optional Firebase services (uncomment as needed)
    // implementation("com.google.firebase:firebase-storage-ktx")
    // implementation("com.google.firebase:firebase-messaging-ktx")
    // implementation("com.google.firebase:firebase-config-ktx")
}