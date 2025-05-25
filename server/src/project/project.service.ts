import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { ProjectModel } from '../models/project.model';

@Injectable()
export class ProjectService {
    constructor(private readonly db: DatabaseService) { }

    async createProject(project: ProjectModel): Promise<void> {
        await this.db.write(`projects/${project.id}`, project);
    }

    async getProjectById(id: string): Promise<ProjectModel | null> {
        return await this.db.read(`projects/${id}`);
    }

    async getAllProjects(): Promise<ProjectModel[]> {
        return await this.db.fetch(`projects`, (item, key) => ({
            ...item,
            id: key,
        }));
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
