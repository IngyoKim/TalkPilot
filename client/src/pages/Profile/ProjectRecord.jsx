import { useEffect, useState, useCallback } from 'react';
import Sidebar from '@/components/SideBar';
import ProfileDropdown from '@/pages/Profile/ProfileDropdown';
import ToastMessage from '@/components/ToastMessage';
import { FaTachometerAlt, FaTrashAlt } from 'react-icons/fa';

// API 연결
const fetchProjectList = async () => {
    return [
        { id: 1, name: 'AI 프로젝트 발표', cpm: 320, date: '2025-05-30' },
        { id: 2, name: '웹 개발 보고서', cpm: 295, date: '2025-05-21' },
    ];
};

export default function ProjectRecord() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [projects, setProjects] = useState([]);
    const [modal, setModal] = useState({ isOpen: false, projectId: null });
    const [messages, setMessages] = useState([]);

    const toggleSidebar = () => setIsSidebarOpen(prev => !prev);

    const showMessage = useCallback((text, type = 'blue', duration = 3000) => {
        const id = Date.now() + Math.random();
        setMessages(prev => [...prev, { id, text, type, duration }]);
    }, []);

    const handleDeleteClick = (id) => {
        setModal({ isOpen: true, projectId: id });
    };

    const handleDeleteConfirm = () => {
        setProjects(prev => prev.filter(p => p.id !== modal.projectId));
        setModal({ isOpen: false, projectId: null });
        showMessage('삭제되었습니다.', 'red');
    };

    useEffect(() => {
        const loadProjects = async () => {
            const data = await fetchProjectList();
            setProjects(data);
        };
        loadProjects();
    }, []);

    return (
        <div style={styles.container}>
            <Sidebar isOpen={isSidebarOpen} />
            <div style={styles.content(isSidebarOpen)}>
                <ProfileDropdown isSidebarOpen={isSidebarOpen} onToggleSidebar={toggleSidebar} />
                <h2 style={styles.header}>발표 기록</h2>
                <div style={styles.projectList}>
                    {projects.map(item => (
                        <ProjectCard
                            key={item.id}
                            item={item}
                            isSidebarOpen={isSidebarOpen}
                            onDelete={() => handleDeleteClick(item.id)}
                        />
                    ))}
                </div>
            </div>
            {modal.isOpen && (
                <ConfirmModal
                    onCancel={() => setModal({ isOpen: false, projectId: null })}
                    onConfirm={handleDeleteConfirm}
                />
            )}
            <ToastMessage messages={messages} setMessages={setMessages} />
        </div>
    );
}

function ProjectCard({ item, isSidebarOpen, onDelete }) {
    return (
        <div
            style={{
                ...styles.projectBox,
                width: isSidebarOpen ? 'calc(20% - 20px)' : 'calc(16.66% - 20px)',
            }}
        >
            <div style={styles.projectInfo}>
                <h3 style={styles.projectName}>{item.name}</h3>
                <div style={styles.cpmRow}>
                    <FaTachometerAlt style={styles.tachometerIcon} />
                    <span style={styles.cpmText}>{item.cpm} CPM</span>
                </div>
                <p style={styles.date}>{item.date}</p>
            </div>
            <button onClick={onDelete} style={styles.deleteButton}>
                <FaTrashAlt />
            </button>
        </div>
    );
}

function ConfirmModal({ onCancel, onConfirm }) {
    return (
        <div style={styles.modalOverlay}>
            <div style={styles.modal}>
                <p style={styles.modalText}>정말로 삭제하시겠습니까?</p>
                <div style={styles.modalActions}>
                    <button onClick={onCancel} style={styles.cancelBtn}>취소</button>
                    <button onClick={onConfirm} style={styles.deleteBtn}>삭제</button>
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
        padding: '24px',
    }),
    header: {
        fontSize: '24px',
        fontWeight: 'bold',
        marginBottom: '24px',
    },
    projectList: {
        display: 'flex',
        flexWrap: 'wrap',
        gap: '20px',
    },
    projectBox: {
        background: 'white',
        borderRadius: '12px',
        padding: '20px',
        boxShadow: '0 8px 6px rgba(0,0,0,0.3)',
        minWidth: '200px',
        boxSizing: 'border-box',
        position: 'relative',
        display: 'flex',
        flexDirection: 'column',
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
        top: '10px',
        background: 'none',
        border: 'none',
        color: '#cc0000',
        cursor: 'pointer',
        fontSize: '16px',
    },
    modalOverlay: {
        position: 'fixed',
        top: 0,
        left: 0,
        width: '100vw',
        height: '100vh',
        backgroundColor: 'rgba(0,0,0,0.5)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 1000,
    },
    modal: {
        backgroundColor: 'white',
        padding: '24px',
        borderRadius: '12px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.2)',
        minWidth: '300px',
        textAlign: 'center',
    },
    modalText: {
        fontSize: '18px',
        marginBottom: '16px',
    },
    modalActions: {
        display: 'flex',
        justifyContent: 'space-around',
    },
    cancelBtn: {
        padding: '8px 16px',
        backgroundColor: '#ccc',
        border: 'none',
        borderRadius: '8px',
        cursor: 'pointer',
    },
    deleteBtn: {
        padding: '8px 16px',
        backgroundColor: '#cc0000',
        color: 'white',
        border: 'none',
        borderRadius: '8px',
        cursor: 'pointer',
    },
};
