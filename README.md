# CineMate

**CineMate** is a SwiftUI-based iOS app that lets users browse, filter, and save movies using The Movie Database (**TMDB**) API.  
It uses **MVVM architecture**, clean SwiftUI views, and a modular structure with previews, mocking, and secure API access.  
**Planned support for Google Sign-In via Firebase Authentication.**

> **Recommended setup:** Xcode **15.3** + iOS **17.4** (simulator or real device)

---

## Prerequisites

Before running the app, you need two local configuration files:

| File | Location | Purpose |
|------|----------|---------|
| `Secrets.plist` | `CineMate/Secrets.plist` | Stores your TMDB API keys |
| `GoogleService-Info.plist` | `CineMate/GoogleService-Info.plist` | Firebase configuration for Google Sign-In *(planned)* |

> These files are **ignored in Git** to protect your secrets. Use the provided `Secrets.example.plist` as a reference.

---

## 🔐 Secrets & Security

These files are listed in `.gitignore` and protected by `.github/CODEOWNERS`:

- `Secrets.plist`
- `GoogleService-Info.plist` *(planned use with Firebase)*

This ensures sensitive data is never committed to GitHub, even by mistake.

> 🛡️ **Note:** `Secrets.plist` was accidentally committed earlier in development.  
> In **June 2025**, the full Git history was sanitized using [`git-filter-repo`](https://github.com/newren/git-filter-repo) to ensure no sensitive data remains in any commit.
> Only `Secrets.example.plist` remains for safe local use.

---

## Project Setup (Xcode)

### 1 — Add `Secrets.plist`

1. Open project in **Xcode 15.3**
2. In **CineMate** folder → right-click → **New File… → Property List**
3. Name it `Secrets.plist`
4. Open as **Source Code** and paste:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
<key>TMDB_API_KEY</key>
<string>PUT-YOUR-API-KEY-HERE</string>
<key>TMDB_BEARER_TOKEN</key>
<string>PUT-YOUR-BEARER-TOKEN-HERE</string>
</dict>
</plist>
```

### 2 — Add `GoogleService-Info.plist` *(optional for now)*

1. Go to **Firebase Console → Project Settings → General → Your Apps**
2. Download the `GoogleService-Info.plist`
3. Drag it into your **CineMate** folder in Xcode
4. Tick **"Copy if needed"**

---

## Architecture & Concepts

- MVVM (Model–View–ViewModel)
- **Simple Dependency Injection** (init-based, no factories)
- Repository Pattern for data abstraction
- Generic service layer for TMDB endpoints
- Preview-friendly setup using `MockMovieRepository` and `PreviewData`
- Secure API key management with `Secrets.plist` (ignored in Git)
- `.gitignore` and `.github/CODEOWNERS` for professional repo hygiene
- SwiftUI-only app using async/await and modern view composition
- Feature-first folder structure (Movies, People, Lists)
- SRP (Single Responsibility Principle) and SoC (Separation of Concerns)
- Icons sourced from [Simple Icons](https://simpleicons.org/)
- Planned support for Firebase Authentication (Google Sign-In)


---

## Running the App

1. Select a simulator running iOS 17.4 (e.g. iPhone 15)
2. Press **Cmd + R** or click ▶️ to build & run

---

## Feature Demos

> **Watch CineMate in Action**  
> [Click here to view full demo on Vimeo »](https://vimeo.com/user50225275)

### Popular Movie List

Displays a scrollable list of popular movies from TMDB.

<img src="Assets/popular_list.gif" width="350" alt="Popular List Demo" />

---

### Genre Filtering

Users can toggle between Popular, Top Rated, Trending, and Upcoming.

<img src="Assets/genre_filtering.gif" width="350" alt="Genre Filtering Demo" />

---

### Movie Detail + Share

Tap any movie to view trailer, details, and share it.

<img src="Assets/movie_detail_share.gif" width="350" alt="Movie Detail & Share Demo" />

---

### List Scroll Animation

Smooth scrolling UI powered by SwiftUI and async/await.

<img src="Assets/movie_list_scroll.gif" width="350" alt="Movie Scroll Demo" />

---
## Region-Based Streaming Support

CineMate automatically detects the user's **current country** and adjusts:

- **Movie content** (Popular, Top Rated, Trending, Upcoming) based on region (🇸🇪 Sweden, 🇮🇳 India, 🇨🇱 Chile, etc.)
- **Streaming services** (Netflix, HBO Max, Apple TV, etc.) available **specifically for that country**

This is handled automatically via:

```swift
Locale.current.region?.identifier ?? "US"
```

No user setup is needed — content is localized based on the device’s current region.

> If you're in Chile, you’ll see what’s trending there.  
> If you're in Sweden, you’ll get Swedish watch providers.

---

### Simulator & Debug Notes

> **Important:** The iOS Simulator may not reflect your real geographic location.

- `Locale.current.region` in Simulator follows **macOS settings**, not simulator device settings.
- You may not see expected content or watch providers when running on a Mac.
- For accurate testing, run CineMate on a **real device**.

Optional debugging tip:

```swift
#if DEBUG
print("Using region: \(region)")
#endif
```

You can even force a region in testing:

```swift
let region = "CL" // For testing Chile region
```

---

### Streaming App Limitations

While CineMate lists platforms where movies are available (e.g., Netflix, Apple TV, HBO Max):

- **Opening apps directly is not guaranteed**
- Most providers only expose **web URLs** (like `https://www.netflix.com/watch/XYZ`)
- Some platforms support **universal links** that redirect to the app *if installed* on a real device
- This behavior **does not work in Simulator**

> TMDB does **not** provide custom deep links like `netflix://` or `hbomax://`, so opening apps directly is limited.

Still — CineMate gives users **clear visibility** into which platforms host each movie, filtered by region.

---


## External Resources

- [TMDB – The Movie Database](https://www.themoviedb.org/)
- [Firebase](https://firebase.google.com/)
- [Simple Icons](https://simpleicons.org)

---

## Portfolio Notes

This app is part of my iOS development portfolio. It demonstrates:

- Real-world API handling (TMDB)
- Secure API key management
- UI/UX considerations with empty state views and genre filtering
- Professional GitHub setup (CODEOWNERS, branch protection, secrets ignored)
- Consideration for advanced patterns like Dependency Injection, SRP, and SoC
- ⭐️ If you find CineMate useful or inspiring, feel free to leave a star on GitHub — every bit of support is appreciated.

> This project is still evolving — new features and improvements are added continuously.

> Want to follow my journey?
**Connect on LinkedIn:** [nicholas-samuelsson-jeria](https://www.linkedin.com/in/nicholas-samuelsson-jeria-69778391)

> **Watch CineMate in Action**  
> [Click here to view full demo on Vimeo »](https://vimeo.com/user50225275)

---

## Folder Structure

The CineMate project follows a modular architecture with feature-based separation, MVVM, and reusable components.

```
CineMate/
├── CineMateApp.swift
├── Core/
│   ├── Config/
│   ├── Models/
│   ├── Networking/
│   ├── Repository/
│   └── Utilities/
├── Features/
│   ├── Movies/
│   ├── MovieList/
│   └── People/
├── UI/
│   └── Components/
├── Previews/
│   ├── Mocks/
│   ├── Factory/
│   └── Data/
├── Resources/
│   ├── Assets.xcassets/
│   └── Secrets/
└── Info.plist
```

---

## 🔐 Google Sign-In Overview *(planned)*

> Support for Firebase Authentication is in progress.  
> Below is a code example showing how sign-in will work:

```swift
let credential = GoogleAuthProvider.credential(
withIDToken: idToken,
accessToken: accessToken
)
Auth.auth().signIn(with: credential) { result, error in
// Signed in to Firebase
}
```

---

Enjoy exploring CineMate

> *“Do. Or do not. There is no try.”*  
> — Yoda
