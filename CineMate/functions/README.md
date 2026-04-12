# Firebase Functions (User Cleanup)

This folder contains backend cleanup automation for account deletion.

## What it does

- `cleanupUserDataOnDelete` runs when a Firebase Auth user is deleted.
- It recursively deletes `/users/{uid}` and all nested subcollections.
- Firestore rules tests check terms enforcement for user data writes.

## First-time setup

1. Set your Firebase project id in `.firebaserc`.
2. Install dependencies:
   - `cd functions`
   - `npm install`
3. Deploy:
   - `npm run deploy`

## Firestore rules tests

- Run emulator tests:
  - `npm run test:rules`
- This starts the Firestore emulator, runs the rules test suite, and stops the emulator.

## Terms notification scaffold

- `onTermsVersionPublished` listens to `legal/terms_versions/{version}`
- It updates `legal/config/current`
- For major versions it creates jobs in `legal/terms_email_jobs` and a pending batch in `legal/terms_email_batches/{version}`
- `processTermsEmailJobs` runs every 5 minutes and moves jobs from queued to sent or retry or failed
- `emailProvider.ts` supports dry run by default
- Set `TERMS_EMAIL_DRY_RUN=false` and `TERMS_EMAIL_WEBHOOK_URL` to enable real delivery
- Optional `TERMS_EMAIL_WEBHOOK_AUTH` adds Bearer auth to webhook requests
- Optional `APP_TERMS_URL` overrides the terms link used in email payloads

## Notes

- Cleanup happens asynchronously after auth account deletion.
- The iOS app no longer deletes Firestore data locally during account deletion.
