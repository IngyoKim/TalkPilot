import { useState } from 'react';
import Sidebar from '../../components/SideBar';
import ProfileDropdown from '../Profile/ProfileDropdown';

export default function MyPresentation() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [projects, setProjects] = useState([]);

    const handleAddProject = () => {
        const newProject = `Project ${projects.length + 1}`;
        setProjects(prev => [...prev, newProject]);
    };

    return (
        <div style={styles.container}>
            <Sidebar isOpen={isSidebarOpen} onAddProject={handleAddProject} />
            <div
                style={{
                    ...styles.content,
                    marginLeft: isSidebarOpen ? 240 : 0,
                }}
            >
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen(prev => !prev)}
                />

                <div style={styles.projectSection}>
                    <h2>프로젝트 목록</h2>
                    <ul>
                        {projects.map((project, index) => (
                            <li key={index} style={styles.projectItem}>
                                {project}
                            </li>
                        ))}
                    </ul>
                </div>
            </div>
        </div>
    );
}

const styles = {
    container: {
        display: 'flex',
    },
    content: {
        flex: 1,
        transition: 'margin-left 0.3s ease',
        padding: '20px',
    },
    projectSection: {
        marginTop: '20px',
    },
    projectItem: {
        padding: '8px 0',
        borderBottom: '1px solid #ccc',
    },
};
