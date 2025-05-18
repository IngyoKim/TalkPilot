import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';

@Injectable()
export class UserService {
    constructor(private readonly db: DatabaseService) { }

    async readUser(uid: string): Promise<any | null> {
        return await this.db.read(`users/${uid}`);
    }

    async writeUser(uid: string, userData: Record<string, any>, onlyIfAbsent = false): Promise<void> {
        if (onlyIfAbsent) {
            const existing = await this.readUser(uid);
            if (existing !== null) return;
        }
        await this.db.write(`users/${uid}`, userData);
    }

    async updateUser(uid: string, updates: Record<string, any>): Promise<void> {
        const fullUpdates = {
            ...updates,
            updatedAt: new Date().toISOString(),
        };
        await this.db.update(`users/${uid}`, fullUpdates);
    }

    async deleteUser(uid: string): Promise<void> {
        await this.db.delete(`users/${uid}`);
    }

    async initUser(decodedUser: {
        uid: string;
        email?: string;
        name?: string;
        picture?: string;
        firebase?: {
            sign_in_provider?: string;
        };
    }, loginMethod?: string): Promise<void> {
        const existing = await this.readUser(decodedUser.uid);
        const now = new Date().toISOString();

        const newFields = {
            name: decodedUser.name ?? '',
            email: decodedUser.email ?? '',
            nickname: decodedUser.name ?? '',
            photoUrl: decodedUser.picture ?? '',
            loginMethod: loginMethod ?? decodedUser.firebase?.sign_in_provider ?? 'unknown',
            createdAt: now,
            updatedAt: now,
            projectIds: {},
            averageScore: 0.0,
            targetScore: 90.0,
            cpm: 0.0,
        };

        if (!existing) {
            await this.writeUser(decodedUser.uid, newFields);
        } else {
            const missingFields = Object.entries(newFields).reduce((acc, [key, value]) => {
                if (!(key in existing)) acc[key] = value;
                return acc;
            }, {} as Record<string, any>);

            if (Object.keys(missingFields).length > 0) {
                await this.updateUser(decodedUser.uid, missingFields);
            }
        }
    }
}
