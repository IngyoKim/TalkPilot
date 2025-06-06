import { Test, TestingModule } from '@nestjs/testing';
import { UserService } from './user.service';
import { DatabaseService } from '../database/database.service';

describe('UserService', () => {
    let service: UserService;
    let mockDatabaseService: Partial<DatabaseService>;

    beforeEach(async () => {
        mockDatabaseService = {
            read: jest.fn(),
            write: jest.fn(),
            update: jest.fn(),
            delete: jest.fn(),
        };

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                UserService,
                { provide: DatabaseService, useValue: mockDatabaseService },
            ],
        }).compile();

        service = module.get<UserService>(UserService);
    });

    it('readUser should return user data', async () => {
        const mockUserData = { uid: 'test_uid', name: 'Tester' };
        (mockDatabaseService.read as jest.Mock).mockResolvedValue(mockUserData);

        const result = await service.readUser('test_uid');
        expect(result).toEqual(mockUserData);
        expect(mockDatabaseService.read).toHaveBeenCalledWith('users/test_uid');
    });

    it('writeUser should write user data', async () => {
        (mockDatabaseService.read as jest.Mock).mockResolvedValue(null);

        const userData = { name: 'Tester' };
        await service.writeUser('test_uid', userData);

        expect(mockDatabaseService.write).toHaveBeenCalledWith('users/test_uid', userData);
    });

    it('writeUser should not overwrite if onlyIfAbsent=true and user exists', async () => {
        (mockDatabaseService.read as jest.Mock).mockResolvedValue({ uid: 'test_uid', name: 'Existing' });

        const userData = { name: 'Tester' };
        await service.writeUser('test_uid', userData, true);

        expect(mockDatabaseService.write).not.toHaveBeenCalled();
    });

    it('updateUser should update user data with updatedAt', async () => {
        const updates = { nickname: 'updated nickname' };

        await service.updateUser('test_uid', updates);

        expect(mockDatabaseService.update).toHaveBeenCalledWith(
            'users/test_uid',
            expect.objectContaining({
                nickname: 'updated nickname',
                updatedAt: expect.any(String),
            }),
        );
    });

    it('deleteUser should delete user', async () => {
        await service.deleteUser('test_uid');

        expect(mockDatabaseService.delete).toHaveBeenCalledWith('users/test_uid');
    });

    it('initUser should write new user if not exists', async () => {
        (mockDatabaseService.read as jest.Mock).mockResolvedValue(null);

        const decodedUser = {
            uid: 'test_uid',
            email: 'test@example.com',
            name: 'Tester',
            picture: 'http://photo.url',
            firebase: { sign_in_provider: 'google' },
        };

        await service.initUser(decodedUser);

        expect(mockDatabaseService.write).toHaveBeenCalledWith(
            'users/test_uid',
            expect.objectContaining({
                name: 'Tester',
                email: 'test@example.com',
                nickname: 'Tester',
                photoUrl: 'http://photo.url',
                loginMethod: 'google',
                createdAt: expect.any(String),
                updatedAt: expect.any(String),
            }),
        );
    });

    it('initUser should update user if missing fields exist', async () => {
        (mockDatabaseService.read as jest.Mock).mockResolvedValue({
            uid: 'test_uid',
            name: 'Tester',
            email: 'test@example.com',
            nickname: 'Tester',
            photoUrl: 'http://photo.url',
        });

        const decodedUser = {
            uid: 'test_uid',
            email: 'test@example.com',
            name: 'Tester',
            picture: 'http://photo.url',
            firebase: { sign_in_provider: 'google' },
        };

        await service.initUser(decodedUser);

        expect(mockDatabaseService.update).toHaveBeenCalledWith(
            'users/test_uid',
            expect.objectContaining({
                loginMethod: 'google',
                createdAt: expect.any(String),
                updatedAt: expect.any(String),
                projectIds: expect.any(Object),
                averageScore: expect.any(Number),
                targetScore: expect.any(Number),
                cpm: expect.any(Number),
            }),
        );
    });

    it('initUser should not update user if no missing fields exist', async () => {
        (mockDatabaseService.read as jest.Mock).mockResolvedValue({
            name: 'Tester',
            email: 'test@example.com',
            nickname: 'Tester',
            photoUrl: 'http://photo.url',
            loginMethod: 'google',
            createdAt: '2023-01-01T00:00:00.000Z',
            updatedAt: '2023-01-01T00:00:00.000Z',
            projectIds: {},
            averageScore: 0.0,
            targetScore: 90.0,
            cpm: 0.0,
        });

        const decodedUser = {
            uid: 'test_uid',
            email: 'test@example.com',
            name: 'Tester',
            picture: 'http://photo.url',
            firebase: { sign_in_provider: 'google' },
        };

        await service.initUser(decodedUser);

        expect(mockDatabaseService.update).not.toHaveBeenCalled();
    });

    it('initUser should handle undefined fields and set defaults', async () => {
        (mockDatabaseService.read as jest.Mock).mockResolvedValue(null);

        const decodedUser = {
            uid: 'test_uid',
            firebase: {},
        };

        await service.initUser(decodedUser);

        expect(mockDatabaseService.write).toHaveBeenCalledWith(
            'users/test_uid',
            expect.objectContaining({
                name: '',
                email: '',
                nickname: '',
                photoUrl: '',
                loginMethod: 'unknown',
                createdAt: expect.any(String),
                updatedAt: expect.any(String),
            }),
        );
    });
});
