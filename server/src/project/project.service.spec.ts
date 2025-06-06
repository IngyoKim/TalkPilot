import { Test, TestingModule } from '@nestjs/testing';
import { ProjectService } from './project.service';
import { DatabaseService } from '../database/database.service';
import { ProjectModel } from '../models/project.model';

describe('ProjectService', () => {
    let service: ProjectService;
    let mockDatabaseService: Partial<DatabaseService>;

    beforeEach(async () => {
        mockDatabaseService = {
            write: jest.fn(),
            read: jest.fn(),
            fetch: jest.fn(),
            update: jest.fn(),
            delete: jest.fn(),
        };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                ProjectService,
                { provide: DatabaseService, useValue: mockDatabaseService },
            ],
        }).compile();

        service = module.get<ProjectService>(ProjectService);
    });

    it('createProject should write project data', async () => {
        const project = { id: 'test_project', title: 'Test Project' } as ProjectModel;

        await service.createProject(project);

        expect(mockDatabaseService.write).toHaveBeenCalledWith(`projects/${project.id}`, project);
    });

    it('getProjectById should return project with defaults applied', async () => {
        const projectData = { id: 'test_project', title: 'Test Project' };
        (mockDatabaseService.read as jest.Mock).mockResolvedValue(projectData);

        const result = await service.getProjectById('test_project');

        expect(result).toEqual(
            expect.objectContaining({
                id: 'test_project',
                title: 'Test Project',
                scheduledDate: '',
                script: '',
                memo: '',
                estimatedTime: 0,
                score: 0,
                status: 'preparing',
                scriptParts: [],
                keywords: [],
            }),
        );

        expect(mockDatabaseService.read).toHaveBeenCalledWith('projects/test_project');
    });

    it('getAllProjects should return all projects with defaults applied', async () => {
        const projectsData = [
            { title: 'Project 1' },
            { title: 'Project 2' },
        ];

        (mockDatabaseService.fetch as jest.Mock).mockResolvedValue([
            { ...projectsData[0], id: 'id1' },
            { ...projectsData[1], id: 'id2' },
        ]);

        const result = await service.getAllProjects();

        expect(result).toHaveLength(2);
        expect(result[0]).toEqual(
            expect.objectContaining({
                id: 'id1',
                title: 'Project 1',
                scheduledDate: '',
                script: '',
                memo: '',
                estimatedTime: 0,
                score: 0,
                status: 'preparing',
                scriptParts: [],
                keywords: [],
            }),
        );
        expect(mockDatabaseService.fetch).toHaveBeenCalledWith('projects', expect.any(Function));
    });

    it('updateProject should update project data with updatedAt', async () => {
        const updates = { title: 'updated title' };

        await service.updateProject('test_project', updates);

        expect(mockDatabaseService.update).toHaveBeenCalledWith(
            'projects/test_project',
            expect.objectContaining({
                title: 'updated title',
                updatedAt: expect.any(String),
            }),
        );
    });

    it('deleteProject should delete project', async () => {
        await service.deleteProject('test_project');

        expect(mockDatabaseService.delete).toHaveBeenCalledWith('projects/test_project');
    });

    it('getProjectById should return null if project does not exist', async () => {
        (mockDatabaseService.read as jest.Mock).mockResolvedValue(null);

        const result = await service.getProjectById('non_existing_project');

        expect(result).toBeNull();
        expect(mockDatabaseService.read).toHaveBeenCalledWith('projects/non_existing_project');
    });
});
