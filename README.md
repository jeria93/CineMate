# CineMate

**CineMate** is a SwiftUI iOS app for browsing, filtering, and saving movies powered by **TMDB**.  
It emphasizes clean architecture, fast UI iteration (Previews + mocks), and safe persistence via Firebase **Auth** + **Firestore**.

> **Authentication included:** Email/Password (verification email on signup + auto sign‑out), **Google Sign‑In (Firebase)**, and **Anonymous guest** mode. Reusable auth UI components and validators are included.
>
> **Recommended setup:** Xcode **15.3+** and iOS **17.4** (deployment targets include 17.4 and 18.5)  
> **Quick start:** clone -> copy `Secrets.example.plist` to `Secrets.plist` -> add TMDB keys -> add `GoogleService-Info.plist` -> Run

---

## Feature Demos

> **Watch CineMate in Action** — [Watch the CineMate demo on Vimeo »](https://vimeo.com/1117585898)

<details>
<summary><strong>Show GIFs (3)</strong></summary>

<br/>

| Browse → Detail | Real-time Favorites | Search + Infinite Scroll |
|---|---|---|
| <img src="Assets/popular_to_detail.gif" width="260" alt="Browse list to movie detail" /> | <img src="Assets/favorites_realtime.gif" width="260" alt="Toggle favorites with real-time updates" /> | <img src="Assets/search_infinite_scroll.gif" width="260" alt="Search with infinite scroll" /> |

</details>

---

## Features

### Movies
- Browse popular/top‑rated movies, details include credits & recommendations
- Search with debounce + infinite scroll
- Save/remove favorites for **movies** and **people** with real‑time updates
- Region‑specific watch providers

### Authentication (Firebase)
- **Create Account (Email/Password)** — sends **verification email** on signup and then **signs out**. Users verify via email and sign in again. No “unverified” in‑app state.
- **Sign In (Email/Password)**
- **Anonymous (Guest)** — one‑tap. Anonymous users can later **link** to email/password during sign‑up, we still **send verification** and **sign out** afterward (same policy as above).
- **Google Sign‑In** — official Google SwiftUI button + Firebase credential exchange
- **Sign Out** — from Account tab

### Guest Gating
- **Discover** and **Search** tabs are **locked for anonymous users**.
- Content remains visible but is non‑interactive (`.allowsHitTesting(false)`).
- A reusable `LockedFeatureOverlay` explains why and offers **Create Account**.

### Account
- Shows **how you’re signed in**: `Google`, `Email (a@b.com)`, or `Guest` (via `authProviderDescription`).  
- Shows short **UID** preview.
- **Sign Out** button.
- **Danger Zone**: delete account + data. Includes inline loading overlay while deleting.
- Full‑screen **Error overlay** (`ErrorMessageView`) for auth errors, ephemeral **toasts** for transient events (e.g. delete failure/success).

> Deleting account removes `/users/{uid}` data in Firestore first, then deletes the Firebase Auth user. For anonymous users, “requires recent login” is tolerated so deletion still succeeds. Deleting a Firebase user **does not** delete your external Google/Apple account.

**UI building blocks**
- `RoundedField`, `TrailingIcon`
- `AuthEmailField`, `AuthPasswordField`
- `ValidationMessageView`, `ToastCenter`
- `LockedFeatureOverlay`, `LoadingView`, `ErrorMessageView`
- `View+Focus.applyFocus(_:)`

**Validation & errors**
- `AuthValidator` — trims/sanitizes email, password policy (min/max length, requires lower/upper/digit)
- `AuthAppError` — maps Firebase/Google errors -> compact, user‑friendly messages

---

## Prerequisites

You need the following local configuration files before running the app:

| File | Location | Purpose |
|------|----------|---------|
| `Secrets.plist` | `CineMate/Secrets.plist` | TMDB API keys and tokens |
| `GoogleService-Info.plist` | Add to the Xcode project (app target) | Firebase config for Auth + Firestore + Google client ID |

> These are **excluded from version control**. Use `Secrets.example.plist` as a template.

### Firebase Console configuration
- **Authentication -> Sign‑in method**
- Enable **Anonymous**
- Enable **Email/Password**
- Enable **Google**
- **Firestore**
- Create database
- Publish security rules (see **Firebase Overview** below)

---

## Firestore Security Rules (essentials)

Allow each authenticated user to manage their own `/users/{uid}` subtree, including deletes of documents and subcollections:

```js
rules_version = '2',

service cloud.firestore {
match /databases/{database}/documents {

// Owner-only access to the entire /users/{uid} subtree
match /users/{uid}/{document=**} {
allow read, write: if request.auth != null && request.auth.uid == uid,
}
}
}
```

> If you prefer more granular collections, the rule above still covers deletes and bulk operations (e.g., removing the user doc and subcollections).

---

## Google Sign‑In (Quick Setup)

1) **Add packages (SPM):** `GoogleSignIn` and `GoogleSignInSwift`  
2) **Info.plist:** add `REVERSED_CLIENT_ID` (from `GoogleService-Info.plist`) as a **URL Type**  
3) **Bootstrap at launch** in `CineMate.init()`:
```swift
FirebaseBootstrap.ensureConfigured()
GoogleSignInBootstrap.ensureConfigured()
```
4) **Handle OAuth redirect** in your scene tree:
```swift
.handleGoogleSignInURL()
```
5) **Use the official SwiftUI button** and exchange tokens with Firebase (see code in project).

> Previews: All Google/Firebase paths are guarded by `ProcessInfo.processInfo.isPreview` so Xcode Previews stay offline.

---

## Project Setup (Xcode)

