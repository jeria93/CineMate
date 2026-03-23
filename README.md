# CineMate

CineMate is a SwiftUI iOS app for browsing, discovering, and saving movies powered by TMDB.
It uses Firebase Auth + Firestore for user sessions and favorites.

## Demo

- Vimeo demo: [Watch CineMate in action](https://vimeo.com/1117585898)

| Browse -> Detail | Real-time Favorites | Search + Infinite Scroll |
|---|---|---|
| <img src="Assets/popular_to_detail.gif" width="260" alt="Browse list to movie detail" /> | <img src="Assets/favorites_realtime.gif" width="260" alt="Toggle favorites with real-time updates" /> | <img src="Assets/search_infinite_scroll.gif" width="260" alt="Search with infinite scroll" /> |

## Quick Start

1. Clone the repo.
2. Copy `CineMate/Secrets.example.plist` -> `CineMate/Secrets.plist` and add TMDB values.
3. Add your real `GoogleService-Info.plist` to the app target in Xcode.
4. In Firebase Console, enable `Anonymous`, `Email/Password`, and `Google` sign-in.
5. Create Firestore and publish your security rules.
6. Open `CineMate.xcodeproj`, choose an iOS 17.4+ simulator/device, and run.

## Prerequisites

| File | Location | Purpose |
|---|---|---|
| `Secrets.plist` | `CineMate/Secrets.plist` | TMDB API keys/tokens |
| `GoogleService-Info.plist` | Added to app target in Xcode | Firebase + Google Sign-In config |

Recommended setup: Xcode 15.3+.

## Feature Overview

### Movies
- Popular, top-rated, trending, upcoming, now-playing lists
- Movie detail with credits, recommendations, trailers, and watch providers
- Genre filtering and "See all" pagination flow

### Search
- Debounced query validation
- Infinite scrolling with pagination and in-flight guards

### Favorites
- Favorite movies and favorite people
- Firestore-backed real-time updates per signed-in user

### Auth & Account
- Email/password sign up + verification email + sign-out policy
- Email/password sign in (verification enforced)
- Google Sign-In (Firebase credential exchange)
- Guest mode (anonymous)
- Reset password and resend verification
- Account deletion with Firestore data cleanup

### Guest Gating
- Discover and Search are visually available but interaction-locked for guests
- Locked overlay CTA routes to Create Account

## Architecture (Short)

- SwiftUI + MVVM
- Init-based dependency injection for repositories/services/view models
- Repository pattern for TMDB and preview mocks
- Enum-based app navigation (`AppRoute` + `AppNavigator`) in signed-in flow
- Preview-first structure (`PreviewFactory`, preview data, `ProcessInfo.isPreview` guards)

## Deep Dive Links

- Firebase setup notes: [`CineMate.xcodeproj/FirebaseConfig-README.md`](CineMate.xcodeproj/FirebaseConfig-README.md)
- App bootstrap and auth gate: [`CineMate/CineMateApp.swift`](CineMate/CineMateApp.swift)
- Navigation core:
  - [`CineMate/Core/Navigation/AppRoute.swift`](CineMate/Core/Navigation/AppRoute.swift)
  - [`CineMate/Core/Navigation/AppNavigator.swift`](CineMate/Core/Navigation/AppNavigator.swift)
  - [`CineMate/Core/Navigation/RootView.swift`](CineMate/Core/Navigation/RootView.swift)
- Auth implementation:
  - [`CineMate/Core/Firebase/Auth/Services/FirebaseAuthService.swift`](CineMate/Core/Firebase/Auth/Services/FirebaseAuthService.swift)
  - [`CineMate/Core/Firebase/Auth/Services/FirebaseAuthService+Deletion.swift`](CineMate/Core/Firebase/Auth/Services/FirebaseAuthService+Deletion.swift)
  - [`CineMate/Features/Account/Auth/`](CineMate/Features/Account/Auth/)
- Preview architecture:
  - [`CineMate/Features/Previews/`](CineMate/Features/Previews/)
  - [`CineMate/Features/Account/Auth/PreviewData/`](CineMate/Features/Account/Auth/PreviewData/)
