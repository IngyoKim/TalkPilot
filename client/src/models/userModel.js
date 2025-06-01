export function UserModel(uid, data = {}) {
    return {
        uid,
        name: data.name || '',
        email: data.email || '',
        nickname: data.nickname || '',
        photoUrl: data.photoUrl || null,
        loginMethod: data.loginMethod || null,
        createdAt: data.createdAt ? new Date(data.createdAt) : null,
        updatedAt: data.updatedAt ? new Date(data.updatedAt) : null,
        projectIds: data.projectIds || {}, // { projectId: status }
        averageScore: typeof data.averageScore === 'number' ? data.averageScore : null,
        targetScore: typeof data.targetScore === 'number' ? data.targetScore : null,
        cpm: typeof data.cpm === 'number' ? data.cpm : null,
    };
}
