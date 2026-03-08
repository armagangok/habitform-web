# Store Submission Guide (Firebase Integration)

Since you've integrated Firebase (Auth, Firestore) and other services like RevenueCat, there are specific forms and declarations you must complete in App Store Connect and Google Play Console to avoid rejection.

---

## 🍎 App Store Connect (iOS)

### 1. App Privacy (Data Types)
You must disclose the data your app collects. Based on your current integration:

*   **Contact Info**:
    *   **Email Address**: Collected for authentication (`firebase_auth`).
    *   **Name**: If collected during sign-up.
*   **Identifiers**:
    *   **User ID**: Used to link account data (`firebase_auth`, `cloud_firestore`).
    *   **Device ID**: Used by Firebase for basic analytics/diagnostics.
*   **Usage Data**:
    *   **Product Interaction**: If you track feature usage via Firebase.
*   **Diagnostics**:
    *   **Crash Data**: If Firebase Crashlytics is enabled.

> [!IMPORTANT]
> When asked if the data is linked to the user's identity, select **Yes** for Email and User ID.

### 2. Account Deletion Requirement
Apple requires that if your app allows account creation, it must also allow account deletion **within the app**.
*   Ensure you have a "Delete Account" button in your settings.
*   This button should delete the user's data from Firebase Auth and their personal documents in Firestore.

### 3. Sign in with Apple
Since you have Google Sign-In, Apple **requires** you to also offer "Sign in with Apple".
*   I see `sign_in_with_apple` in your `pubspec.yaml`, so ensure it is functional and prominently displayed.

---

## 🤖 Google Play Console (Android)

### 1. Data Safety Section
Google requires a detailed "Data Safety" form. You will need to declare:

*   **Data Collection**:
    *   **Personal Info**: Email address (Collected, Shared=No, Processed=Yes).
    *   **Identifiers**: User IDs, Device IDs.
*   **Data Usage**:
    *   Check: **App functionality**, **Account management**.
*   **Security Practices**:
    *   Data is encrypted in transit (Firebase handles this).
    *   Users can request data deletion.

### 2. Account Deletion (New Policy)
In the "App Content" section, you must provide:
*   A link users can use to request account deletion outside the app (e.g., a simple web form or your website's support page).
*   Declaration that users can delete their account and associated data within the app.

---

## 🔥 Firebase Specifics

### 1. Analytics & Crashlytics
Even if not explicitly used, Firebase often collects basic device info.
*   **iOS**: Check "Usage Data" and "Diagnostics" in the Privacy section.
*   **Android**: Ensure "Device or other IDs" is checked in Data Safety.

### 2. Location (If applicable)
If you ever add location-based habits, you must justify background location usage to both stores, which is a high-risk review item. (Currently not detected in your code).

---

## 💰 RevenueCat (In-App Purchases)
*   Disclose "Purchase History" in the App Privacy / Data Safety sections.
*   Ensure your "Restore Purchases" button is 100% functional and visible on the paywall.
