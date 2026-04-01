# Firebase Configuration

This file explains how the Firebase plist should be handled in this project.

## Valid Path In Repo

Place your real `GoogleService-Info.plist` here:

`CineMate/Core/Config/GoogleService-Info.plist`

This file is git-ignored and should not be committed.

## Setup

1. Download `GoogleService-Info.plist` from Firebase Console (Project settings -> Your apps -> iOS app).
2. Place the file in `CineMate/Core/Config/`.
3. Ensure the file is included in the app target in Xcode.
4. Verify that the URL scheme in `CineMate/Info.plist` matches `REVERSED_CLIENT_ID` from the plist.

## Optional Build Check

Add a Run Script in Build Phases to fail clearly when the plist is missing:

```sh
FILE="${SRCROOT}/CineMate/Core/Config/GoogleService-Info.plist"
if [ ! -f "$FILE" ]; then
  echo "error: Missing GoogleService-Info.plist. Download it from Firebase Console and place it at $FILE"
  exit 1
fi
```
