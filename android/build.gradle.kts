allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Use default Gradle build directories to avoid path issues on Windows
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
