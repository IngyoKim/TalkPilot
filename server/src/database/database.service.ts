import { Injectable, Logger } from '@nestjs/common';
import { admin } from '../auth/firebase-admin';

@Injectable()
export class DatabaseService {
    private readonly db = admin.database();
    private readonly logger = new Logger('DatabaseService');

    async read(path: string): Promise<any> {
        try {
            const snapshot = await this.db.ref(path).once('value');
            const value = snapshot.val();

            if (value === null || value === undefined) {
                this.logger.warn(`[READ] ${path} - no data`);
            } else {
                this.logger.log(`[READ] ${path}\n${JSON.stringify(value, null, 2)}`);
            }

            return value;
        } catch (e) {
            this.logger.error(`[READ] ${path}`, e instanceof e ? e.stack : String(e));
            throw e;
        }
    }

    async write(path: string, data: any): Promise<void> {
        try {
            await this.db.ref(path).set(data);
            this.logger.log(`[WRITE] ${path}\n${JSON.stringify(data, null, 2)}`);
        } catch (e) {
            this.logger.error(`[WRITE] ${path}`, e instanceof e ? e.stack : String(e));
            throw e;
        }
    }

    async update(path: string, data: any): Promise<void> {
        try {
            await this.db.ref(path).update(data);
            this.logger.log(`[UPDATE] ${path}\n${JSON.stringify(data, null, 2)}`);
        } catch (e) {
            this.logger.error(`[UPDATE] ${path}`, e instanceof e ? e.stack : String(e));
            throw e;
        }
    }

    async fetch<T = any>(
        path: string,
        map?: (item: any, key?: string) => T,
    ): Promise<T[]> {
        try {
            const snapshot = await this.db.ref(path).once('value');

            if (!snapshot.exists()) {
                this.logger.warn(`[FETCH] ${path} - no data`);
                return [];
            }

            const raw = snapshot.val();
            const result = Object.entries(raw).map(([key, value]) =>
                map ? map(value, key) : value,
            ) as T[];

            this.logger.log(`[FETCH] ${path}\n${JSON.stringify(result, null, 2)}`);
            return result;
        } catch (e) {
            this.logger.error(`[FETCH] ${path}`, e instanceof e ? e.stack : String(e));
            throw e;
        }
    }

    async delete(path: string): Promise<void> {
        try {
            await this.db.ref(path).remove();
            this.logger.log(`[DELETE] ${path} - success`);
        } catch (e) {
            this.logger.error(`[DELETE] ${path}`, e instanceof e ? e.stack : String(e));
            throw e;
        }
    }
}
