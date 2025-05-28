import { useState, useEffect } from 'react';
import * as projectAPI from '../utils/api/project';
import * as userAPI from '../utils/api/user';

export default function useProjects(user, setUser) {
    const [projects, setProjects] = useState([]);
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        if (!user?.projectIds) return;

        const loadProjects = async () => {
            setLoading(true);
            try {
                const entries = Object.entries(user.projectIds).filter(
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
            } catch (e) {
                console.error('[useProjects] 프로젝트 로딩 실패:', e);
            } finally {
                setLoading(false);
            }
        };

        loadProjects();
    }, [user]);

    const create = async ({ title, description }) => {
        const project = await projectAPI.createProject({ title, description });

        const updatedProjectIds = { ...(user.projectIds || {}), [project.id]: project.status };
        await userAPI.updateUser({ projectIds: updatedProjectIds });
        setUser({ ...user, projectIds: updatedProjectIds });

        setProjects((prev) => [project, ...prev]);
        return project;
    };

    const join = async (projectId, user) => {
        const project = await projectAPI.fetchProjectById(projectId);
        if (!project || project.participants[user.uid]) throw new Error('참여 불가');

        await projectAPI.updateProject(projectId, {
            participants: { ...project.participants, [user.uid]: 'member' },
        });

        const updatedProjectIds = { ...(user.projectIds || {}), [projectId]: project.status };
        await userAPI.updateUser({ projectIds: updatedProjectIds });
        setUser({ ...user, projectIds: updatedProjectIds });

        setProjects((prev) => [
            { ...project, participants: { ...project.participants, [user.uid]: 'member' } },
            ...prev,
        ]);
    };

    const update = async (id, updates) => {
        await projectAPI.updateProject(id, updates);
        setProjects((ps) => ps.map((p) => (p.id === id ? { ...p, ...updates } : p)));
    };

    const remove = async (id) => {
        await projectAPI.deleteProject(id);

        const updatedProjectIds = { ...user.projectIds };
        delete updatedProjectIds[id];
        await userAPI.updateUser({ projectIds: updatedProjectIds });
        setUser({ ...user, projectIds: updatedProjectIds });

        setProjects((ps) => ps.filter((p) => p.id !== id));
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