import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';

@Injectable()
export class UserService {
    constructor(private readonly db: DatabaseService) { }

    async readUser(uid: string): Promise<any | null> {
        return await this.db.read(`users/${uid}`);
    }

    async writeUser(uid: string, data: any, onlyIfAbsent = false): Promise<void> {
        if (onlyIfAbsent) {
            const existing = await this.readUser(uid);
            if (existing) return;
        }
        await this.db.write(`users/${uid}`, data);
    }

    async updateUser(uid: string, updates: Record<string, any>): Promise<void> {
        await this.db.update(`users/${uid}`, {
            ...updates,
            updatedAt: new Date().toISOString(),
        });
    }

    async deleteUser(uid: string): Promise<void> {
        await this.db.delete(`users/${uid}`);
    }

    async initUser(user: {
        uid: string;
        email?: string;
        name?: string;
        picture?: string;
        [key: string]: any;
    }, loginMethod?: string): Promise<void> {
        const existing = await this.readUser(user.uid);
        const now = new Date().toISOString();

        const defaultData = {
            name: user.name ?? '',
            email: user.email ?? '',
            nickname: user.name ?? '',
            photoUrl: user.picture ?? '',
            loginMethod,
            createdAt: now,
            updatedAt: now,
            projectIds: {},
            averageScore: 0.0,
            targetScore: 90.0,
            cpm: 0.0,
        };

        if (!existing) {
            await this.writeUser(user.uid, defaultData);
        } else {
            const missingFields = Object.entries(defaultData).reduce((acc, [key, value]) => {
                if (!(key in existing)) acc[key] = value;
                return acc;
            }, {} as Record<string, any>);

            if (Object.keys(missingFields).length > 0) {
                await this.updateUser(user.uid, missingFields);
            }
        }
    }
}
