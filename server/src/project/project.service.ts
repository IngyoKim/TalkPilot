import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { ProjectModel } from '../models/project.model';

@Injectable()
export class ProjectService {
    constructor(private readonly db: DatabaseService) { }

    async createProject(project: ProjectModel): Promise<void> {
        await this.db.write(`projects/${project.id}`, project);
    }

    private applyDefaults(project: ProjectModel): ProjectModel {
        return {
            ...project,
            scheduledDate: project.scheduledDate ?? '',
            script: project.script ?? '',
            memo: project.memo ?? '',
            estimatedTime: project.estimatedTime ?? 0,
            score: project.score ?? 0,
            status: project.status ?? 'preparing',
            scriptParts: project.scriptParts ?? [],
            keywords: project.keywords ?? [],
        };
    }

    async getProjectById(id: string): Promise<ProjectModel | null> {
        const project = await this.db.read(`projects/${id}`);
        return project ? this.applyDefaults(project) : null;
    }

    async getAllProjects(): Promise<ProjectModel[]> {
        const projects = await this.db.fetch(`projects`, (item, key) => ({
            ...item,
            id: key,
        }));
        return projects.map(p => this.applyDefaults(p));
    }

    async updateProject(id: string, updates: Partial<ProjectModel>): Promise<void> {
        await this.db.update(`projects/${id}`, {
            ...updates,
            updatedAt: new Date().toISOString(),
        });
    }

    async deleteProject(id: string): Promise<void> {
        await this.db.delete(`projects/${id}`);
    }
}
