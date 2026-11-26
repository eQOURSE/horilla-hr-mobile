# eQOURSE Work Android handoff

## Identity and server

- Android application ID: `com.eqourse.work`
- API host: `https://work.eqourse.com`
- Google sign-in accepts only active employee accounts whose verified email ends in `@eqourse.com`.
- The app's `serverClientId` must be the existing **Web OAuth client ID**. Supply it at build time with `--dart-define=GOOGLE_SERVER_CLIENT_ID=...`.
- The Android OAuth client ID and release SHA-1 are registered in Google Cloud for `com.eqourse.work`; they are not the `serverClientId`, and the mobile app does not contain a client secret.

The release certificate fingerprint is intentionally not committed or guessed. Bhavesh should generate it from the private release keystore and register it in Google Cloud before pilot testing:

```powershell
keytool -list -v -keystore <private-release-keystore> -alias <release-alias>
```

Keep the keystore and passwords outside GitHub. Use the same keystore for every future update; changing it prevents Android updates from installing over the pilot build.

## Attendance contract

Every check-in and check-out collects:

- a fresh high-accuracy GPS fix;
- reported GPS accuracy and location timestamp;
- a confirmed front-camera JPEG containing exactly one detected face.

The app sends these fields as multipart data to the existing `/api/v1/attendance/clock-in/` or `/api/v1/attendance/clock-out/` route. The server compares the live image with the approved employee photo and applies the office/WFH policy. The app never treats a client-side face result as identity proof.

For this pilot, onsite evidence uses `distance from office + GPS uncertainty <= 100 m` and
`GPS uncertainty <= 25 m`. The HRMS server must be configured with the same 100 m onsite
radius before end-to-end pilot testing; a client-only change must not be used against a
server still enforcing a different radius.

The automated cases cover both check-in and check-out: 75 m + 25 m passes, 76 m + 25 m
fails, 10 m + 26 m fails, and a wrong face fails even when location evidence is valid.

## Release gate

Do not make this build mandatory until Bhavesh and Kartik have tested on their phones at the office entrance and usual indoor punch spot. Record check-in and check-out results for inside/outside radius, denied camera/location permissions, weak GPS, wrong face, printed photo, and photo shown on another phone. If either photo spoof is accepted by server matching, add an explicit liveness challenge before employee rollout.

Configure the private signing values in the user's Gradle properties file
(`$HOME/.gradle/gradle.properties` on macOS/Linux, or
`%USERPROFILE%\\.gradle\\gradle.properties` on Windows):

```properties
EQOURSE_RELEASE_STORE_FILE=C:\\secure\\eqourse-work-release.jks
EQOURSE_RELEASE_STORE_PASSWORD=your-keystore-password
EQOURSE_RELEASE_KEY_ALIAS=eqourse-work
EQOURSE_RELEASE_KEY_PASSWORD=your-key-password
```

If the keystore does not exist yet, create it locally (never commit it):

```powershell
keytool -genkeypair -v -keystore C:\\secure\\eqourse-work-release.jks -alias eqourse-work -keyalg RSA -keysize 2048 -validity 10000
```

Verify the release SHA-1/SHA-256 that is registered in Google Cloud:

```powershell
keytool -list -v -keystore C:\\secure\\eqourse-work-release.jks -alias eqourse-work
```

Build the signed pilot APK with the existing Web OAuth client ID:

```powershell
flutter pub get
flutter build apk --release --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. The release
signing configuration is loaded only from local Gradle properties or environment
variables; no private key or password belongs in Git.

The signed APK must be hosted over HTTPS by Bhavesh. AWS, production deployment, OAuth client setup, and release signing remain with Bhavesh.
