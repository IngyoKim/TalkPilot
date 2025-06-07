import { UserModel } from './userModel';

describe('UserModel', () => {
    it('기본값으로 생성됨', () => {
        const user = UserModel('u1');
        expect(user).toMatchObject({
            uid: 'u1',
            name: '',
            email: '',
            nickname: '',
            photoUrl: null,
            loginMethod: null,
            projectIds: {},
            averageScore: null,
            targetScore: null,
            cpm: null,
        });
    });

    it('입력 데이터로 필드가 설정됨', () => {
        const data = {
            name: '홍길동',
            email: 'test@example.com',
            nickname: '길동',
            projectIds: { pid1: 'done' },
            averageScore: 80,
            cpm: 250,
            createdAt: '2024-05-01T00:00:00Z',
        };
        const user = UserModel('u99', data);
        expect(user.name).toBe('홍길동');
        expect(user.projectIds.pid1).toBe('done');
        expect(user.createdAt).toBeInstanceOf(Date);
        expect(user.averageScore).toBe(80);
    });
});
