import { getIdToken } from '../auth/auth';
import { UserModel } from '../../models/userModel';

/// Nest에서 uid로 유저 정보를 가져옴.
export async function fetchUserByUid(uid) {
    const token = await getIdToken();
    const res = await fetch(`/api/user/${uid}`, {
        headers: { Authorization: `Bearer ${token}` },
    });

    if (!res.ok) throw new Error('사용자 정보 요청 실패');

    const json = await res.json();
    return UserModel(uid, json);
}

/// Nest에서 user의 [updates]를 업데이트함.

export async function fetchProjectById(projectId) {
    const token = await getIdToken();
    const res = await fetch(`/api/project/${projectId}`, {
        headers: { Authorization: `Bearer ${token}` },
    });

    if (res.status === 404) {
        console.warn(`[projectAPI] 프로젝트 ${projectId} 가 존재하지 않음`);
        return null;
    }

    if (!res.ok) throw new Error('프로젝트 조회 실패');

    const json = await res.json();
    return createProjectModel(projectId, json);
}