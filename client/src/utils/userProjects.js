import { useState, useEffect } from 'react';

import * as userAPI from '@/utils/api/user';
import * as projectAPI from '@/utils/api/project';

export default function useProjects(user, setUser) {
    const [projects, setProjects] = useState([]);
    const [loading, setLoading] = useState(false);

    const loadProjects = async (projectIds) => {
        console.log('[useProjects] 프로젝트 목록 불러오기 시작:', projectIds);
        const entries = Object.entries(projectIds || {}).filter(
            ([id]) => typeof id === 'string' && id.trim() !== '' && id !== 'undefined'
        );

        try {
            const fetched = await Promise.all(
                entries.map(async ([id, status]) => {
                    try {
                        const project = await projectAPI.fetchProjectById(id);
                        return project ? { ...project, status } : null;
                    } catch (e) {
                        console.warn(`[useProjects] 프로젝트(${id}) 불러오기 실패:`, e);
                        return null;
                    }
                })
            );

            const validProjects = fetched.filter(Boolean);
            setProjects(
                validProjects.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
            );
            console.log('[useProjects] 프로젝트 불러오기 완료:', validProjects);
        } catch (e) {
            console.error('[useProjects] 프로젝트 로딩 중 오류 발생:', e);
        }
    };

    useEffect(() => {
        if (!user?.projectIds) {
            console.log('[useProjects] 사용자에 연결된 프로젝트 없음');
            setProjects([]);
            return;
        }
        loadProjects(user.projectIds);
    }, [JSON.stringify(user?.projectIds)]);

    const create = async ({ title, description }) => {
        console.log('[useProjects] 프로젝트 생성 시작:', title);
        const project = await projectAPI.createProject({ title, description });

        const updatedProjectIds = { ...(user.projectIds || {}), [project.id]: 'preparing' };
        await userAPI.updateUser({ projectIds: updatedProjectIds });
        setUser(prev => ({ ...prev, projectIds: updatedProjectIds }));

        console.log('[useProjects] 프로젝트 생성 완료:', project);
        return project;
    };

    const join = async (projectId) => {
        console.log('[useProjects] 프로젝트 참여 시도:', projectId);
        const project = await projectAPI.fetchProjectById(projectId);
        if (!project || project.participants[user.uid]) {
            console.warn('[useProjects] 참여 실패 - 이미 참여 중이거나 프로젝트 없음:', projectId);
            throw new Error('참여 불가');
        }

        const newParticipants = { ...project.participants, [user.uid]: 'member' };
        await projectAPI.updateProject(projectId, { participants: newParticipants });

        const updatedProjectIds = { ...(user.projectIds || {}), [projectId]: project.status };
        await userAPI.updateUser({ projectIds: updatedProjectIds });
        setUser(prev => ({ ...prev, projectIds: updatedProjectIds }));

        console.log('[useProjects] 프로젝트 참여 완료:', projectId);
    };

    const update = async (id, updates) => {
        console.log('[useProjects] 프로젝트 업데이트:', id, updates);
        await projectAPI.updateProject(id, updates);
        setProjects((ps) => ps.map((p) => (p.id === id ? { ...p, ...updates } : p)));
    };

    const remove = async (id) => {
        console.log('[useProjects] 프로젝트 삭제 시도:', id);
        try {
            await projectAPI.deleteProject(id);

            const updatedProjectIds = { ...user.projectIds };
            delete updatedProjectIds[id];

            await userAPI.updateUser({ projectIds: updatedProjectIds });
            setUser(prev => ({ ...prev, projectIds: updatedProjectIds }));

            await loadProjects(updatedProjectIds);

            console.log('[useProjects] 프로젝트 삭제 완료:', id);
        } catch (e) {
            console.error('[useProjects] 삭제 실패:', e);
            throw e;
        }
    };

    const changeStatus = async (id, newStatus) => {
        console.log('[useProjects] 프로젝트 상태 변경:', id, newStatus);
        await update(id, { status: newStatus });
    };

    return {
        projects,
        loading,
        create,
        join,
        update,
        remove,
        changeStatus,
    };
}
