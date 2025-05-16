import * as admin from 'firebase-admin';
import { readFileSync } from 'fs';

export function initializeFirebase() {
    const keyPath = process.env.FIREBASE_ADMIN_KEY_PATH || '/etc/secrets/firebase-admin-key.json';
    const parsed = JSON.parse(readFileSync(keyPath, 'utf-8'));

    if (admin.apps.length === 0) {
        admin.initializeApp({
            credential: admin.credential.cert(parsed),
            databaseURL: process.env.FIREBASE_DATABASE_URL,
        });
    }
}

export { admin };
