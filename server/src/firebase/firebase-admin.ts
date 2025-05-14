import * as admin from 'firebase-admin';
import { readFileSync } from 'fs';
import { join } from 'path';

export function initializeFirebase() {
    const path = process.env.FIREBASE_ADMIN_KEY_PATH ?? '/etc/secrets/firebase-admin-key.json';
    const fullPath = join(process.cwd(), path);
    const parsed = JSON.parse(readFileSync(fullPath, 'utf-8'));

    if (admin.apps.length === 0) {
        admin.initializeApp({
            credential: admin.credential.cert(parsed),
        });
    }
}

export { admin };
