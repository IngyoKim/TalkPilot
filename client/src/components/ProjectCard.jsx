import { useState } from 'react';

import { Sidebar } from '@/components/SideBar';
import { useUser } from '@/contexts/UserContext';
import { useProjects } from '@/utils/useProjects';
import { ProjectCard } from '@/components/ProjectCard';
import { ProjectModal } from '@/components/ProjectModal';
import { ProfileDropdown } from '@/pages/Profile/ProfileDropdown';


const mainColor = '#673AB7';

export default function ProjectCard() {
    const { user } = useUser();
    const {
        projects,
        create,
        join,
        update,
        remove,
        changeStatus,
    } = useProjects(user);

    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [editProject, setEditProject] = useState(null); // null이면 create

    const handleOpenCreate = () => {
        setEditProject(null);
        setShowModal(true);
    };

    const handleOpenEdit = (project) => {
        setEditProject(project);
        setShowModal(true);
    };

    const handleCloseModal = () => {
        setShowModal(false);
        setEditProject(null);
    };

    return (
        <div style={{ display: 'flex' }}>
            <div style={{ flex: 1, padding: 20, marginLeft: isSidebarOpen ? 240 : 0 }}>
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen((o) => !o)}
                />
                <Sidebar isOpen={isSidebarOpen} />

                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 20 }}>
                    <button
                        style={{
                            backgroundColor: mainColor,
                            color: '#fff',
                            padding: '10px 16px',
                            borderRadius: 8,
                            border: 'none',
                            cursor: 'pointer',
                        }}
                        onClick={handleOpenCreate}
                    >
                        프로젝트 추가
                    </button>
                </div>

                <div
                    style={{
                        display: 'grid',
                        gridTemplateColumns: 'repeat(auto-fill, minmax(220px, 1fr))',
                        gap: 20,
                    }}
                >
                    {projects.map((project) => (
                        <ProjectCard
                            key={project.id}
                            project={project}
                            onEdit={handleOpenEdit}
                            onDelete={remove}
                            onStatusChange={changeStatus}
                        />
                    ))}
                </div>

                {showModal && (
                    <ProjectModal
                        mode={editProject ? 'edit' : 'createOrJoin'}
                        project={editProject}
                        onClose={handleCloseModal}
                        onCreate={create}
                        onJoin={(projectId) => join(projectId, user)}
                        onUpdate={update}
                    />
                )}
            </div>
        </div>
    );
}
