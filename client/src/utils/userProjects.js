import { useState, useEffect } from 'react';
import * as projectAPI from '../utils/api/project';
import * as userAPI from '../utils/api/user';

export default function useProjects(user, setUser) {
    const [projects, setProjects] = useState([]);
    const [loading, setLoading] = useState(false);

    const loadProjects = async (projectIds) => {
        const entries = Object.entries(projectIds || {}).filter(
            ([id]) => typeof id === 'string' && id.trim() !== '' && id !== 'undefined'
        );
        const fetched = await Promise.all(
            entries.map(async ([id, status]) => {
                try {
                    const project = await projectAPI.fetchProjectById(id);
                    return project ? { ...project, status } : null;
                } catch {
                    return null;
                }
            })
        );
        setProjects(
            fetched.filter(Boolean).sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
        );
    };

    useEffect(() => {
        if (!user?.projectIds) {
            setProjects([]);
            return;
        }
        loadProjects(user.projectIds);
    }, [JSON.stringify(user?.projectIds)]);

    const create = async ({ title, description }) => {
        const project = await projectAPI.createProject({ title, description });
        const updatedProjectIds = { ...(user.projectIds || {}), [project.id]: 'preparing' };
        await userAPI.updateUser({ projectIds: updatedProjectIds });
        setUser(prev => ({ ...prev, projectIds: updatedProjectIds }));
        return project;
    };

    const join = async (projectId) => {
        const project = await projectAPI.fetchProjectById(projectId);
        if (!project || project.participants[user.uid]) throw new Error('참여 불가');

        const newParticipants = { ...project.participants, [user.uid]: 'member' };
        await projectAPI.updateProject(projectId, { participants: newParticipants });

        const updatedProjectIds = { ...(user.projectIds || {}), [projectId]: project.status };
        await userAPI.updateUser({ projectIds: updatedProjectIds });
        setUser(prev => ({ ...prev, projectIds: updatedProjectIds }));
    };

    const update = async (id, updates) => {
        await projectAPI.updateProject(id, updates);
        setProjects((ps) => ps.map((p) => (p.id === id ? { ...p, ...updates } : p)));
    };

    const remove = async (id) => {
        try {
            await projectAPI.deleteProject(id);

            const updatedProjectIds = { ...user.projectIds };
            delete updatedProjectIds[id];

            await userAPI.updateUser({ projectIds: updatedProjectIds });
            setUser(prev => ({ ...prev, projectIds: updatedProjectIds }));

            await loadProjects(updatedProjectIds);

        } catch (e) {
            console.error('[useProjects] 삭제 실패:', e);
            throw e;
        }
    };


    const changeStatus = async (id, newStatus) => {
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
