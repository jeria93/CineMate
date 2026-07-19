# Firebase Configuration

This file explains how local configuration is handled in this project.

## Portfolio Demo

The shared `CineMate` scheme uses `CINEMATE_RUNTIME=auto`.

- If both local plist files exist, the app starts in live mode.
- If either file is missing, the app starts in a local portfolio demo.
- The demo uses sample data and does not initialize Firebase or call the TMDB API.

A clean clone therefore builds and runs without personal configuration.

## Valid Path In Repo

Place your real `GoogleService-Info.plist` here:

`CineMate/Core/Config/GoogleService-Info.plist`

This file is git-ignored and should not be committed.

## Setup

1. Download `GoogleService-Info.plist` from Firebase Console (Project settings -> Your apps -> iOS app).
2. Place the file in `CineMate/Core/Config/`.
3. Copy `Secrets.example.plist` to `CineMate/Features/Resources/Secrets.plist` and add your TMDB key.
4. Verify that the URL scheme in `CineMate/Info.plist` matches `REVERSED_CLIENT_ID` from the Firebase plist.
5. Run the shared `CineMate` scheme. The build copies existing local plist files into the app bundle.

Both real plist files are git-ignored and should not be committed.

## Runtime Override

Set `CINEMATE_RUNTIME` in an Xcode scheme when an explicit mode is useful:

- `demo` always uses local sample data.
- `live` uses live services when both plist files exist and otherwise falls back to demo.
- `auto` selects live only when both plist files exist.
