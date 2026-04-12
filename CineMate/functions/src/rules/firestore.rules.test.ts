import { readFile } from "node:fs/promises"
import { resolve } from "node:path"
import { after, afterEach, before, test } from "node:test"

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from "@firebase/rules-unit-testing"
import { doc, setDoc, serverTimestamp } from "firebase/firestore"

const CURRENT_TERMS_VERSION = "2026-04-10"

let testEnv: RulesTestEnvironment

function ownerDb(uid: string) {
  return testEnv.authenticatedContext(uid).firestore()
}

async function seedTermsAcceptance(
  uid: string,
  {
    termsVersion = CURRENT_TERMS_VERSION,
    includeAcceptedAt = true,
    appVersion = "1.0.0",
  }: {
    termsVersion?: string
    includeAcceptedAt?: boolean
    appVersion?: string
  } = {}
) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore()
    const data: Record<string, unknown> = {
      termsVersion,
      appVersion,
    }
    if (includeAcceptedAt) {
      data.acceptedAt = new Date("2026-04-10T00:00:00Z")
    }

    await setDoc(doc(db, "users", uid), data, { merge: true })
  })
}

before(async () => {
  const rules = await readFile(resolve(process.cwd(), "../firestore.rules"), "utf8")
  testEnv = await initializeTestEnvironment({
    projectId: `cinemate-rules-${Date.now()}`,
    firestore: {
      rules,
      host: "127.0.0.1",
      port: 8080,
    },
  })
})

afterEach(async () => {
  await testEnv.clearFirestore()
})

after(async () => {
  await testEnv.cleanup()
})

test("owner can write acceptance metadata on own user document", async () => {
  const uid = "alice"
  const db = ownerDb(uid)

  await assertSucceeds(
    setDoc(
      doc(db, "users", uid),
      {
        termsVersion: CURRENT_TERMS_VERSION,
        acceptedAt: serverTimestamp(),
        appVersion: "2.4.1",
      },
      { merge: true }
    )
  )
})

test("owner cannot write favorites before accepting current terms", async () => {
  const uid = "alice"
  const db = ownerDb(uid)

  await assertFails(
    setDoc(
      doc(db, "users", uid, "favorites", "1"),
      {
        id: 1,
        title: "Movie A",
        createdAt: serverTimestamp(),
      },
      { merge: true }
    )
  )
})

test("owner can write favorites after accepting current terms", async () => {
  const uid = "alice"
  await seedTermsAcceptance(uid)
  const db = ownerDb(uid)

  await assertSucceeds(
    setDoc(
      doc(db, "users", uid, "favorites", "1"),
      {
        id: 1,
        title: "Movie A",
        createdAt: serverTimestamp(),
      },
      { merge: true }
    )
  )
})

test("owner cannot write favorites when accepted terms version is stale", async () => {
  const uid = "alice"
  await seedTermsAcceptance(uid, { termsVersion: "2026-01-01" })
  const db = ownerDb(uid)

  await assertFails(
    setDoc(
      doc(db, "users", uid, "favorites", "1"),
      {
        id: 1,
        title: "Movie A",
        createdAt: serverTimestamp(),
      },
      { merge: true }
    )
  )
})

test("owner cannot write favorites when acceptedAt is missing", async () => {
  const uid = "alice"
  await seedTermsAcceptance(uid, { includeAcceptedAt: false })
  const db = ownerDb(uid)

  await assertFails(
    setDoc(
      doc(db, "users", uid, "favorites", "1"),
      {
        id: 1,
        title: "Movie A",
        createdAt: serverTimestamp(),
      },
      { merge: true }
    )
  )
})

test("non owner cannot write another user's subtree even when terms are accepted", async () => {
  const ownerUid = "alice"
  const attackerUid = "mallory"
  await seedTermsAcceptance(ownerUid)
  const attackerDb = ownerDb(attackerUid)

  await assertFails(
    setDoc(
      doc(attackerDb, "users", ownerUid, "favorites", "1"),
      {
        id: 1,
        title: "Movie A",
        createdAt: serverTimestamp(),
      },
      { merge: true }
    )
  )
})
