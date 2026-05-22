# Firebase Rules Tests

This folder is only used for Firestore rules tests.

## Active Backend

- No Cloud Functions are deployed from this project.
- Account deletion uses local cleanup for known user data collections.
- Firestore rules require current `termsVersion`, `privacyVersion`, and `acceptedAt` before protected writes.
- Owners can delete their own user data even when legal acceptance is missing or outdated.

## Setup

1. Set the Firebase project id in `.firebaserc`.
2. Install test dependencies:
   - `cd functions`
   - `npm install`

## Tests

- Run Firestore rules tests:
  - `npm run test:rules`
- This starts the Firestore emulator, runs the rules suite, and stops the emulator.

## Legal Release Checklist

1. Check that `TermsContent.currentVersion` and `TermsContent.privacyPolicyVersion` match `firestore.rules`.
2. Check that Terms and Privacy sheets show the correct `Last updated` date.
3. Run `npm run test:rules`.
4. Deploy updated Firestore rules:
   - `firebase deploy --only firestore:rules --project cinemate-bec9f`
5. Confirm `firebase functions:list --project cinemate-bec9f` is empty.
