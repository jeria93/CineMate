import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import * as functions from "firebase-functions/v1";

initializeApp();

export const cleanupUserDataOnDelete = functions
  .region("europe-west1")
  .auth.user()
  .onDelete(async (user) => {
    const uid = user.uid;
    if (!uid) {
      functions.logger.warn("cleanupUserDataOnDelete called without uid");
      return;
    }

    const db = getFirestore();
    const userDoc = db.doc(`users/${uid}`);

    try {
      await db.recursiveDelete(userDoc);
      functions.logger.info("Deleted Firestore user subtree", { uid });
    } catch (error) {
      functions.logger.error("Failed to delete Firestore user subtree", { uid, error });
      throw error;
    }
  }
);