1. Open project in **Xcode 15.3** or later  
2. Add `Secrets.plist` (see template in `Resources/Secrets/Secrets.example.plist`)  
3. Add `GoogleService-Info.plist` to the app target  
4. In **Firebase Console**: enable Anonymous, Email/Password, Google enable Firestore, publish rules  
5. Select iOS **17.4+** device/simulator and run (**Cmd+R**)

---

## Architecture & Design

- **MVVM** with focused ViewModels driving SwiftUI views  
- **Init‑based DI** (Simple DI) for testability (no `@EnvironmentObject` required)  
- **Repository pattern** for TMDB + mocks  
- **Enum‑driven navigation** (`AppRoute` / `AppNavigator`) with push/replace semantics  
- **Preview‑first**: `PreviewFactory`, shared mock data, and `ProcessInfo.isPreview` guards  
- **Caching & in‑flight guards** to prevent duplicates and UI flicker  
- **Pagination / Infinite scroll** with explicit state  
- **Region‑awareness** via `Locale.current.region?.identifier`

### Guest Gating flow (Discover & Search)
- Root decides if guest: `authViewModel.isGuest`
- Content rendered but `.allowsHitTesting(false)` stops interaction
- `LockedFeatureOverlay` on top with CTA to Create Account
- When the user signs up:
- If **anonymous**: we **link** anon -> email/password, **send verification**, then **sign out**
- If **not anonymous**: normal sign‑up, **send verification**, then **sign out**

---

## Account Deletion (implementation notes)

- `AuthViewModel.deleteCurrentAccount()` orchestrates:
1. Delete Firestore data under `/users/{uid}` (subcollections first)  
2. Delete Firebase Auth user (`deleteAccountTolerantForAnonymous()` handles anon recent‑login)  
3. `signOut()` and clear local state
- UI: `AccountDangerZoneView` shows inline `LoadingView`, success/failure signaled via `ToastCenter`.
- External identity (Google/Apple) is **not** deleted — only the Firebase user and Firestore data for this app.

---

## Navigation

Centralized, enum‑based navigation using `AppRoute` and `AppNavigator`.  
Supports push/replace, decoupled programmatic flows, and deterministic behavior for testing.

```swift
navigator.goToCreateAccount()
```

---

## Folder Structure

```
CineMate/
├── CineMateApp.swift
├── Info.plist
├── Core/
│   ├── Config/
│   ├── Models/
│   ├── Networking/
│   ├── Repository/
│   └── Utilities/
├── Features/
│   ├── Discover/
│   ├── SeeAllMovies/
│   ├── Search/
│   ├── Favorites/
│   ├── Account/
│   │   └── Auth/
│   │       ├── Views/
│   │       │   ├── LoginView.swift
│   │       │   ├── CreateAccountView.swift
│   │       │   └── ResetPasswordSheet.swift
│   │       ├── ViewModels/
│   │       │   ├── LoginViewModel.swift
│   │       │   ├── CreateAccountViewModel.swift
│   │       │   └── ResetPasswordViewModel.swift
│   │       └── Components/
│   │           ├── AuthEmailField.swift
│   │           ├── AuthPasswordField.swift
│   │           ├── ValidationMessageView.swift
│   │           ├── LockedFeatureOverlay.swift
│   │           ├── LoadingView.swift
│   │           └── ErrorMessageView.swift
│   └── Genre/
├── UI/
│   ├── Components/
│   │   ├── RoundedField.swift
│   │   └── TrailingIcon.swift
│   └── Common/
│       └── Extensions/
│           └── View+Focus.swift
├── Previews/
│   ├── Factory/
│   ├── Data/
│   └── Mocks/
├── Resources/
│   ├── Assets.xcassets/
│   ├── Assets/
│   │   ├── popular_to_detail.gif
│   │   ├── favorites_realtime.gif
│   │   └── search_infinite_scroll.gif
│   └── Secrets/
│       └── Secrets.example.plist
└── README.md
```

---

## Roadmap
- Profile management (change email/password)

---

## External Resources
- TMDB — https://www.themoviedb.org/
- Firebase — https://firebase.google.com/
- Google Sign‑In for iOS — https://developers.google.com/identity/sign-in/ios
- GoogleSignInSwift (SwiftUI button) — https://github.com/google/GoogleSignIn-iOS

---

## Portfolio / Contact

I’m seeking a **LIA (internship)**. Open to remote/hybrid — based in **Stockholm (Haninge)**.  
**LinkedIn:** https://www.linkedin.com/in/nicholas-samuelsson-jeria-69778391

---

## Legal & Attribution

- This product uses the TMDB API but is **not endorsed or certified by TMDB**.
- Streaming availability data is provided by **JustWatch**.
- Movie posters, backdrops, and logos are © their respective owners and are shown via TMDB, they are not included in this repository’s license and must not be redistributed.

**Links**
- TMDB: https://www.themoviedb.org  • Terms: https://www.themoviedb.org/terms-of-use  • API: https://developer.themoviedb.org/
- JustWatch: https://www.justwatch.com/

**In-app attribution**
- Display “Powered by TMDB” (with the TMDB logo/link) somewhere visible in the app (e.g., About/Settings or on detail screens).
- When showing “Where to watch”, also display “Data provided by JustWatch” with a link to justwatch.com.

**License note**
- The application code is licensed as per this repo’s LICENSE. Third-party trademarks and media (TMDB/JustWatch assets, posters, logos) are excluded from the code license.

---

## Project Status

CineMate is stable and usable today. Development continues **part-time** while I focus on new courses, so updates may be irregular.  
If you hit an issue or want to propose an improvement, please **open a GitHub Issue**—I’ll respond as time allows.

---

Enjoy exploring **CineMate**!

> *“Do. Or do not. There is no try.”* — Yoda
