import { Injectable } from '@nestjs/common';
import { admin } from '../auth/firebase-admin';

@Injectable()
export class DatabaseService {
    private db = admin.database();

    async read(path: string): Promise<any> {
        const snapshot = await this.db.ref(path).once('value');
        return snapshot.val();
    }

    async write(path: string, data: any): Promise<void> {
        await this.db.ref(path).set(data);
    }

    async update(path: string, data: any): Promise<void> {
        await this.db.ref(path).update(data);
    }

    async delete(path: string): Promise<void> {
        await this.db.ref(path).remove();
    }
}
