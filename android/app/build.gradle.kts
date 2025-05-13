plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}
import java.util.Properties
import java.io.File
android {
    namespace = "com.ghastep"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Add this new block for signing configurations
    signingConfigs {
        create("release") {
            val keystoreProperties = Properties().apply {
                load(File(rootProject.projectDir, "key.properties").reader())
            }
            
            storeFile = file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
        }
    }

    defaultConfig {
        applicationId = "com.ghastep"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode.toInt()  // Add .toInt() for type safety
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Replace debug signing with your release config
            signingConfig = signingConfigs.getByName("release")
            
            // Add these optimization flags
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // Optional: Enable build features if needed
    buildFeatures {
        buildConfig = true
    }
}

flutter {
    source = "../.."
}

// Optional: Add this if you want to enable Java 11 features
tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions {
        jvmTarget = "11"
    }
}