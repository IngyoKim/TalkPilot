import { ScriptPartModel } from './script-part.model';

export interface ProjectModel {
    id: string;
    title: string;
    description: string;
    createdAt?: string;
    updatedAt?: string;
    ownerUid: string;
    participants: Record<string, string>; // { uid : role }
    status: 'preparing' | 'completed';
    estimatedTime?: number; // 단위: 초
    score?: number;
    script?: string;
    scheduledDate?: string; // ISO string형식
    memo?: string;
    scriptParts?: ScriptPartModel[];
    keywords?: string[];
}
