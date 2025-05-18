import * as admin from 'firebase-admin';
import { readFileSync } from 'fs';
import { Logger } from '@nestjs/common';

const logger = new Logger('Firebase');

export function initializeFirebase() {
    const keyPath = process.env.FIREBASE_ADMIN_KEY_PATH || '/etc/secrets/firebase-admin-key.json';
    const databaseURL = process.env.FIREBASE_DATABASE_URL;

    try {
        const parsed = JSON.parse(readFileSync(keyPath, 'utf-8'));

        if (admin.apps.length === 0) {
            admin.initializeApp({
                credential: admin.credential.cert(parsed),
                databaseURL,
            });
            logger.log('Firebase 초기화 완료');
        } else {
            logger.log('Firebase는 이미 초기화된 상태입니다.');
        }
    } catch (error) {
        logger.error('Firebase 초기화 실패', error.stack);
        throw error;
    }
}

export { admin };
