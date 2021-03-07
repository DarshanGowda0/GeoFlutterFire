# geoflutterfire_example

Demonstrates how to use the geoflutterfire plugin.

To run this example:

1. Go to https://firebase.google.com/ and create a new project.
2. Enable the Cloud Firestore in Firebase console https://console.firebase.google.com/
3. Create a database in test mode.
4. Create a Google Maps API key. Follow instructions on Google Map plugin https://pub.dev/packages/google_maps_flutter
5. Create Credentials -> API Key. Follow instructions https://developers.google.com/maps/documentation/javascript/get-api-key

Android:
1. Select 'Add Firebase to your Android app' and use package name: com.example.example
2. Download the google-services.json file and add it to the android/app folder.
3. Paste API key value into android/app/src/main/AndroidManifest.xml as the value for the com.google.android.geo.API_KEY meta data.

iOS:
1. Select 'Add Firebase to your iOS app' and use package name: com.example.example
2. Download the GoogleService-Info.plist and add it to the runner/runner using Xcode.
3. Paste API key value into ios/Runner/AppDelegate.swift as the parameter for GMSServices.provideAPIKey.