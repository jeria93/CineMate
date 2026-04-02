# Firebase Functions (User Cleanup)

This folder contains backend cleanup automation for account deletion.

## What it does

- `cleanupUserDataOnDelete` runs when a Firebase Auth user is deleted.
- It recursively deletes `/users/{uid}` and all nested subcollections.

## First-time setup

1. Set your Firebase project id in `.firebaserc`.
2. Install dependencies:
   - `cd functions`
   - `npm install`
3. Deploy:
   - `npm run deploy`

## Notes

- Cleanup happens asynchronously after auth account deletion.
- The iOS app no longer deletes Firestore data locally during account deletion.
