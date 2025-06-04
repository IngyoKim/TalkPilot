import { useState } from 'react';
import Sidebar from '@/components/SideBar';
import ProfileDropdown from '@/pages/Profile/ProfileDropdown';
import ToastMessage from '@/components/ToastMessage';
import { FaTachometerAlt, FaTrashAlt } from 'react-icons/fa';

const mockData = [
    { id: 1, name: 'AI 프로젝트 발표', cpm: 320, date: '2025-05-30' },
    { id: 2, name: '웹 개발 보고서', cpm: 295, date: '2025-05-21' },
];

export default function ProjectRecord() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [projects, setProjects] = useState(mockData);

    const toggleSidebar = () => setIsSidebarOpen(prev => !prev);
    const handleDelete = (id) => setProjects(projects.filter(p => p.id !== id));

    return (
        <div style={styles.container}>
            <Sidebar isOpen={isSidebarOpen} />

            <div style={styles.content(isSidebarOpen)}>
                <ProfileDropdown isSidebarOpen={isSidebarOpen} onToggleSidebar={toggleSidebar} />
                <h2 style={styles.header}>발표 기록</h2>

                <div style={styles.projectList}>
                    {projects.map(item => (
                        <div key={item.id} style={styles.projectBox}>
                            <div style={styles.projectInfo}>
                                <h3 style={styles.projectName}>{item.name}</h3>
                                <div style={styles.cpmRow}>
                                    <FaTachometerAlt style={styles.tachometerIcon} />
                                    <span style={styles.cpmText}>{item.cpm} CPM</span>
                                </div>
                                <p style={styles.date}>{item.date}</p>
                            </div>
                            <button
                                onClick={() => handleDelete(item.id)}
                                style={styles.deleteButton}
                            >
                                <FaTrashAlt />
                            </button>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}

const styles = {
    container: {
        display: 'flex',
        minHeight: '100vh',
        backgroundColor: '#f5f5f5',
    },
    content: (isSidebarOpen) => ({
        flex: 1,
        marginLeft: isSidebarOpen ? 240 : 60,
        transition: 'margin-left 0.3s ease',
    }),
    header: {
        fontSize: '24px',
        fontWeight: 'bold',
        marginBottom: '24px',
    },
    projectList: {
        display: 'flex',
        flexDirection: 'column',
        gap: '16px',
    },
    projectBox: {
        position: 'relative',
        background: 'white',
        borderRadius: '12px',
        padding: '20px',
        display: 'flex',
        flexDirection: 'column',
        boxShadow: '0 2px 6px rgba(0,0,0,0.1)',
        transition: 'box-shadow 0.3s ease-in-out',
    },
    projectInfo: {
        display: 'flex',
        flexDirection: 'column',
    },
    projectName: {
        fontSize: '20px',
        fontWeight: 600,
        marginBottom: '8px',
    },
    cpmRow: {
        display: 'flex',
        alignItems: 'center',
        gap: '8px',
        fontSize: '16px',
        color: '#333',
    },
    tachometerIcon: {
        color: '#555',
    },
    cpmText: {
        fontWeight: 500,
    },
    date: {
        fontSize: '14px',
        color: '#777',
        marginTop: '4px',
    },
    deleteButton: {
        position: 'absolute',
        right: '20px',
        top: '50%',
        transform: 'translateY(-50%)',
        background: 'none',
        border: 'none',
        color: '#cc0000',
        cursor: 'pointer',
        fontSize: '16px',
    },
};