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
        const mockUserData = { uid: 'test_uid', name: 'Test User' };
        (mockDatabaseService.read as jest.Mock).mockResolvedValue(mockUserData);

        const result = await service.readUser('test_uid');
        expect(result).toEqual(mockUserData);
        expect(mockDatabaseService.read).toHaveBeenCalledWith('users/test_uid');
    });

    it('writeUser should write user data', async () => {
        (mockDatabaseService.read as jest.Mock).mockResolvedValue(null);

        const userData = { name: 'Test User' };
        await service.writeUser('test_uid', userData);

        expect(mockDatabaseService.write).toHaveBeenCalledWith('users/test_uid', userData);
    });

    it('updateUser should update user data with updatedAt', async () => {
        const updates = { nickname: 'Updated Nick' };

        await service.updateUser('test_uid', updates);

        expect(mockDatabaseService.update).toHaveBeenCalledWith(
            'users/test_uid',
            expect.objectContaining({
                nickname: 'Updated Nick',
                updatedAt: expect.any(String),
            }),
        );
    });

    it('deleteUser should delete user', async () => {
        await service.deleteUser('test_uid');

        expect(mockDatabaseService.delete).toHaveBeenCalledWith('users/test_uid');
    });
});
