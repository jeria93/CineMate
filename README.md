# CineMate

**CineMate** is a SwiftUI iOS app for browsing, filtering, and saving movies powered by The Movie Database (**TMDB**) API.  
It emphasizes clean architecture, responsive UI iteration, and secure secret handling — all built with modern Swift concurrency, enum-based navigation, and feature-first modularity.

**Key highlights:**  
- MVVM with init-based dependency injection  
- Enum-driven navigation (`AppRoute` / `AppNavigator`) with push/replace semantics for predictable routing  
- Region-aware content & streaming availability  
- Search with debounce, pagination, in-flight guard and caching  
- Previews + mocks for offline UI development  
- Secure API key management with sanitized history  

> **Recommended setup:** Xcode **15.3+** and iOS **17.4** (deployment targets include 17.4 and 18.5)  
> **Quick start:** clone → copy `Secrets.example.plist` to `Secrets.plist` → fill in TMDB credentials → Run in Xcode

---

## Prerequisites

You need the following local configuration files before running the app:

| File | Location | Purpose |
|------|----------|---------|
| `Secrets.plist` | `CineMate/Secrets.plist` | TMDB API keys and tokens |
| `GoogleService-Info.plist` | `CineMate/GoogleService-Info.plist` | Firebase config for Google Sign-In *(planned)* |

> These are **excluded from version control**. Use `Secrets.example.plist` as a template.

---

## Secrets & Security

The sensitive files below are ignored in Git and enforced via repository config (`.gitignore`, `.github/CODEOWNERS`):

- `Secrets.plist`  
- `GoogleService-Info.plist` *(future Firebase integration)*  

> **Historic note:** `Secrets.plist` was unintentionally committed early in development. In **June 2025** the Git history was rewritten/sanitized using `git-filter-repo` to purge any leaked secrets. Only `Secrets.example.plist` remains in history for safe reference.

---

## Project Setup (Xcode)

1. Open the project in **Xcode 15.3** or later.  
2. Add your `Secrets.plist`:
   - Right-click on the **CineMate** folder → **New File… → Property List**  
   - Name it `Secrets.plist`  
   - Open as source and add keys (example below):
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
3. *(Optional)* Add `GoogleService-Info.plist` from Firebase for planned Google Sign-In.  
4. Select device/simulator (iOS 17.4+) and run (Cmd+R).

---

## Architecture & Design

- **MVVM** with focused ViewModels driving SwiftUI views.  
- **Init-based dependency injection** for testability and simplicity.  
- **Repository pattern** abstracts the TMDB service layer and enables mocking.  
- **Enum-driven navigation** (`AppRoute` / `AppNavigator`) with push/replace semantics for deterministic routing and programmatic control.  
- **PreviewFactory + mocks** allow fast UI iteration without network dependency.  
- **Caching & in-flight protection** prevents duplicate API calls, reduces UI flicker, and improves perceived performance.  
- **Pagination / Infinite scroll** with explicit state (current page, total pages, loading guard) for long result sets.  
- **Region-awareness** using `Locale.current.region?.identifier` for localized content and streaming providers.  
- **Principles:** Single Responsibility (SRP), Separation of Concerns (SoC), minimal over-engineering.

---

## Caching & Network Efficiency

Goals:
- Avoid redundant network calls  
- Prevent concurrent duplicate requests (in-flight guard)  
- Provide instant responses for previously-searched queries  
- Reduce UI blinking when reloading same data  
- Bound memory usage via eviction/trimming  

Implementation highlights:
- In-memory cache keyed by normalized queries  
- `Set` tracks active in-flight queries  
- Pagination state per search for incremental loading  
- Preview shortcut bypasses real network calls (`ProcessInfo.processInfo.isPreview`)

---

## Navigation

Centralized, enum-based navigation using `AppRoute` and `AppNavigator`.  
Supports:
- Push and replace semantics  
- Decoupled programmatic flows  
- Deterministic behavior useful in testing  

Example usage:
```swift
navigator.goTo(.movieDetail(id: movie.id), replace: false)
```

---

## Previews & Mocks

- `PreviewFactory` supplies ViewModels in different UI states (loading, error, empty, populated).  
- `MockMovieRepository` and shared preview data enable offline rendering.  
- Helpers like `.withPreviewNavigation()` simulate realistic navigation context in canvas.

---

## Running the App

1. Open project in **Xcode 15.3**  
2. Select **iOS 17.4** simulator or real device  
3. Press **Cmd+R**

---

## Feature Demos

> **Watch CineMate in Action**  
> [Click here to view full demo on Vimeo »](https://vimeo.com/1098629918)

### Popular Movie List  
Scrollable list of popular movies with smooth loading and preview.

<img src="Assets/popular_list.gif" width="350" alt="Popular List Demo" />

### Genre Filtering  
Toggle between genres with instant feedback, cancellation, and in-memory caching.

<img src="Assets/genre_filtering.gif" width="350" alt="Genre Filtering Demo" />

### Movie Detail + Share  
View trailers, details and share movie info seamlessly.

<img src="Assets/movie_detail_share.gif" width="350" alt="Movie Detail & Share Demo" />

### List Scroll & Infinite Loading  
Smooth infinite scroll and pagination for search and long collections.

<img src="Assets/movie_list_scroll.gif" width="350" alt="Movie Scroll Demo" />

---

## Region-Based Streaming Support

CineMate detects the user's **current country** and adjusts:

- **Movie content** (Popular, Top Rated, Trending, Upcoming) per region (🇸🇪 Sweden, 🇮🇳 India, 🇨🇱 Chile, etc.)  
- **Streaming providers** (Netflix, HBO Max, Apple TV, etc.) available specifically for that region  

Handled automatically via:
```swift
Locale.current.region?.identifier ?? "US"
```

> Content is localized without user configuration.  

---

## Debug & Limitations

- **Simulator caveat:** `Locale.current.region` in Simulator follows macOS settings; real device gives more accurate region-based results.  
- **Streaming deep links:** Most provider links are web URLs; direct app opening is not guaranteed. TMDB does not expose custom deep link schemes like `netflix://` in a reliable way.  
- **Firebase / Google Sign-In:** Planned but not fully integrated yet.

---

## Planned / Roadmap

- Firebase Authentication (Google Sign-In)  
- Persistent or shared caching layer (beyond in-memory)  
- Enhanced offline support  
- Metrics / telemetry for cache hit/miss and latency analysis  

---

## External Resources

- [TMDB – The Movie Database](https://www.themoviedb.org/)  
- [Firebase](https://firebase.google.com/)  
- [Simple Icons](https://simpleicons.org/)  

---

## Portfolio

Demonstrates:
- Real-world async API integration with TMDB  
- Secure secret management and history sanitization  
- Enum-based deterministic navigation  
- State-driven SwiftUI with caching, debounce, pagination, and in-flight guards  
- Preview-first development for fast iteration  

> Star the repo if you find it useful or inspiring.

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
│   └── Genre/
├── UI/
│   └── Components/
├── Previews/
│   ├── Mocks/
│   ├── Factory/
│   └── Data/
├── Resources/
│   ├── Assets.xcassets/
│   └── Secrets/
└── README.md
```

---

## Google Sign-In Overview *(planned)*

> Firebase Authentication integration example:

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
