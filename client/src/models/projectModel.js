export const ProjectRole = {
    owner: 'owner',
    editor: 'editor',
    member: 'member',
};

export function canEdit(role) {
    return role === ProjectRole.owner || role === ProjectRole.editor;
}

export function ProjectModel(id, data = {}) {
    return {
        id,
        title: data.title || '',
        description: data.description || '',
        createdAt: data.createdAt ? new Date(data.createdAt) : null,
        updatedAt: data.updatedAt ? new Date(data.updatedAt) : null,
        ownerUid: data.ownerUid || '',
        participants: data.participants || {}, // uid: 'role'
        status: data.status || 'preparing',
        estimatedTime: typeof data.estimatedTime === 'number' ? data.estimatedTime : null,
        score: typeof data.score === 'number' ? data.score : null,
        script: data.script || '',
        scheduledDate: data.scheduledDate ? new Date(data.scheduledDate) : null,
        memo: data.memo || '',
        scriptParts: Array.isArray(data.scriptParts) ? data.scriptParts : [],
    };
}
