import { useState } from 'react';

import { Sidebar } from '@/components/SideBar';
import { useUser } from '@/contexts/UserContext';
import userProjects from '@/utils/userProjects';
import ProfileDropdown from '@/pages/Profile/ProfileDropdown';


const mainColor = '#673AB7';

export default function ProjectCard() {
    const { user } = useUser();
    const {
        projects,
        create,
        join,
        update,
        remove,
        changeStatus
    } = userProjects(user);

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
                        <ProjectItemCard
                            key={project.id}
                            project={project}
                            onEdit={handleOpenEdit}
                            onDelete={remove}
                            onStatusChange={changeStatus}
                        />
                    ))}
                </div>
            </div>
        </div>
    );
};

// ✅ 내부에서만 쓰이는 카드 컴포넌트 정의
function ProjectItemCard({ project, onEdit, onDelete, onStatusChange }) {
    return (
        <div style={{ border: '1px solid #ccc', borderRadius: 8, padding: 16 }}>
            <h3>{project.title}</h3>
            <p>{project.description}</p>
            <button onClick={() => onEdit(project)}>수정</button>
            <button onClick={() => onDelete(project.id)}>삭제</button>
            <button onClick={() => onStatusChange(project.id, 'done')}>완료</button>
        </div>
    );
}
