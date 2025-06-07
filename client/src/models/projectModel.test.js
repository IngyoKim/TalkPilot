import { ProjectModel, ProjectRole, canEdit } from './projectModel';

describe('ProjectModel', () => {
    it('기본값으로 생성됨', () => {
        const model = ProjectModel('p1');
        expect(model).toMatchObject({
            id: 'p1',
            title: '',
            description: '',
            status: 'preparing',
            participants: {},
            scriptParts: [],
        });
    });

    it('올바른 데이터로 필드 생성됨', () => {
        const data = {
            title: '테스트 프로젝트',
            description: '설명',
            createdAt: '2024-01-01T00:00:00Z',
            participants: { u1: 'member' },
            scriptParts: ['a', 'b'],
            estimatedTime: 60,
            score: 85,
            scheduledDate: '2024-01-10T10:00:00Z',
        };
        const model = ProjectModel('pid123', data);
        expect(model.title).toBe('테스트 프로젝트');
        expect(model.createdAt).toBeInstanceOf(Date);
        expect(model.participants.u1).toBe('member');
        expect(model.estimatedTime).toBe(60);
    });
});

describe('canEdit', () => {
    it('owner와 editor는 true 반환', () => {
        expect(canEdit(ProjectRole.owner)).toBe(true);
        expect(canEdit(ProjectRole.editor)).toBe(true);
    });

    it('member는 false 반환', () => {
        expect(canEdit(ProjectRole.member)).toBe(false);
    });
});
