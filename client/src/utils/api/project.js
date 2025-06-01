import { getIdToken } from '@/utils/auth/auth';
import { ProjectModel } from '@/models/projectModel';


const API_URL = '/api/project';

/// Nest에서 새로운 프로젝트를 생성
export async function createProject(data) {
    const token = await getIdToken();
    const res = await fetch(API_URL, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(data),
    });
    return res.json();
}

/// 로그인된 uid를 기반으로
// 참여 중인 프로젝트 목록을 가져옴
export async function getProjects(uid) {
    const token = await getIdToken();
    const res = await fetch(`/api/project?uid=${uid}`, {
        headers: { Authorization: `Bearer ${token}` },
    });

    const json = await res.json();
    return json.map((p) => ProjectModel(p.id, p));
}


/// 선택된 프로젝트의 정보를 업데이트함(projectId를 받아서)
export async function updateProject(projectId, updates) {
    const token = await getIdToken();
    const res = await fetch(`${API_URL}/${projectId}`, {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(updates),
    });
    return res.json();
}

/// 선택된 프로젝트를 삭제함
export async function deleteProject(projectId) {
    const token = await getIdToken();
    const res = await fetch(`${API_URL}/${projectId}`, {
        method: 'DELETE',
        headers: {
            Authorization: `Bearer ${token}`,
        },
    });

    /// 본문이 없으면 .json() 호출 시 오류 나므로 안전 처리
    if (res.status === 204 || res.headers.get('content-length') === '0') {
        return null;
    }

    const text = await res.text();
    return text ? JSON.parse(text) : null;
}


/// [projectId]로 단일 프로젝트를 조회
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
    return ProjectModel(projectId, json);
}
