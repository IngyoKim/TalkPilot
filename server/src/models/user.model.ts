export class UserModel {
    uid: string;
    name: string;
    email: string;
    nickname: string;
    photoUrl?: string;
    loginMethod?: string;
    createdAt?: string;
    updatedAt?: string;
    projectIds?: Record<string, string>;
    averageScore?: number;
    targetScore?: number;
    cpm?: number;
}
