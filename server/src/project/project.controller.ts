import {
    Controller, Get, Post, Patch, Delete,
    Param, Query, Body, NotFoundException
} from '@nestjs/common';
import { ProjectService } from './project.service';
import { ProjectModel } from '../models/project.model';
import { v4 as uuidv4 } from 'uuid';

@Controller('project')
export class ProjectController {
    constructor(private readonly projectService: ProjectService) { }

    @Post()
    async create(@Body() data: Omit<ProjectModel, 'id' | 'createdAt' | 'updatedAt'>) {
        const now = new Date().toISOString();
        const project: ProjectModel = {
            ...data,
            id: uuidv4(),
            createdAt: now,
            updatedAt: now,
        };
        await this.projectService.createProject(project);
        return { success: true, id: project.id };
    }

    @Get(':id')
    async getById(@Param('id') id: string) {
        const project = await this.projectService.getProjectById(id);
        if (!project) throw new NotFoundException('Project not found');
        return project;
    }

    @Get()
    async getAll(@Query('uid') uid?: string) {
        const allProjects = await this.projectService.getAllProjects();
        if (!uid) return allProjects;

        return allProjects.filter(p => p.participants && p.participants[uid]);
    }

    @Patch(':id')
    async update(@Param('id') id: string, @Body() updates: Partial<ProjectModel>) {
        await this.projectService.updateProject(id, updates);
        return { success: true };
    }

    @Delete(':id')
    async delete(@Param('id') id: string) {
        await this.projectService.deleteProject(id);
        return { success: true };
    }
}
