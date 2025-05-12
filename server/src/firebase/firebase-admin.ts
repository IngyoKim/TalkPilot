import * as admin from 'firebase-admin';
import { readFileSync } from 'fs';
import { join } from 'path';

const serviceAccount = JSON.parse(
    readFileSync(join(__dirname, '../../credentials/firebase-admin-key.json'), 'utf8'),
);

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

export { admin };
