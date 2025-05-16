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
                this.logger.log(`[READ] ${path}`, JSON.stringify(value));
            }

            return value;
        } catch (error) {
            this.logger.error(`[READ] ${path}`, error instanceof Error ? error.stack : String(error));
            throw error;
        }
    }

    async write(path: string, data: any): Promise<void> {
        try {
            await this.db.ref(path).set(data);
            this.logger.log(`[WRITE] ${path}`, JSON.stringify(data));
        } catch (error) {
            this.logger.error(`[WRITE] ${path}`, error instanceof Error ? error.stack : String(error));
            throw error;
        }
    }

    async update(path: string, data: any): Promise<void> {
        try {
            await this.db.ref(path).update(data);
            this.logger.log(`[UPDATE] ${path}`, JSON.stringify(data));
        } catch (error) {
            this.logger.error(`[UPDATE] ${path}`, error instanceof Error ? error.stack : String(error));
            throw error;
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

            this.logger.log(`[FETCH] ${path}`, JSON.stringify(result));
            return result;
        } catch (error) {
            this.logger.error(`[FETCH] ${path}`, error instanceof Error ? error.stack : String(error));
            throw error;
        }
    }

    async delete(path: string): Promise<void> {
        try {
            await this.db.ref(path).remove();
            this.logger.log(`[DELETE] ${path} - success`);
        } catch (error) {
            this.logger.error(`[DELETE] ${path}`, error instanceof Error ? error.stack : String(error));
            throw error;
        }
    }
}
