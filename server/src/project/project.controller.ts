import {
    Controller, Get, Post, Patch, Delete,
    Param, Query, Body, NotFoundException,
    Req
} from '@nestjs/common';
import { ProjectService } from './project.service';
import { ProjectModel } from '../models/project.model';
import { v4 as uuidv4 } from 'uuid';
import { UserService } from '../user/user.service';

@Controller('project')
export class ProjectController {
    constructor(private readonly projectService: ProjectService,
        private readonly userService: UserService,
    ) { }

    @Post()
    async create(
        @Body() data: Pick<ProjectModel, 'title' | 'description'>,
        @Req() req: Request,
    ) {
        const uid = (req as any).user?.uid;
        const now = new Date().toISOString();
        const projectId = uuidv4();

        const project: ProjectModel = {
            ...data,
            id: projectId,
            createdAt: now,
            updatedAt: now,
            ownerUid: uid,
            participants: { [uid]: 'owner' },
            status: 'preparing',
            estimatedTime: 0,
            score: 0,
            script: '',
            scheduledDate: '',
            memo: '',
            scriptParts: [],
            keywords: [],
        };

        await this.projectService.createProject(project);

        await this.userService.updateUser(uid, {
            projectIds: {
                ...(await this.userService.readUser(uid)).projectIds ?? {},
                [projectId]: project.status,
            },
        });

        return { success: true, id: projectId };
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
    async delete(@Param('id') id: string): Promise<void> {
        const project = await this.getById(id);
        if (!project) return;

        const participants = Object.keys(project.participants || {});
        for (const uid of participants) {
            const user = await this.userService.readUser(uid);
            if (user?.projectIds?.[id]) {
                const { [id]: _, ...rest } = user.projectIds;
                await this.userService.updateUser(uid, { projectIds: rest });
            }
        }

        await this.projectService.deleteProject(id);
    }
}
